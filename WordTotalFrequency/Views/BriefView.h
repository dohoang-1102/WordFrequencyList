//
//  BriefView.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BriefView : UIView {
    UILabel *_totalLabel;
    UILabel *_levelLabel;
}

- (void)updateTotalMarkedCount:(NSUInteger)total;


@end
