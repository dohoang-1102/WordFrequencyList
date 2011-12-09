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

@property (nonatomic) NSUInteger startNumber;
@property (nonatomic) NSUInteger totalWordCount;
@property (nonatomic, readonly) NSUInteger markedWordCount;
@property (nonatomic) NSUInteger intermediateMarkedWordCount;
@property (nonatomic) NSUInteger completeMarkedWordCount;
@property (nonatomic, readonly) float completePercentage;

@property (nonatomic) NSUInteger categoryId;
@property (nonatomic) NSUInteger groupId;

@end
