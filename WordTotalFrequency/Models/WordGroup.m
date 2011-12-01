//
//  WordGroup.m
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WordGroup.h"

@implementation WordGroup

@synthesize totalWordCount = _totalWordCount;
@synthesize markedWordCount = _markedWordCount;
@synthesize intermediateMarkedWordCount = _intermediateMarkedWordCount;
@synthesize completeMarkedWordCount = _completeMarkedWordCount;
@synthesize completePercentage = _completePercentage;


-  (NSInteger)markedWordCount
{
    return _intermediateMarkedWordCount + _completeMarkedWordCount;
}

- (NSNumber*)completePercentage
{
    if (_totalWordCount <= 0)
        return 0;
    else
        return [NSNumber numberWithFloat: self.markedWordCount * 100.f / _totalWordCount ];
}

@end
