//
//  Util.m
//  WordFrequencyList
//
//  Created by  on 11-12-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSUInteger)iOSVersionMajor
{
    NSString *version = [UIDevice currentDevice].systemVersion;
    version = [version substringToIndex:1];
    return [version intValue];
}

@end
