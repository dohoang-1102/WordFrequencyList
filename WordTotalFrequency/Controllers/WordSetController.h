//
//  WordSetController.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordListController.h"
#import "WordGroup.h"
#import "WordTestView.h"
#import "SettingsView.h"
#import "CustomSegmentedControl.h"

@class WordListController;

@interface WordSetController : UIViewController<CustomSegmentedControlDelegate> {
    WordListController *_listController;
    WordListController *_historyController;
    CustomSegmentedControl *_segmentedControl;
    
    NSArray *_testingWords;
}

@property (nonatomic, retain) UIView *viewContainer;
@property (nonatomic, retain) WordGroup *wordGroup;
@property (nonatomic, readonly) NSArray *testingWords;
@property (nonatomic, readonly) NSArray *listingWords;
@property (nonatomic) NSUInteger currentTestWordIndex;

@property (nonatomic, readonly) NSUInteger selectedViewIndex;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;

@property (nonatomic, retain, readonly) WordTestView *wordTestView;
@property (nonatomic, retain, readonly) UIView *historyView;
@property (nonatomic, retain, readonly) SettingsView *settingsView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedWordResultsController;

@end
