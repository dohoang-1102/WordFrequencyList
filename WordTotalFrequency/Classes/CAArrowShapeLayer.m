//
//  CAArrowShapeLayer.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CAArrowShapeLayer.h"
#import "UIColor+WTF.h"


@implementation CAArrowShapeLayer

@synthesize strokeColor = _strokeColor;
@synthesize arrowAreaColor = _arrowAreaColor;

- (id)init
{
    if ((self = [super init]))
    {
        _strokeColor = [[UIColor colorWithHex:0xed9f1e] retain];
    }
    return self;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (strokeColor != _strokeColor)
    {
        [_strokeColor release];
        _strokeColor = [strokeColor retain];
        [self setNeedsDisplay];
    }
}

- (void)setArrowAreaColor:(UIColor *)arrowAreaColor
{
    if (arrowAreaColor != _arrowAreaColor)
    {
        [_arrowAreaColor release];
        _arrowAreaColor = [arrowAreaColor retain];
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {[_arrowAreaColor red], [_arrowAreaColor green], [_arrowAreaColor blue], 1,  // Start color
        [_arrowAreaColor red], [_arrowAreaColor green], [_arrowAreaColor blue], 1}; // End color
    
	
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), 9.5);
    

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 9.5);
    CGPathAddLineToPoint(path, NULL, 295.5, 9.5);
    CGPathAddLineToPoint(path, NULL, 300, 0);
    CGPathAddLineToPoint(path, NULL, 304.5, 9.5);
    CGPathAddLineToPoint(path, NULL, 600, 9.5);
    CGPathAddLineToPoint(path, NULL, 600, 900);
    CGPathAddLineToPoint(path, NULL, 0, 900);
    CGPathCloseSubpath(path);
    
    CGContextSetLineWidth(ctx, 1.f);
    CGContextSetStrokeColorWithColor(ctx, _strokeColor.CGColor);
    
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathStroke);

    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGPathRelease(path);

    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

- (void)dealloc
{
    [_strokeColor release];
    [_arrowAreaColor release];
    [super dealloc];
}

@end
