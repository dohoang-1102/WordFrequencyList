//
//  UnitIconView.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UnitIconView.h"
#import "UIColor+WTF.h"

@interface UnitIconView()

- (void)drawPathWithArc:(CGFloat)arc;

@end

@implementation UnitIconView

@synthesize imageLayer = _imagelayer;
@synthesize circleLayer = _circleLayer;
@synthesize percentLayer = _percentLayer;
@synthesize dashboard = _dashboard;
@synthesize wordSet = _wordSet;
@synthesize percentArc = _percentArc;
@synthesize index = _index;

const float INSET_OFFSET = 4;

- (id)initWithFrame:(CGRect)frame image:(NSString *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        rect = CGRectInset(rect, INSET_OFFSET, INSET_OFFSET);
        
        _circleLayer = [[CAShapeLayer alloc] init];
        _circleLayer.bounds = rect;
        _circleLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        _circleLayer.strokeColor = [UIColor colorWithHex:0xb3d7ef].CGColor;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.lineWidth = 4.f;
        CGMutablePathRef thePath = CGPathCreateMutable();
        CGPathAddArc(thePath,
                     NULL,
                     CGRectGetMidX(rect),
                     CGRectGetMidY(rect),
                     CGRectGetWidth(rect)/2.0,
                     0,
                     2*M_PI,
                     NO);
        _circleLayer.path = thePath;
        CGPathRelease(thePath);
        [self.layer addSublayer:_circleLayer];
        
        _percentLayer = [[CAShapeLayer alloc] init];
        _percentLayer.bounds = rect;
        _percentLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        _percentLayer.strokeColor = [UIColor colorWithHex:0x45738e].CGColor;
        _percentLayer.fillColor = [UIColor clearColor].CGColor;
        _percentLayer.lineWidth = 4.f;
        [self.layer addSublayer:_percentLayer];
        
        _imagelayer = [[CALayer alloc] init];
        _imagelayer.frame = CGRectInset(rect, 2, 2);
        _imagelayer.contents = (id)[UIImage imageNamed:image].CGImage;
        [self.layer addSublayer:_imagelayer];
        
        // Tap Gesture
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(iconTapped:)];
        [self addGestureRecognizer:gesture];
        [gesture release];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePath:)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)setWordSet:(WordSet *)wordSet
{
    if (_wordSet != wordSet)
    {
        _wordSet = wordSet;
        _percentArc = [wordSet.completePercentage floatValue]  * 2 * M_PI / 100.f -  M_PI / 2;
    }
}

- (void)updateData
{
    _percentArc = [_wordSet.completePercentage floatValue]  * 2 * M_PI / 100.f -  M_PI / 2;
}

- (void)addCADisplayLink
{
    _displayLink.paused = NO;
    _currentArc = -M_PI/2;
    [self drawPathWithArc:_currentArc];
}

- (void)drawPathWithArc:(CGFloat)arc
{
    CGRect rect = CGRectInset(self.bounds, INSET_OFFSET, INSET_OFFSET);
    _percentLayer.path = nil;
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathAddArc(thePath,
                 NULL,
                 CGRectGetMidX(rect),
                 CGRectGetMidY(rect),
                 CGRectGetWidth(rect)/2.0,
                 -M_PI/2,
                 arc,
                 NO);
    _percentLayer.path = thePath;
    CGPathRelease(thePath);
}

- (void)updatePath:(CADisplayLink *)displayLink {
    CGFloat delta = (_percentArc + M_PI / 2) / 20;
    _currentArc = fminf(_currentArc + delta, _percentArc);
    [self drawPathWithArc:_currentArc];
    if (_currentArc >= _percentArc) {
        _displayLink.paused = YES;
    }
}

- (void)dealloc
{
    [_displayLink invalidate];
    
    [_imagelayer release];
    [_circleLayer release];
    [_percentLayer release];
    [super dealloc];
}
                                           
- (void)iconTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self toggleDisplayState:self affectDashboard:YES];
}

- (void)toggleDisplayState:(UnitIconView *)iconView affectDashboard:(BOOL)affect
{
    // toggle previous selected
    if (_dashboard.selectedIconIndex > -1 && affect)
    {
        if (_dashboard.selectedIconIndex != _index){
            UnitIconView *icon = [_dashboard.unitIcons objectAtIndex:_dashboard.selectedIconIndex];
            [icon toggleDisplayState:icon affectDashboard:NO];
        }
        else{
            _dashboard.selectedIconIndex = -1;
            return;
        }
    }
    
    // toggle self
    if (_isSelected)
    {
        _imagelayer.transform = CATransform3DIdentity;
        [self performSelector:@selector(addCADisplayLink) withObject:nil afterDelay:0];
    }
    else
    {
        CATransform3D currentTransform = _imagelayer.transform;
        CATransform3D scaled = CATransform3DScale(currentTransform, 1.43, 1.43, 1.43);
        _imagelayer.transform = scaled;
        
        // set selectedIconIndex
        if (affect)
        {
            for (int i=0; i<[_dashboard.unitIcons count]; i++) {
                UnitIconView *view = [_dashboard.unitIcons objectAtIndex:i];
                if (view == self)
                {
                    _dashboard.selectedIconIndex = i;
                    break;
                }
            }
        }
    }
    _isSelected = !_isSelected;
}
@end
