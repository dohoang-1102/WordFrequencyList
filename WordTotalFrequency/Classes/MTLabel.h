//
//  MTLabel.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    
    MTLabelTextAlignmentLeft,
    MTLabelTextAlignmentCenter,
    MTLabelTextAlignmentRight,
    MTLabelTextAlignmentJustify
    
} MTLabelTextAlignment;


@interface MTLabel : UIView {
    
    int _numberOfLines;
    CGFloat _lineHeight;
    NSString *_text;
    UIColor *_fontColor;
    UIFont *_font;
    BOOL _limitToNumberOfLines;
    BOOL _shouldResizeToFit;
    MTLabelTextAlignment _textAlignment;
    
}

@property (nonatomic, readwrite, setter = setNumberOfLines:, getter = numberOfLines) int _numberOfLines;
@property (nonatomic, readwrite, setter = setLineHeight:, getter = lineHeight)    CGFloat _lineHeight;
@property (nonatomic, readonly) CGFloat _textHeight;
@property (nonatomic, retain, setter = setText:, getter = text) NSString *_text;
@property (nonatomic, retain, setter = setFontColor:, getter = fontColor) UIColor *_fontColor;
@property (nonatomic, retain, setter = setFont:, getter = font) UIFont *_font;
@property (nonatomic, readwrite, setter = setLimitToNumberOfLines:, getter = limitToNumberOfLines) BOOL _limitToNumberOfLines;
@property (nonatomic, readwrite, setter = setResizeToFitText:, getter = resizeToFitText) BOOL _shouldResizeToFit;
@property (nonatomic, readwrite, setter = setTextAlignment:, getter = textAlignment) MTLabelTextAlignment _textAlignment;

-(id)initWithFrame:(CGRect)frame andText:(NSString *)text;
-(id)initWithText:(NSString *)text;
+(id)label;
+(id)labelWithFrame:(CGRect)frame andText:(NSString *)text;
+(id)labelWithText:(NSString *)text;
-(void)setText:(NSString *)text;
-(void)setLineHeight:(CGFloat)lineHeight;
-(void)setNumberOfLines:(int)numberOfLines;
-(void)setFont:(UIFont *)font;
-(void)setFontColor:(UIColor *)fontColor;
-(void)setLimitToNumberOfLines:(BOOL)limitToNumberOfLines;
-(void)setTextAlignment:(MTLabelTextAlignment)textAlignment;
-(void)setResizeToFitText:(BOOL)resizeToFitText;
-(NSString *)text;
-(CGFloat)lineHeight;
-(UIColor *)fontColor;
-(UIFont *)font;
-(int)numberOfLines;
-(BOOL)limitToNumberOfLines;
-(BOOL)resizeToFitText;
-(MTLabelTextAlignment)textAlignment;


@end