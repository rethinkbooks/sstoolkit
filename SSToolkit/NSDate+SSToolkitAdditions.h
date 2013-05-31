//
//  NSDate+SSToolkitAdditions.h
//  SSToolkit
//
//  Created by Sam Soffes on 5/26/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

@interface NSDate (SSToolkitAdditions)

+ (NSDate *)dateFromISO8601String:(NSString *)string;
- (NSString *)ISO8601String;

+ (NSString *)timeAgoInWordsFromTimeInterval:(NSTimeInterval)intervalInSeconds;
- (NSString *)timeAgoInWords;

+ (NSString *)timeAgoCrypticFromTimeInterval:(NSTimeInterval)intervalInSeconds;
- (NSString *)timeAgoCryptic;

// Adjusts for the current time zone
- (NSDate *)adjustedDate;
- (NSString *)adjustedTimeAgoInWords;

- (NSString *)unitsGroupStringFromDate:(NSDate *)date;

+ (NSDate *)today;
+ (NSDate *)yesterday;

@end
