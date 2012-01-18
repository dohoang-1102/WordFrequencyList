//
//  History.h
//  WordFrequencyList
//
//  Created by Lei Perry on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface History : NSManagedObject

@property (nonatomic, retain) NSNumber * markComplete;
@property (nonatomic, retain) NSString * markDate;
@property (nonatomic, retain) NSString * spell;

@end
