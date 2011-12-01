//
//  WordSet.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WordSet : NSObject {
    
}

@property (nonatomic) NSInteger totalWordCount;
@property (nonatomic, readonly) NSInteger markedWordCount;
@property (nonatomic) NSInteger intermediateMarkedWordCount;
@property (nonatomic) NSInteger completeMarkedWordCount;
@property (nonatomic, readonly) NSNumber *completePercentage;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *arrowColor;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic) NSInteger categoryId;

@end
