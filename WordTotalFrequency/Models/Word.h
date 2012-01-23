//
//  Word.h
//  WordTotalFrequency
//
//  Created by OCS on 11-7-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Word : NSManagedObject {
    
}

@property (nonatomic, retain) NSString *spell;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) NSString *soundFile;
@property (nonatomic, retain) NSString *phonetic;
@property (nonatomic, retain) NSString *translate;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, retain) NSString *detail;
@property (nonatomic, retain) NSNumber *category;
@property (nonatomic, retain) NSNumber *group;

@end
