//
//  WordTotalFrequencyAppDelegate.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MobClick.h"

@interface WordTotalFrequencyAppDelegate : NSObject <UIApplicationDelegate, MobClickDelegate> {
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end
