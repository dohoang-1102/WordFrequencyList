//
//  WordDetailController.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
#import "WordListController.h"
#import "WordSetController.h"
#import "CustomSegmentedControl.h"

@interface WordDetailController : UIViewController<UIGestureRecognizerDelegate, CustomSegmentedControlDelegate> {
    UIView *_containerView;
    CustomSegmentedControl *_segmentedControl;
}

@property (nonatomic, retain) Word *word;
@property (nonatomic, retain) NSArray *words;
@property (nonatomic) NSInteger wordSetIndex;
@property (nonatomic) NSUInteger currentWordIndex;
@property (nonatomic, assign) WordSetController *wordSetController;
@property (nonatomic, assign) WordListController *wordListController;
@property (nonatomic) BOOL historyListDirty;
@property (nonatomic) BOOL navigatable;

- (void)updateMarkOnSegmented;

@end
