//
//  WordGroup.m
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WordGroup.h"

@implementation WordGroup

@synthesize startNumber = _startNumber;
@synthesize totalWordCount = _totalWordCount;
@synthesize markedWordCount = _markedWordCount;
@synthesize intermediateMarkedWordCount = _intermediateMarkedWordCount;
@synthesize completeMarkedWordCount = _completeMarkedWordCount;
@synthesize completePercentage = _completePercentage;
@synthesize categoryId = _categoryId;
@synthesize groupId = _groupId;


-  (NSUInteger)markedWordCount
{
    return _intermediateMarkedWordCount + _completeMarkedWordCount;
}

- (float)completePercentage
{
    if (_totalWordCount <= 0)
        return 0;
    else
        return self.markedWordCount * 100.f / _totalWordCount;
}

@end