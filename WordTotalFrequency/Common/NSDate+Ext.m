//
//  NSDate+Ext.m
//  WordTotalFrequency
//
//  Created by Perry on 11-10-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Ext.h"


@implementation NSDate (Ext)

- (NSString *)formatLongDate {
	static NSDateFormatter* formatter = nil;
	if (nil == formatter) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSS";
		formatter.locale = [NSLocale currentLocale];
	}
	return [formatter stringFromDate:self];
}


@end