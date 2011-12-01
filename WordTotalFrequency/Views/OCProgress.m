//
//  OCProgress.m
//  ProgressView
//
//  Created by Brian Harmann on 7/24/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "OCProgress.h"


@implementation OCProgress

@synthesize  minValue, maxValue, currentValue;
@synthesize lineColor, progressRemainingColor, progressColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		minValue = 0;
		maxValue = 1;
		currentValue = 0;
		self.backgroundColor = [UIColor clearColor];
        lineWidth = 2;
		lineColor = [[UIColor whiteColor] retain];
		progressColor = [[UIColor darkGrayColor] retain];
		progressRemainingColor = [[UIColor lightGrayColor] retain];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(context, lineWidth);
	
	CGContextSetStrokeColorWithColor(context,[lineColor CGColor]);
	CGContextSetFillColorWithColor(context, [[progressRemainingColor colorWithAlphaComponent:.7] CGColor]);
    
	
	float radius = (rect.size.height / 2) - lineWidth;
	CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
    
	CGContextAddArcToPoint(context, lineWidth, lineWidth, radius + lineWidth, lineWidth, radius);
	CGContextAddLineToPoint(context, rect.size.width - radius - lineWidth, lineWidth);
	CGContextAddArcToPoint(context, rect.size.width - lineWidth, lineWidth, rect.size.width - lineWidth, rect.size.height / 2, radius);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, [progressRemainingColor CGColor]);
    
	CGContextMoveToPoint(context, rect.size.width - lineWidth, rect.size.height/2);
	CGContextAddArcToPoint(context, rect.size.width - lineWidth, rect.size.height - lineWidth, rect.size.width - radius - lineWidth, rect.size.height - lineWidth, radius);
	CGContextAddLineToPoint(context, radius + lineWidth, rect.size.height - lineWidth);
	CGContextAddArcToPoint(context, lineWidth, rect.size.height - lineWidth, lineWidth, rect.size.height/lineWidth, radius);
	CGContextFillPath(context);
	
	
	CGContextMoveToPoint(context, lineWidth, rect.size.height/2);
	
	CGContextAddArcToPoint(context, lineWidth, lineWidth, radius + lineWidth, lineWidth, radius);
	CGContextAddLineToPoint(context, rect.size.width - radius - lineWidth, lineWidth);
	CGContextAddArcToPoint(context, rect.size.width - lineWidth, lineWidth, rect.size.width - lineWidth, rect.size.height / lineWidth, radius);
	CGContextAddArcToPoint(context, rect.size.width - lineWidth, rect.size.height - lineWidth, rect.size.width - radius - lineWidth, rect.size.height - lineWidth, radius);
	
	CGContextAddLineToPoint(context, radius + lineWidth, rect.size.height - lineWidth);
	CGContextAddArcToPoint(context, lineWidth, rect.size.height - lineWidth, lineWidth, rect.size.height/2, radius);
	CGContextStrokePath(context);
	
	CGContextSetFillColorWithColor(context, [[progressColor colorWithAlphaComponent:.78] CGColor]);
    
	radius = radius - lineWidth;
	CGContextMoveToPoint(context, 2*lineWidth, rect.size.height/2);
	float amount = (currentValue/(maxValue - minValue)) * (rect.size.width);
	
	if (amount >= radius + 2*lineWidth && amount <= (rect.size.width - radius - 2*lineWidth)) {
		CGContextAddArcToPoint(context, 2*lineWidth, 2*lineWidth, radius + 2*lineWidth, 2*lineWidth, radius);
		CGContextAddLineToPoint(context, amount-radius, 2*lineWidth);
		//CGContextAddLineToPoint(context, amount, radius + 4);
		CGContextAddArcToPoint(context, amount + 2*lineWidth, 2*lineWidth,  amount + 2*lineWidth, rect.size.height/2, radius);
        
		CGContextFillPath(context);
		
		CGContextSetFillColorWithColor(context, [progressColor CGColor]);
		CGContextMoveToPoint(context, 2*lineWidth, rect.size.height/2);
		CGContextAddArcToPoint(context, 2*lineWidth, rect.size.height - 2*lineWidth, radius + 2*lineWidth, rect.size.height - 2*lineWidth, radius);
		CGContextAddLineToPoint(context, amount-radius, rect.size.height - 2*lineWidth);
		CGContextAddArcToPoint(context, amount + 2*lineWidth, rect.size.height - 2*lineWidth,  amount + 2*lineWidth, rect.size.height/2, radius);
		//CGContextAddLineToPoint(context, amount, radius + 4);
		CGContextFillPath(context);
	} else if (amount > radius + 2*lineWidth) {
		CGContextAddArcToPoint(context, 2*lineWidth, 2*lineWidth, radius + 2*lineWidth, 2*lineWidth, radius);
		CGContextAddLineToPoint(context, rect.size.width - radius - 2*lineWidth, 2*lineWidth);
		CGContextAddArcToPoint(context, rect.size.width - 2*lineWidth, 2*lineWidth, rect.size.width - 2*lineWidth, rect.size.height/2, radius);
		CGContextFillPath(context);
		
		CGContextSetFillColorWithColor(context, [progressColor CGColor]);
		CGContextMoveToPoint(context, 2*lineWidth, rect.size.height/2);
		CGContextAddArcToPoint(context, 2*lineWidth, rect.size.height - 2*lineWidth, radius + 2*lineWidth, rect.size.height - 2*lineWidth, radius);
		CGContextAddLineToPoint(context, rect.size.width - radius - 2*lineWidth, rect.size.height - 2*lineWidth);
		CGContextAddArcToPoint(context, rect.size.width - 2*lineWidth, rect.size.height - 2*lineWidth, rect.size.width - 2*lineWidth, rect.size.height/2, radius);
		CGContextFillPath(context);
	} else if (amount < radius + 2*lineWidth && amount > 0) {
		CGContextAddArcToPoint(context, 2*lineWidth, 2*lineWidth, radius + 2*lineWidth, 2*lineWidth, radius);
		CGContextAddLineToPoint(context, radius + 2*lineWidth, rect.size.height/2);
		CGContextFillPath(context);
		
		CGContextSetFillColorWithColor(context, [progressColor CGColor]);
		CGContextMoveToPoint(context, 2*lineWidth, rect.size.height/2);
		CGContextAddArcToPoint(context, 2*lineWidth, rect.size.height - 2*lineWidth, radius + 2*lineWidth, rect.size.height - 2*lineWidth, radius);
		CGContextAddLineToPoint(context, radius + 2*lineWidth, rect.size.height/2);
		CGContextFillPath(context);
	}
	
	
}

-(void)setNewRect:(CGRect)newFrame 
{
	self.frame = newFrame;
	[self setNeedsDisplay];
    
}

-(void)setMinValue:(float)newMin
{
	minValue = newMin;
	[self setNeedsDisplay];
    
}

-(void)setMaxValue:(float)newMax
{
	maxValue = newMax;
	[self setNeedsDisplay];
    
}

-(void)setCurrentValue:(float)newValue
{
	currentValue = newValue;
	[self setNeedsDisplay];
}

-(void)setLineColor:(UIColor *)newColor
{
	[newColor retain];
	[lineColor release];
	lineColor = newColor;
	[self setNeedsDisplay];
    
}

-(void)setProgressColor:(UIColor *)newColor
{
	[newColor retain];
	[progressColor release];
	progressColor = newColor;
	[self setNeedsDisplay];
    
}

-(void)setProgressRemainingColor:(UIColor *)newColor
{
	[newColor retain];
	[progressRemainingColor release];
	progressRemainingColor = newColor;
	[self setNeedsDisplay];
    
}

- (void)dealloc {
	[lineColor release];
	[progressColor release];
	[progressRemainingColor release];
    [super dealloc];
}


@end
