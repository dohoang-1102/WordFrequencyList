//
//  CustomProgress.m
//  WordTotalFrequency
//
//  Created by Perry on 11-9-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CustomProgress.h"


@implementation CustomProgress

@synthesize currentValue = _currentValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backImage = [[UIImage imageNamed:@"progress-bg"] stretchableImageWithLeftCapWidth:6 topCapHeight:6];
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), backImage.size.height);
        
        UIImageView *back = [[UIImageView alloc] initWithFrame:rect];
        back.image = backImage;
        [self addSubview:back];
        [back release];
        
        _percentImage = [[UIImageView alloc] init];
        [self addSubview:_percentImage];
    }
    return self;
}

- (void)setImageName:(NSString *)imageName
{
    [_percentImage setImage:[[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:6 topCapHeight:6]];
}

-(void)setCurrentValue:(float)newValue
{
	_currentValue = newValue;
	[self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float w = 0;
    if (_currentValue > 0)
    {
        w = CGRectGetWidth(self.bounds) * MIN(_currentValue, 100) / 100.0;
        if (w < 12)
            w = 12;
    }
    [_percentImage setFrame:CGRectMake(0, -0.5, w, 12)];
}

- (void)dealloc
{
    [_percentImage release];
    [super dealloc];
}

@end
