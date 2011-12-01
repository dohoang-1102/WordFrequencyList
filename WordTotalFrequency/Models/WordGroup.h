//
//  WordGroup.h
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordGroup : NSObject{
    
}
@property (nonatomic) NSInteger totalWordCount;
@property (nonatomic, readonly) NSInteger markedWordCount;
@property (nonatomic) NSInteger intermediateMarkedWordCount;
@property (nonatomic) NSInteger completeMarkedWordCount;
@property (nonatomic, readonly) NSNumber *completePercentage;

@end
