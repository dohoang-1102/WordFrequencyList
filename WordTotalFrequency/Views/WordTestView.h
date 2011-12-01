//
//  WordTestView.h
//  WordTotalFrequency
//
//  Created by Perry on 11-8-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "WordPaperView.h"

@class WordSetController;

@interface WordTestView : UIView<UIGestureRecognizerDelegate> {
    UIView *_containerView;
    WordPaperView *_paperView;
}

@property (nonatomic, assign) WordSetController *wordSetController;
@property (nonatomic, retain) AVAudioPlayer *player;

- (void)previousTestWord;
- (void)nextTestWord;
- (void)playWordSound:(Word*)word;

@end
