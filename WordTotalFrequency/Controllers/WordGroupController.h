//
//  WordGroupController.h
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordSetController.h"
#import "WordSet.h"
#import "WordGroup.h"

@interface WordGroupController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
}

@property (nonatomic, retain) WordSet *wordSet;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *groups;

@end