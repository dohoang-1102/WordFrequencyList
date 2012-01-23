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
        
        [db executeUpdate:@"CREATE TABLE history (spell VARCHAR(255) PRIMARY KEY, markComplete INTEGER, markDate VARCHAR(255), categoryId INTEGER, groupId INTEGER)"];
        [db executeUpdate:@"CREATE INDEX history_spell_index ON history (spell)"];
        [db executeUpdate:@"CREATE INDEX history_markDate_index ON history (markDate)"];
        [db executeUpdate:@"CREATE INDEX history_categoryId_index ON history (categoryId)"];
        [db executeUpdate:@"CREATE INDEX history_groupId_index ON history (groupId)"];
        [db close];
        
        [pool release];
    }
}

- (void)migrateObsoleteDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbInDoc = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent: SQL_DATABASE_NAME] stringByAppendingString:@".sqlite"];
	// If there is db under document, migrate history data
	if (![fileManager fileExistsAtPath:dbInDoc]) {
		return;
	}
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // get mark history from obsolete word table, store in array
    FMDatabase *db = [FMDatabase databaseWithPath:dbInDoc];
    if (![db open]){
        [pool release];
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet *rs = [db executeQuery:@"SELECT ZSPELL, ZMARKSTATUS, ZMARKDATE, ZCATEGORY, ZGROUP FROM ZWORD WHERE ZMARKDATE <> ''"];
    while ([rs next]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [rs stringForColumn:@"ZSPELL"], @"spell",
                              [NSNumber numberWithInt:[rs intForColumn:@"ZMARKSTATUS"]-1], @"markComplete",
                              [rs stringForColumn:@"ZMARKDATE"], @"markDate",
                              [NSNumber numberWithInt:[rs intForColumn:@"ZCATEGORY"]], @"category",
                              [NSNumber numberWithInt:[rs intForColumn:@"ZGROUP"]], @"group", nil];
        [array addObject:dict];
    }
    [rs close];
    [db close];
    
    // remove document db
    [fileManager removeItemAtPath:dbInDoc error:NULL];
    
    // insert mark history from array into history table
    db = [FMDatabase databaseWithPath:self.docHistoryPath];
    if (![db open]){
        [pool release];
        [array release];
        return;
    }
    
    [db beginTransaction];
    for (NSDictionary *dict in array) {
        [db executeUpdate:@"INSERT INTO history VALUES (?, ?, ?, ?, ?)",
         [dict objectForKey:@"spell"],
         [dict objectForKey:@"markComplete"],
         [dict objectForKey:@"markDate"],
         [dict objectForKey:@"category"],
         [dict objectForKey:@"group"]];
    }
    [db commit];
    [db close];
    
    [array release];
    [pool release];
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
	

//    NSString *p = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Word.sqlite"];
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
    [self migrateObsoleteDatabase];
    
    // check plist file version
    NSDictionary *dict = [DataUtil readDictionaryFromBundleFile:@"WordSets"];
    int bundleVersion = [[dict objectForKey:@"Version"] intValue];
    BOOL needMigrate = NO;
    if (![self.settingsDictionary.allKeys containsObject:@"Version"]){
        needMigrate = YES;
    }
    else{
        int docVersion = [[self.settingsDictionary objectForKey:@"Version"] intValue];
//        NSLog(@"bunder ver:%d, document ver:%d", bundleVersion, docVersion);
        if (bundleVersion > docVersion){
            [self.settingsDictionary setValue:[NSNumber numberWithInt:bundleVersion] forKey:@"Version"];
            needMigrate = YES;
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark CDLC Save

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
    NSUInteger k = 0;
    int status = [self getMarkStatusBySpell:word.spell];
    switch (status) {
        case 0:
            k = 1;
            break;
        case 1:
            k = 2;
            break;
        case 2:
            k = 0;
            break;
    }
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
    sqlite3 *database;
    if (sqlite3_open([self.bundleDbPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql = @"SELECT ZSPELL, ZCATEGORY FROM ZWORD WHERE ZMARKSTATUS=0 ORDER BY ZRANK DESC LIMIT 0, 1";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                nextWord = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            }
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"failed open db");
    }
    sqlite3_close(database);
    database = NULL;
    
    if (nextWord == @"")
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
        NSString *reviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=481628150";
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