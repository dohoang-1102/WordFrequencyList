//
//  WordTotalFrequencyAppDelegate.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordTotalFrequencyAppDelegate.h"
#import "DashboardController.h"
#import "Common.h"
#import "UIColor+WTF.h"
#import "Word.h"
#import "DataController.h"

@implementation WordTotalFrequencyAppDelegate


@synthesize window=_window;
@synthesize navigationController=_navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    DashboardController *dc = [[DashboardController alloc] init];
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:dc];
    _navigationController.navigationBar.tintColor = [UIColor colorWithHex:0x3A3A65];
    [dc release];
    self.window.rootViewController = self.navigationController;
    
//    [[DataController sharedDataController] saveFromSource:@"save data free sqlite"];
    
    [self.window makeKeyAndVisible];
    
    
    application.applicationIconBadgeNumber = 0;
    
    // Handle launching from a notification
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        NSLog(@"Recieved Notification %@",localNotif);
    }
    
    [[DataController sharedDataController] incrementAppLoadedTimes];
    
    [MobClick setDelegate:self reportPolicy:BATCH];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if ([[[DataController sharedDataController] managedObjectContext] hasChanges]) {
		[[DataController sharedDataController] saveFromSource:@"application will terminate"];
	}
    [[DataController sharedDataController].historyDatabase close];
    
    // local notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[DataController sharedDataController] scheduleNextWord];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // local notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[DataController sharedDataController] scheduleNextWord];
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (NSString *)appKey
{
    NSString *appkey = [[DataController sharedDataController].settingsDictionary objectForKey:@"AppKey"];
    if (!appkey)
        appkey = @"4f38d35852701553e9000029";
    return appkey;
}

@end
