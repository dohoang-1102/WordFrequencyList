//
//  WordGroupController.h
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordSetController.h"
#import "WordGroupListController.h"

@interface WordGroupController : UIViewController{
    WordGroupListController *_groupListController;
}

@property (nonatomic, retain) WordSet *wordSet;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (nonatomic, retain) UIView *viewContainer;


@end


