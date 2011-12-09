//
//  WordListCell.h
//  WordTotalFrequency
//
//  Created by Perry on 11-9-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"
#import "WordSetController.h"

@interface WordListCell : UITableViewCell {
    UIButton *_markIcon;
    UILabel *_spell;
    UILabel *_translate;
    
    CGPoint _lastHitPoint;
}

@property (nonatomic, retain) Word *word;

@property (nonatomic, assign) WordSetController *wordSetController;

@end
