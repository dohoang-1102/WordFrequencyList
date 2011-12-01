//
//  WordGroupCell.h
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordGroup.h"


@interface WordGroupCell : UITableViewCell{
    UILabel *_idLabel;
    UILabel *_titleLabel;
    UILabel *_percentLabel;
}

@property (nonatomic, retain) WordGroup *wordGroup;
@property (nonatomic, assign) UITableView *ownerTable;

@end
