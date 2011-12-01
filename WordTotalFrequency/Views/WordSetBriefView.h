//
//  WordSetBriefView.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MTLabel.h"
#import "WordSet.h"
#import "DashboardController.h"
#import "CAArrowShapeLayer.h"
#import "CustomProgress.h"

@interface WordSetBriefView : UIView<UITableViewDelegate, UITableViewDataSource> {
    UILabel *_countlabel;
    MTLabel *_countNoteLabel;
    UILabel *_percentLabel;
    CustomProgress *_progress;
    CAArrowShapeLayer *_arrowLayer;
    UIImageView *_backgroundImage;
    
    WordSet *_wordSet;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) WordSet *wordSet;

- (void)centerArrowToX:(CGFloat)x;
- (void)updateDisplay;
- (void)fadeSelectedBackground;

@end
