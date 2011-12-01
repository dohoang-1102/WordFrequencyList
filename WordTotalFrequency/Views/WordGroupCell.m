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

@synthesize ownerTable  = _ownerTable;
@synthesize wordGroup   = _word;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect rect = self.bounds;
        
        self.backgroundView         = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"word-group-bg"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"word-group-bg"]];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 30, 30)];
        _idLabel.backgroundColor    = [UIColor clearColor];
        _idLabel.adjustsFontSizeToFitWidth = YES;
        _idLabel.textColor          = [UIColor colorForNormalText];
        _idLabel.font               = [UIFont systemFontOfSize:22];
        _idLabel.shadowColor        = [UIColor whiteColor];
        _idLabel.shadowOffset       = CGSizeMake(.5, 1);
        [self addSubview:_idLabel];
        _idLabel.text = @"1.";
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 175, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor       = [UIColor colorForNormalText];
        _titleLabel.font            = [UIFont systemFontOfSize:16];
        _titleLabel.shadowColor     = [UIColor whiteColor];
        _titleLabel.shadowOffset    = CGSizeMake(.5, 1);
        [self addSubview:_titleLabel];
        _titleLabel.text = @"第 200 - 400 个单词";
        
       
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 12, 60, 30)];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.adjustsFontSizeToFitWidth = YES;
        _percentLabel.textColor       = [UIColor colorForNormalText];
        _percentLabel.font            = [UIFont systemFontOfSize:16];
        _percentLabel.shadowColor     = [UIColor whiteColor];
        _percentLabel.shadowOffset    = CGSizeMake(.5, 1);
        _percentLabel.textAlignment   = UITextAlignmentRight;
        [self addSubview:_percentLabel];
        _percentLabel.text = @"35%";
        
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
