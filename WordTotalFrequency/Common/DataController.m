//
//  DataController.m
//  CoreDataLibrary
//
//  
//  Copyright 2010 Eric Peter. 
//  Released under the GPL v3 License
//
//  code.google.com/p/coredatalibrary

#import "DataController.h"
#import "SynthesizeSingleton.h"
#import "NSDate+Ext.h"
#import "DataUtil.h"
#import "Constant.h"
#import <sqlite3.h>

@interface DataController()
- (void)checkHistoryDatabase;
- (BOOL)migrateObsoleteDatabase;
- (void)migrateHistoryDatabase;
@end

@implementation DataController

SYNTHESIZE_SINGLETON_FOR_CLASS(DataController);

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize historyDatabase = _historyDatabase;
@synthesize notificationOn;

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        [_managedObjectContext setUndoManager:nil];
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
	NSError *error = nil;
	//Try to automatically migrate minor changes
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: 
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSReadOnlyPersistentStoreOption,
                             nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:[NSURL fileURLWithPath:self.bundleDbPath]
                                                         options:options
                                                           error:&error]) {
		[self handleError:error fromSource:@"Open persistant store"];
    }
    
    // check history db, create it if not exist
    [self checkHistoryDatabase];
    
    // handle obsolete WordFrequencyList.sqlite under document
    BOOL b = [self migrateObsoleteDatabase];
    
    // check plist file version
    NSDictionary *dict = [DataUtil readDictionaryFromBundleFile:@"WordSets"];
    int bundleVersion = [[dict objectForKey:@"Version"] intValue];
    BOOL needMigrate = NO;
    if (![self.settingsDictionary.allKeys containsObject:@"Version"]){
        needMigrate = YES;
    }
    else{
        int docVersion = [[self.settingsDictionary objectForKey:@"Version"] intValue];
        if (bundleVersion > docVersion){
            needMigrate = YES;
        }
    }
    if (needMigrate) {
        [self.settingsDictionary setValue:[NSNumber numberWithInt:bundleVersion] forKey:@"Version"];
        [self saveSettingsDictionary];
    }
#ifdef DEBUG
//    needMigrate = YES;
#endif
    
    if (needMigrate && !b) {
        [self migrateHistoryDatabase];
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - history database & related actions
- (FMDatabase *)historyDatabase{
    if (_historyDatabase != nil)
        return _historyDatabase;
    
    _historyDatabase = [[FMDatabase databaseWithPath:self.docHistoryPath] retain];
    [_historyDatabase open];
    return _historyDatabase;
}

- (void)checkHistoryDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.docHistoryPath]){
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        FMDatabase *db = [FMDatabase databaseWithPath:self.docHistoryPath];
        if (![db open]){
            [pool release];
            return;
        }
        
        [db beginTransaction];
        [db executeUpdate:@"CREATE TABLE history (spell VARCHAR(255) PRIMARY KEY, markComplete INTEGER, markDate VARCHAR(255), categoryId INTEGER, groupId INTEGER)"];
        [db executeUpdate:@"CREATE INDEX history_spell_index ON history (spell)"];
        [db executeUpdate:@"CREATE INDEX history_markDate_index ON history (markDate)"];
        [db executeUpdate:@"CREATE INDEX history_categoryId_index ON history (categoryId)"];
        [db executeUpdate:@"CREATE INDEX history_groupId_index ON history (groupId)"];
        [db commit];
        
        [db close];
        
        [pool release];
    }
}

- (BOOL)migrateObsoleteDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbInDoc = [[self.applicationDocumentsDirectory stringByAppendingPathComponent:SQL_DATABASE_NAME] stringByAppendingString:@".sqlite"];
	// If there is db under document, migrate history data
	if (![fileManager fileExistsAtPath:dbInDoc]) {
		return NO;
	}
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // get mark history from obsolete word table, store in array
    FMDatabase *db = [FMDatabase databaseWithPath:dbInDoc];
    if (![db open]){
        [pool release];
        return NO;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet *rs = [db executeQuery:@"SELECT ZSPELL FROM ZWORD WHERE ZMARKDATE <> ''"];
    while ([rs next]) {
        [array addObject:[rs stringForColumnIndex:0]];
    }
    [rs close];
    [db close];
    
    // remove document db
    [fileManager removeItemAtPath:dbInDoc error:NULL];
    
    // compare to bundle database
    FMDatabase *dbBundle = [FMDatabase databaseWithPath:self.bundleDbPath];
    [dbBundle open];
    
    [self.historyDatabase beginTransaction];
    for (NSString *spell in array) {
        FMResultSet *rs2 = [dbBundle executeQuery:@"SELECT ZMARKSTATUS, ZMARKDATE, ZCATEGORY, ZGROUP FROM ZWORD WHERE ZSPELL = ?", spell];
        if ([rs2 next]) {
            [self.historyDatabase executeUpdate:@"INSERT INTO history VALUES (?, ?, ?, ?, ?)",
             spell,
             [NSNumber numberWithInt:[rs2 intForColumn:@"ZMARKSTATUS"]-1],
             [rs2 stringForColumn:@"ZMARKDATE"],
             [NSNumber numberWithInt:[rs2 intForColumn:@"ZCATEGORY"]],
             [NSNumber numberWithInt:[rs2 intForColumn:@"ZGROUP"]]];
        }
        [rs2 close];
    }
    [self.historyDatabase commit];
    
    [dbBundle close];
    
    [array release];
    [pool release];
    return YES;
}

- (void)migrateHistoryDatabase
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *wordsNotExist = [[NSMutableArray alloc] init];
    
    
    // double check category & group index
    FMDatabase *dbBundle = [FMDatabase databaseWithPath:self.bundleDbPath];
    [dbBundle open];
    
    FMResultSet *rs = [self.historyDatabase executeQuery:@"SELECT spell FROM history"];
    while ([rs next]) {
        NSString *spell = [rs stringForColumnIndex:0];
        
        FMResultSet *rs2 = [dbBundle executeQuery:@"SELECT ZCATEGORY, ZGROUP FROM ZWORD WHERE ZSPELL = ?", spell];
        if ([rs2 next]) {
            [self.historyDatabase executeUpdate:@"UPDATE history SET categoryId = ?, groupId = ? WHERE spell = ?",
             [NSNumber numberWithInt:[rs2 intForColumn:@"ZCATEGORY"]],
             [NSNumber numberWithInt:[rs2 intForColumn:@"ZGROUP"]],
             spell];
        }
        else {
            [wordsNotExist addObject:spell];
        }
        [rs2 close];
    }
    [rs close];
    
    [dbBundle close];
    
    
    // remove histories that do not exist in bundle database any more
    for (NSString *spell in wordsNotExist) {
        [self.historyDatabase executeQuery:@"DELETE FROM history WHERE spell = ?", spell];
    }
    
    [wordsNotExist release];
    [pool release];
}

- (NSString *)AppID
{
    NSString *appid = [self.settingsDictionary objectForKey:@"AppID"];
    if (!appid)
        appid = @"481628150";
    return appid;
}

#pragma mark - CDLC Save

/**
 Saves the Managed Object Context, calling the logging method if an error occurs
 */
- (void)saveFromSource:(NSString *)source
{
	NSError *error;
	if (![[self managedObjectContext] save:&error]) {
		[self handleError:error fromSource:source];
	}
}

#pragma mark -
#pragma mark Error Handling

/**
 Error logging/user notification should be implemented here.  Call this method whenever an error happens
 */
/*
 Apple says: "Replace this implementation with code to handle the error appropriately.
 
 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.

 Check the error message to determine what the actual problem was."
 */
- (void) handleError:(NSError *)error fromSource:(NSString *)sourceString
{
	NSLog(@"Unresolved error %@ at %@, %@", error, sourceString, [error userInfo]);
	abort(); // Fail
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
													message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - handy methods

- (void)markWord:(Word *)word status:(NSUInteger)status
{
    if (status == 0){
        [self.historyDatabase executeUpdate:@"DELETE FROM history WHERE spell = ?", word.spell];
    }
    else if (status == 1){
        [self.historyDatabase executeUpdate:@"INSERT INTO history VALUES (?, ?, ?, ?, ?)",
         [[word.spell retain] autorelease],
         [NSNumber numberWithInt:0],
         [[NSDate date] formatLongDate],
         word.category,
         word.group];
    }
    else if (status == 2){
        [self.historyDatabase executeUpdate:@"UPDATE history SET markComplete = 1, markDate = ? WHERE spell = ?", [[NSDate date] formatLongDate], word.spell];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HISTORY_CHANGED_NOTIFICATION object:self];
}

- (int)markWordToNextLevel:(Word *)word
{
    int status = [self getMarkStatusBySpell:word.spell];
    int k = status + 1;
    if (k == 3) k = 0;
    [self markWord:word status:k];
    return k;
}

static NSDictionary *alldict = nil;

- (NSDictionary *)settingsDictionary
{
    if (alldict == nil){
        alldict = [[DataUtil readDictionaryFromFile:@"WordSets"] retain];
    }
    return alldict;
}

- (NSDictionary *)dictionaryForCategoryId:(NSUInteger)categoryId
{
    NSArray *array = [self.settingsDictionary objectForKey:@"WordSets"];
    NSDictionary *dict = [array objectAtIndex:categoryId];
    return dict;
}

- (void)setNotificationOn:(BOOL)_notificationOn
{
    [self.settingsDictionary setValue:[NSNumber numberWithBool:_notificationOn] forKey:@"NotificationOn"];
}

- (BOOL)isNoticationOn
{
    NSNumber *number = [self.settingsDictionary objectForKey:@"NotificationOn"];
    return [number boolValue];
}

- (void)setDetailPageAutoSpeakOn:(BOOL)_autoSpeakOn
{
    [self.settingsDictionary setValue:[NSNumber numberWithBool:_autoSpeakOn] forKey:@"DetailPageAutoSpeakOn"];
}

- (BOOL)isDetailPageAutoSpeakOn
{
    NSNumber *number = [self.settingsDictionary objectForKey:@"DetailPageAutoSpeakOn"];
    return [number boolValue];
}

- (void)saveSettingsDictionary
{
    [DataUtil writeDictionary:self.settingsDictionary toDataFile:@"WordSets"];
}

- (NSString *)bundleDbPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:SQL_DATABASE_NAME ofType:@"sqlite"];
    return path;
}

- (NSString *)docHistoryPath
{
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"History"];
	path = [path stringByAppendingString: @".sqlite"];
    return path;
}

- (NSArray*)getLevelList
{
    NSArray* ary = [self.settingsDictionary objectForKey:@"LevelList"];
    return ary;
}

- (void)scheduleNextWord
{
    if (![self isNoticationOn])
        return;
    
    // retrieve next unmarked word
    NSString *nextWord = @"";
    NSString *cursor;
    FMDatabase *db = [FMDatabase databaseWithPath:self.bundleDbPath];
    [db open];
    FMResultSet *rs = [db executeQuery:@"SELECT ZSPELL FROM ZWORD"];
    while ([rs next]) {
        cursor = [rs stringForColumnIndex:0];
        FMResultSet *rs2 = [self.historyDatabase executeQuery:@"SELECT spell FROM history WHERE spell = ?", cursor];
        if ([rs2 next]){
            [rs2 close];
            continue;
        }
        else {
            [rs2 close];
            break;
        }
    }
    [rs close];
    [db close];
    
    if ([nextWord isEqualToString:@""])
        return;
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    // Get the current date
    NSDate *pickerDate = [NSDate date];
    
    // Break the date up into components
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit)
												   fromDate:pickerDate];
//    NSDateComponents *timeComponents = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
//												   fromDate:pickerDate];
    // Set up the fire time
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]+1];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:11];
    [dateComps setMinute:30];
	[dateComps setSecond:0];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    [dateComps release];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
	// Notification details
    localNotif.alertBody = [NSString stringWithFormat:@"Time to learn new word: %@", nextWord];
	// Set the action button
    localNotif.alertAction = @"View";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
	// Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    localNotif.userInfo = infoDict;
    
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
}



- (void)incrementAppLoadedTimes
{
    int times = [[self.settingsDictionary objectForKey:@"AppLoadedTimes"] intValue];
    times += 1;
    if (times % 5 == 0) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"喜欢我们的应用吗？"
                                                         message:@"请为词频背单词评分，您的褒奖和批评是我们持续改进的动力，谢谢！"
                                                        delegate:self
                                               cancelButtonTitle:@"不予置评"
                                               otherButtonTitles:@"我要评分！", nil] autorelease];
        [alert show];
    }
    [self.settingsDictionary setValue:[NSNumber numberWithInt:times] forKey:@"AppLoadedTimes"];
    [self saveSettingsDictionary];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", self.AppID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    }
}

- (int)getMarkStatusBySpell:(NSString *)spell
{
    int status = 0;
    FMResultSet *rs = [self.historyDatabase executeQuery:@"SELECT markComplete FROM history WHERE spell = ?", spell];
    if ([rs next])
        status = [rs intForColumnIndex:0] + 1;
    [rs close];
    return status;
}

- (int)getMarkCountByCategory:(NSUInteger)category AndStatus:(NSUInteger)status
{
    int count = 0;
    FMResultSet *rs = [self.historyDatabase executeQuery:@"SELECT COUNT(*) FROM history WHERE categoryId = ? AND markComplete = ?", [NSNumber numberWithInt:category], [NSNumber numberWithInt:status]];
    if ([rs next])
        count = [rs intForColumnIndex:0];
    return count;
}

- (int)getMarkCountByCategory:(NSUInteger)category AndGroup:(NSUInteger)group AndStatus:(NSUInteger)status
{
    int count = 0;
    FMResultSet *rs = [self.historyDatabase executeQuery:@"SELECT COUNT(*) FROM history WHERE categoryId = ? AND groupId = ? AND markComplete = ?", [NSNumber numberWithInt:category], [NSNumber numberWithInt:group], [NSNumber numberWithInt:status]];
    if ([rs next])
        count = [rs intForColumnIndex:0];
    return count;
}

- (NSArray *)getMarkedWordsByCategory:(NSUInteger)category AndGroup:(NSUInteger)group
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    FMResultSet *rs = [self.historyDatabase executeQuery:@"SELECT spell FROM history WHERE categoryId = ? AND groupId = ?", [NSNumber numberWithInt:category], [NSNumber numberWithInt:group]];
    while ([rs next]) {
        [array addObject:[rs stringForColumnIndex:0]];
    }
    return [NSArray arrayWithArray:array];
}

- (NSSet *)getUnmarkedWordsByCategory:(NSUInteger)category AndGroup:(NSUInteger)group
{
    NSMutableSet *s1 = [NSMutableSet set];
    NSMutableSet *s2 = [NSMutableSet set];
    FMDatabase *db = [FMDatabase databaseWithPath:self.bundleDbPath];
    [db open];
    FMResultSet *rs = [db executeQuery:@"SELECT ZSPELL FROM ZWORD WHERE ZCATEGORY = ? AND ZGROUP = ?", [NSNumber numberWithInt:category], [NSNumber numberWithInt:group]];
    while ([rs next]) {
        [s1 addObject:[rs stringForColumnIndex:0]];
    }
    [rs close];
    [db close];
    
    rs = [self.historyDatabase executeQuery:@"SELECT spell FROM history WHERE categoryId = ? AND groupId = ?", [NSNumber numberWithInt:category], [NSNumber numberWithInt:group]];
    while ([rs next]) {
        [s2 addObject:[rs stringForColumnIndex:0]];
    }
    [rs close];
    [s1 minusSet:s2];
    return s1;
}

@end