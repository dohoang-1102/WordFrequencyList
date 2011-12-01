//
//  WordDetailView.h
//  WordTotalFrequency
//
//  Created by Perry on 11-8-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Word.h"
#import "WordDetailController.h"

@interface WordDetailView : UIView {
}

@property (nonatomic, retain) Word *word;
@property (nonatomic, assign) WordDetailController *wordDetailController;
@property (nonatomic, retain) AVAudioPlayer *player;

- (void)updateWordData;
- (void)playWordSpeech;
- (void)markAction:(UIGestureRecognizer *)gestureRecognizer;

@end
