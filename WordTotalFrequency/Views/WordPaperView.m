//
//  WordPaperView.m
//  WordTotalFrequency
//
//  Created by Perry on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordPaperView.h"
#import "UIColor+WTF.h"
#import "DataController.h"

#define MARK_ICON_TAG 11
#define SPELL_LABEL_TAG 22


@interface WordPaperView ()
- (void)updateMark;
@end

@implementation WordPaperView

@synthesize word = _word;

- (void)updateMark
{
    int status = [[DataController sharedDataController] getMarkStatusBySpell:_word.spell];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"mark-circle-%d", status]];
    [(UIButton *)[self viewWithTag:MARK_ICON_TAG] setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)choiceTapped:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    int tapIndex = -1;
    for (int i=0; i<4; i++)
    {
        UILabel *label = (UILabel *)[self viewWithTag:(i+1)*10];
        if (CGRectContainsPoint(label.frame, point))
        {
            tapIndex = i;
            break;
        }
        
        UILabel *option = (UILabel *)[self viewWithTag:i+1];
        if (CGRectContainsPoint(option.frame, point))
        {
            tapIndex = i;
            break;
        }
    }
    
    if (tapIndex > -1)
    {
        if (tapIndex != _answerIndex)
        {
            UIView *tappedView = [self viewWithTag:(tapIndex+1)*10];
            UIImageView *wrong = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark-circle-wrong"]];
            wrong.center = CGPointMake(CGRectGetMinX(tappedView.frame), CGRectGetMidY(tappedView.frame));
            CGSize size = CGSizeMake(CGRectGetWidth(wrong.bounds), CGRectGetHeight(wrong.bounds));
            CGAffineTransform scaled = CGAffineTransformMakeScale(1/size.width, 1/size.height);
            wrong.transform = scaled;
            
            [UIView animateWithDuration:.2
                                  delay:0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^{
                                 [self addSubview:wrong];
                                 wrong.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){}];
            [wrong release];
        }
        
        UIView *rightView = [self viewWithTag:(_answerIndex+1)*10];
        UIImageView *right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark-circle-right"]];
        right.center = CGPointMake(CGRectGetMinX(rightView.frame), CGRectGetMidY(rightView.frame));
        CGSize size = CGSizeMake(CGRectGetWidth(right.bounds), CGRectGetHeight(right.bounds));
        CGAffineTransform scaled = CGAffineTransformMakeScale(1/size.width, 1/size.height);
        right.transform = scaled;
        
        [UIView animateWithDuration:.2
                              delay:(tapIndex != _answerIndex ? .2 : 0)
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             [self addSubview:right];
                             right.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished){}];
        [right release];
        
        [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
        
        // update mark status
        int currentStatus = [[DataController sharedDataController] getMarkStatusBySpell:_word.spell];
        if (tapIndex == _answerIndex){
            if (currentStatus < 2){
                [[DataController sharedDataController] markWord:_word status:currentStatus+1];
                [self updateMark];
            }
        }
        else{
            if (currentStatus > 0){
                [[DataController sharedDataController] markWord:_word status:currentStatus-1];
                [self updateMark];
            }
        }
    }
}

- (id)initWithFrame:(CGRect)frame word:(Word *)word options:(NSArray *)options answer:(NSUInteger)answer footer:(NSString *)footer testView:(WordTestView *)testView
{
    self = [super initWithFrame:frame];
    if (self) {
        _answerIndex = answer;
        _wordTestView = testView;
        self.word = word;
        
        UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 38, 38)];
        [left setImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
        [left setImage:[UIImage imageNamed:@"arrow-left-pressed"] forState:UIControlStateHighlighted];
        [left addTarget:_wordTestView action:@selector(previousTestWord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:left];
        [left release];
        
        UIButton *mark = [UIButton buttonWithType:UIButtonTypeCustom];
        mark.frame = CGRectMake(58, 30, 12, 13);
        mark.tag = MARK_ICON_TAG;
        mark.userInteractionEnabled = NO;
        [self addSubview:mark];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(76, 20, CGRectGetWidth(frame)-136, 30)];
        label.tag = SPELL_LABEL_TAG;
        label.font = [UIFont boldSystemFontOfSize:28];
        label.text = word.spell;
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        UIButton *right = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-15-38, 15, 38, 38)];
        [right setImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
        [right setImage:[UIImage imageNamed:@"arrow-right-pressed"] forState:UIControlStateHighlighted];
        [right addTarget:_wordTestView action:@selector(nextTestWord) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:right];
        [right release];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 77, CGRectGetWidth(frame), CGRectGetHeight(frame)-77-20)];
        [self addSubview:container];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(choiceTapped:)];
        [container addGestureRecognizer:gesture];
        [gesture release];
        
        UILabel *number, *option;
        int y = 77;
        for (int i=0; i<[options count]; i++) {
            number = [[UILabel alloc] initWithFrame:CGRectMake(18, y, 20, 30)];
            number.tag = (i+1)*10;
            number.font = [UIFont systemFontOfSize:27];
            number.textAlignment = UITextAlignmentLeft;
            number.textColor = [UIColor colorWithHex:0x0b76b4];
            number.text = [NSString stringWithFormat:@"%d", i+1];
            [self addSubview:number];
            [number release];
            
            option = [[UILabel alloc] initWithFrame:CGRectMake(44, y, CGRectGetWidth(frame)-44, 30)];
            option.tag = i+1;
            option.font = [UIFont systemFontOfSize:17];
            option.textColor = [UIColor colorForNormalText];
            option.text = [options objectAtIndex:i];
            option.numberOfLines = 0;
            [self addSubview:option];
            
            CGSize maximumSize = CGSizeMake(CGRectGetWidth(option.frame), 9999);
            CGSize size = [option.text sizeWithFont:option.font constrainedToSize:maximumSize lineBreakMode:option.lineBreakMode];
            CGRect optFrame = option.frame;
            optFrame = CGRectMake(CGRectGetMinX(optFrame), CGRectGetMinY(optFrame), CGRectGetWidth(optFrame), size.height);
            option.frame = optFrame;
            
            [option release];
            
            y += MAX(40, CGRectGetHeight(optFrame)+18);
        }
        
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)-20, CGRectGetWidth(frame)-5, 20)];
        footerLabel.textColor = [UIColor grayColor];
        footerLabel.font = [UIFont systemFontOfSize:14];
        footerLabel.text = footer;
        footerLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:footerLabel];
        [footerLabel release];
        
        [container release];
        
        
        /**********************
         *** adjust postion ***
         **********************/
        CGRect frame = label.frame;
        CGSize size = [label.text sizeWithFont:label.font
                             constrainedToSize:frame.size
                                 lineBreakMode:label.lineBreakMode];
        if (size.width < frame.size.width){
            float delta = (frame.size.width - size.width)/2.0f;
            frame.origin = CGPointMake(frame.origin.x + delta, frame.origin.y);
            label.frame = frame;
            
            frame = mark.frame;
            frame.origin = CGPointMake(frame.origin.x + delta, frame.origin.y);
            mark.frame = frame;
        }
        [self updateMark];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [_word release];
    [super dealloc];
}

@end
