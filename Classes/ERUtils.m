//
//  ERUtils.m
//  Billy
//
//  Created by Eugenijus on 2010-12-26.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import "ERUtils.h"

@implementation ERUtils

+ (NSDecimalNumber *)invertDecimalNumber:(NSDecimalNumber *)number {
	return [number decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES]];	
}

+ (NSDecimalNumber *)absoluteDecimalNumber:(NSDecimalNumber *)number {
	
	if ([number compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
		return [self invertDecimalNumber:number];
	}
	return number;
}

+ (NSDate *)today {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	return [calendar dateFromComponents:components];
}

@end
