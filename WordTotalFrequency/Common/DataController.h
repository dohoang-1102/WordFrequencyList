//
//  DataController.h
//  CoreDataLibrary
//
//  
//  Copyright 2010 Eric Peter. 
//  Released under the GPL v3 License
//
//  code.google.com/p/coredatalibrary

//  Based from Apple's provided Navigation-Controller CoreData template

#import "NSManagedObjectContext+insert.h"
#import "Word.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


#define MANAGED_OBJECT_CONTEXT [[DataController sharedDataController] managedObjectContext]
#define SQL_DATABASE_NAME @"WordFrequencyList"

@interface DataController : NSObject<UIAlertViewDelegate> {
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;	    
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    
    FMDatabase *_historyDatabase;
}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) FMDatabase *historyDatabase;

@property (nonatomic, readonly) NSDictionary *settingsDictionary;
@property (nonatomic, readonly) NSString *bundleDbPath;
@property (nonatomic, readonly) NSString *docHistoryPath;
@property (nonatomic, readonly) NSString *AppID;
@property (nonatomic, getter = isNoticationOn) BOOL notificationOn;
@property (nonatomic, getter = isDetailPageAutoSpeakOn) BOOL detailPageAutoSpeakOn;

/**
 Print a log message and exit the application.  Called whenever a CoreData related method fails.
 @parm error NSError object describing the issue
 @param sourceString NSString describing where in code it was called from
 */
- (void) handleError:(NSError *)error fromSource:(NSString *)sourceString;

/** 
 Save the ManagedObjectContext
 @param source String describing where in code the save takes place
 */
- (void) saveFromSource:(NSString *)source;

- (NSString *)applicationDocumentsDirectory;

/**
 Singleton accessor 
 */
+ (DataController *)sharedDataController;

- (NSArray*)getLevelList;

- (void)markWord:(Word *)word status:(NSUInteger)status;

- (int)markWordToNextLevel:(Word *)word;

- (NSDictionary *)dictionaryForCategoryId:(NSUInteger)categoryId;

- (void)saveSettingsDictionary;

- (void)scheduleNextWord;

- (void)incrementAppLoadedTimes;

- (int)getMarkStatusBySpell:(NSString *)spell;
- (int)getMarkCountByCategory:(NSUInteger)category AndStatus:(NSUInteger)status;
- (int)getMarkCountByCategory:(NSUInteger)category AndGroup:(NSUInteger)group AndStatus:(NSUInteger)status;
- (NSArray *)getMarkedWordsByCategory:(NSUInteger)category AndGroup:(NSUInteger)group;
- (NSSet *)getUnmarkedWordsByCategory:(NSUInteger)category AndGroup:(NSUInteger)group;

@end
