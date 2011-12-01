//
//  BriefView.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BriefView.h"
#import "UIColor+WTF.h"
#import "MTLabel.h"
#import "DataController.h"

@implementation BriefView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat top = 10;
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dashline-bg"]];
        bg.frame = CGRectMake(1, -11, 318, 35);
        [self addSubview:bg];
        [bg release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, top-2, 75, 48)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:40];
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor colorForNormalText];
        label.textAlignment = UITextAlignmentRight;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:label];
        [label release];
        _totalLabel = label;
        
        MTLabel *note = [[MTLabel alloc] initWithFrame:CGRectMake(85, top-2, 80, 60)];
        note.backgroundColor = [UIColor clearColor];
        note.font = [UIFont systemFontOfSize:13];
        note.numberOfLines = 0;
        note.text = @"个单词\n被标记为\n(熟悉/记住)了";
        [note setFontColor:[UIColor colorForNormalText]];
        [note setLineHeight:14];
        note.textAlignment = MTLabelTextAlignmentLeft;
        [self addSubview:note];
        [note release];
        
        UIImage *image = [UIImage imageNamed:@"check-mark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(155, 0, image.size.width, image.size.height);
        [self addSubview:imageView];
        [imageView release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(200, 24+top, 50, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor colorForNormalText];
        label.text = @"Level:";
        [self addSubview:label];
        [label release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(250, 6+top, 80, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:34];
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor colorForNormalText];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:label];
        [label release];
        _levelLabel = label;
        
    }
    return self;
}

- (void)updateTotalMarkedCount:(NSUInteger)total
{
    _totalLabel.text = [NSString stringWithFormat:@"%d", total];
    NSArray* levelList = [[DataController sharedDataController] getLevelList];
    
    NSString *level = @"0";
    
    for (int i=0; i<levelList.count; i++) {
        NSNumber *v = [levelList objectAtIndex:i] ;
        if (total<[v intValue]) {
            level = [NSString stringWithFormat:@"%d", i];
            break;
        }
    }
    _levelLabel.text = level;
}

- (void)dealloc
{
    [super dealloc];
}

@end
