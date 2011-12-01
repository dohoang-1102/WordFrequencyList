//
//  CustomSearchBar.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CustomSearchBar.h"
#import "UIColor+WTF.h"


@implementation CustomSearchBar

@synthesize searchBox = _searchBox;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView* segment = [self.subviews objectAtIndex:0];
        segment.alpha = 0;
        
        NSUInteger numViews = [self.subviews count];
        for(int i = 0; i < numViews; i++) {
            if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                _searchBox = [self.subviews objectAtIndex:i];
                
                _searchBox.textColor = [UIColor colorForNormalText];
                _searchBox.font = [UIFont systemFontOfSize:18.f];
                [_searchBox setBackground: [UIImage imageNamed:@"search-bg"] ];
                [_searchBox setBorderStyle:UITextBorderStyleNone];
                
            }
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
}
*/

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)resignFirstResponder
{
    [_searchBox setBackground:[UIImage imageNamed:@"search-bg"]];
    return [super resignFirstResponder];
}

@end
