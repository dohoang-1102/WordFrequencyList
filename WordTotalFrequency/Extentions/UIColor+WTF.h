//
//  UIColor+WTF.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (WTF)

// takes #FF00FF
+ (UIColor *)colorWithHex:(NSUInteger)color;
+ (UIColor *)colorWithHex:(NSUInteger)color alpha:(CGFloat)alpha;

+ (UIColor *)colorForNormalText;

+ (UIColor *)colorForTheme;

- (CGColorSpaceModel) colorSpaceModel;

- (CGFloat) red;
- (CGFloat) green;
- (CGFloat) blue;
- (CGFloat) alpha;

@end
