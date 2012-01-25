//
//  NSCalendar+SSToolkitAdditions.m
//  BookShout
//
//  Created by Arthur Dexter on 1/25/12.
//  Copyright (c) 2012 Rethink Books, Inc. All rights reserved.
//

#import "NSCalendar+SSToolkitAdditions.h"

@implementation NSCalendar (SSToolkitAdditions)

- (NSInteger)units:(NSCalendarUnit)units withinEraFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSAssert(units != NSSecondCalendarUnit, @"Seconds not supported for this method.");
    NSInteger start = [self ordinalityOfUnit:units inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger end = [self ordinalityOfUnit:units inUnit:NSEraCalendarUnit forDate:endDate];
    return end - start;
}

@end
