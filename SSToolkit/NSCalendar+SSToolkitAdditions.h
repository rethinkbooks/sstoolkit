//
//  NSCalendar+SSToolkitAdditions.h
//  BookShout
//
//  Created by Arthur Dexter on 1/25/12.
//  Copyright (c) 2012 Rethink Books, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (SSToolkitAdditions)

// Calculate the number of the given units between two times. This only works for units larger than seconds.
- (NSInteger)units:(NSCalendarUnit)units withinEraFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

@end
