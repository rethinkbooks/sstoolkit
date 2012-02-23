//
//  NSDate+SSToolkitAdditions.m
//  SSToolkit
//
//  Created by Sam Soffes on 5/26/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "NSDate+SSToolkitAdditions.h"
#import "NSCalendar+SSToolkitAdditions.h"
#include <time.h>

@implementation NSDate (SSToolkitAdditions)

+ (NSDate *)dateFromISO8601String:(NSString *)string {
	if (!string) {
		return nil;
	}
	
	struct tm tm;
	time_t t;	
	
	strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
	tm.tm_isdst = -1;
	t = timegm(&tm);
	
	return [NSDate dateWithTimeIntervalSince1970:t];
}


- (NSString *)ISO8601String {
	struct tm *timeinfo;
	char buffer[80];
	
	time_t rawtime = [self timeIntervalSince1970];
	timeinfo = localtime(&rawtime);
	
	strftime(buffer, 80, "%Y-%m-%dT%H:%M:%S%z", timeinfo);
	
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}


//	Adapted from http://github.com/gabriel/gh-kit/blob/master/Classes/GHNSString+TimeInterval.m
+ (NSString *)timeAgoInWordsFromTimeInterval:(NSTimeInterval)intervalInSeconds includingSeconds:(BOOL)includeSeconds {
	double intervalInMinutes = round(intervalInSeconds / 60.0f);
	
	if (intervalInMinutes >= 0 && intervalInMinutes <= 1) {
		if (!includeSeconds) {
			return intervalInMinutes <= 0 ?
                NSLocalizedString(@"less than a minute", @"Time ago less than one minute") :
                NSLocalizedString(@"1 minute", @"Time ago one minute");
		}
		if (intervalInSeconds >= 0 && intervalInSeconds < 5) {
			return NSLocalizedString(@"less than 5 seconds", @"Time ago less than 5 seconds");
		} else if (intervalInSeconds >= 5 && intervalInSeconds < 10) {
			return NSLocalizedString(@"less than 10 seconds", @"Time ago less than 10 seconds");
		} else if (intervalInSeconds >= 10 && intervalInSeconds < 20) {
			return NSLocalizedString(@"less than 20 seconds", @"Time ago less than 20 seconds");
		} else if (intervalInSeconds >= 20 && intervalInSeconds < 40) {
			return NSLocalizedString(@"half a minute", @"Time ago half minute");
		} else if (intervalInSeconds >= 40 && intervalInSeconds < 60) {
			return NSLocalizedString(@"less than a minute", @"Time ago less than a minute");
	 	} else {
			return NSLocalizedString(@"1 minute", @"Time ago one minute");
		}		
	} else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0f minutes", @"Time ago less than one hour"), intervalInMinutes];
	} else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) {
		return NSLocalizedString(@"about 1 hour", @"Time ago about one hour");
	} else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) {
		return [NSString stringWithFormat:NSLocalizedString(@"about %.0f hours", @"Time ago about n hours format"), round(intervalInMinutes/60.0f)];
	} else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) {
		return NSLocalizedString(@"1 day", @"Time ago one day");
	} else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0f days", @"Time ago n days format"), round(intervalInMinutes/1440.0f)];
	} else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) {
		return NSLocalizedString(@"about 1 month", @"Time ago one month");
	} else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0f months", @"Time ago n months format"), round(intervalInMinutes/43200.0f)];
	} else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) {
		return NSLocalizedString(@"about 1 year", @"Time ago one year");
	} else {
		return [NSString stringWithFormat:NSLocalizedString(@"over %.0f years", @"Time ago over n years format"), round(intervalInMinutes/525600.0f)];
	}
	return nil;
}


- (NSString *)timeAgoInWords {
	return [self timeAgoInWordsIncludingSeconds:YES];
}


- (NSString *)timeAgoInWordsIncludingSeconds:(BOOL)includeSeconds {
	return [[self class] timeAgoInWordsFromTimeInterval:fabs([self timeIntervalSinceNow]) includingSeconds:includeSeconds];		
}


+ (NSString *)timeAgoCrypticFromTimeInterval:(NSTimeInterval)intervalInSeconds {
	double intervalInMinutes = round(intervalInSeconds / 60.0f);
	
	if (intervalInMinutes >= 0 && intervalInMinutes <= 1) {
		return NSLocalizedString(@"~1m", @"Time ago cryptic one minute");
	} else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fm", @"Time ago cryptic minutes format"), intervalInMinutes];
	} else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) {
		return NSLocalizedString(@"~1h", @"Time ago cryptic one hour");
	} else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fh", @"Time ago cryptic hours format"), round(intervalInMinutes/60.0f)];
	} else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) {
		return NSLocalizedString(@"~1d", @"Time ago cryptic one day");
	} else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fd", @"Time ago cryptic days format"), round(intervalInMinutes/1440.0f)];
	} else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) {
		return NSLocalizedString(@"~1M", @"Time ago cryptic one month");
	} else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fM", @"Time ago cryptic months format"), round(intervalInMinutes/43200.0f)];
	} else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) {
		return NSLocalizedString(@"~1Y", @"Time ago cryptic one year");
	} else {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fY+", @"Time ago cryptic years format"), round(intervalInMinutes/525600.0f)];
	}
	return nil;
}


- (NSString *)timeAgoCryptic {
	return [[self class] timeAgoCrypticFromTimeInterval:fabs([self timeIntervalSinceNow])];		
}


- (NSDate *)adjustedDate {
	return [[[NSDate alloc] initWithTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT] sinceDate:self] autorelease];
}


- (NSString *)adjustedTimeAgoInWords {
	return [self adjustedTimeAgoInWordsIncludingSeconds:YES];
}


- (NSString *)adjustedTimeAgoInWordsIncludingSeconds:(BOOL)includeSeconds {
	return [[self class] timeAgoInWordsFromTimeInterval:fabs([self timeIntervalSinceNow] + [[NSTimeZone localTimeZone] secondsFromGMT]) includingSeconds:includeSeconds];
}

- (NSString *)unitsGroupStringFromDate:(NSDate *)date {
    NSString *result = nil;
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekOfMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents *selfComps = [cal components:unitFlags fromDate:self];
    NSDateComponents *dateComps = [cal components:unitFlags fromDate:date];

    NSDateComponents *delta = [[[NSDateComponents alloc] init] autorelease];
    delta.year = dateComps.year - selfComps.year;
    delta.month = dateComps.month - selfComps.month;
    delta.weekOfMonth = dateComps.weekOfMonth - selfComps.weekOfMonth;
    delta.day = dateComps.day - selfComps.day;

    if (delta.year == 0) {
        if (delta.month == 0) {
            if (delta.weekOfMonth == 0) {
                if (delta.day == 0) {
                    result = NSLocalizedString(@"Today", @"Today");
                } else if (delta.day > 1) {
                    result = NSLocalizedString(@"This Week", @"This Week");
                } else if (delta.day > 0) {
                    result = NSLocalizedString(@"Yesterday", @"Yesterday");
                }
            } else if (delta.weekOfMonth > 0) {
                result = NSLocalizedString(@"This Month", @"This Month");
            }
        } else if (delta.month > 0) {
            result = NSLocalizedString(@"This Year", @"This Year");
        }
    } else if (delta.year > 1) {
        result = NSLocalizedString(@"More Than One Year Ago", @"More Than One Year Ago");
    } else if (delta.year > 0) {
        result = NSLocalizedString(@"Last Year", @"Last Year");
    }
    if (!result) {
        result = NSLocalizedString(@"In The Future", @"In The Future");
    }

    return result;
}

@end
