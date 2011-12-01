//
//  UIColor+WTF.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIColor+WTF.h"


@implementation UIColor (WTF)

+ (UIColor *)colorWithHex:(NSUInteger)color
{
    return [UIColor colorWithHex:color alpha:1];
}

+ (UIColor *)colorWithHex:(NSUInteger)color alpha:(CGFloat)alpha
{
    unsigned char r, g, b;
    b = color & 0xFF;
    g = (color >> 8) & 0xFF;
    r = (color >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:alpha];
}

+ (UIColor *)colorForNormalText
{
    return [UIColor colorWithHex:0x45738e];
}

+ (UIColor *)colorForTheme
{
    return [UIColor colorWithRed:193.0/255 green:231.0/255 blue:1.0 alpha:1.0];
}


- (CGColorSpaceModel) colorSpaceModel  
{  
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));  
}

- (CGFloat) red  
{  
    const CGFloat *c = CGColorGetComponents(self.CGColor);  
    return c[0];  
}  

- (CGFloat) green  
{  
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];  
    return c[1];  
}  

- (CGFloat) blue  
{  
    const CGFloat *c = CGColorGetComponents(self.CGColor);  
    if ([self colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];  
    return c[2];  
}  

- (CGFloat) alpha  
{  
    const CGFloat *c = CGColorGetComponents(self.CGColor);  
    return c[CGColorGetNumberOfComponents(self.CGColor)-1];  
}  

@end
