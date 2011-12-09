//
//  WordGroupCell.m
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WordGroupCell.h"
#import "UIColor+WTF.h"
@implementation WordGroupCell

@synthesize wordGroup   = _wordGroup;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView         = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"word-group-bg"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"word-group-bg"]];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 30, 30)];
        _idLabel.backgroundColor    = [UIColor clearColor];
        _idLabel.adjustsFontSizeToFitWidth = YES;
        _idLabel.textColor          = [UIColor colorForNormalText];
        _idLabel.font               = [UIFont systemFontOfSize:20];
        _idLabel.shadowColor        = [UIColor whiteColor];
        _idLabel.shadowOffset       = CGSizeMake(.5, 1);
        [self addSubview:_idLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 12, 175, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor       = [UIColor colorForNormalText];
        _titleLabel.font            = [UIFont systemFontOfSize:16];
        _titleLabel.shadowColor     = [UIColor whiteColor];
        _titleLabel.shadowOffset    = CGSizeMake(.5, 1);
        [self addSubview:_titleLabel];
        
       
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 12, 60, 30)];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.adjustsFontSizeToFitWidth = YES;
        _percentLabel.textColor       = [UIColor colorForNormalText];
        _percentLabel.font            = [UIFont systemFontOfSize:16];
        _percentLabel.shadowColor     = [UIColor whiteColor];
        _percentLabel.shadowOffset    = CGSizeMake(.5, 1);
        _percentLabel.textAlignment   = UITextAlignmentRight;
        [self addSubview:_percentLabel];
        
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    return self;
}

- (void)setWordGroup:(WordGroup *)wordGroup
{
    if (_wordGroup != wordGroup) {
        [_wordGroup release];
        _wordGroup = [wordGroup retain];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _idLabel.text = [NSString stringWithFormat:@"%d.", _wordGroup.groupId + 1];
    _titleLabel.text = [NSString stringWithFormat:@"第 %d - %d 个单词", _wordGroup.startNumber, _wordGroup.startNumber+_wordGroup.totalWordCount-1];
    _percentLabel.text = [NSString stringWithFormat:@"%.1f%%", _wordGroup.completePercentage];
}

- (void)dealloc
{
    [_wordGroup release];
    [_idLabel release];
    [_titleLabel release];
    [_percentLabel release];
    
    [super dealloc];
}

@end
