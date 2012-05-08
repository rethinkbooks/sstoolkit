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
+ (NSString *)timeAgoInWordsFromTimeInterval:(NSTimeInterval)intervalInSeconds {
	double intervalInMinutes = round(-intervalInSeconds / 60.0f);
	
	if (intervalInMinutes <= 4) {
        return NSLocalizedString(@"Just now", @"Time ago less than five minutes");
	} else if (intervalInMinutes >= 5 && intervalInMinutes <= 44) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0f minutes", @"Time ago less than one hour"), intervalInMinutes];
	} else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) {
		return NSLocalizedString(@"about 1 hour ago", @"Time ago about one hour");
	} else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) {
		return [NSString stringWithFormat:NSLocalizedString(@"about %.0f hours", @"Time ago about n hours format"), round(intervalInMinutes/60.0f)];
	} else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) {
		return NSLocalizedString(@"1 day ago", @"Time ago one day");
	} else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0f days", @"Time ago n days format"), round(intervalInMinutes/1440.0f)];
	} else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) {
		return NSLocalizedString(@"about 1 month ago", @"Time ago one month");
	} else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0f months", @"Time ago n months format"), round(intervalInMinutes/43200.0f)];
	} else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) {
		return NSLocalizedString(@"about 1 year ago", @"Time ago one year");
	} else {
		return [NSString stringWithFormat:NSLocalizedString(@"over %.0f years ago", @"Time ago over n years format"), round(intervalInMinutes/525600.0f)];
	}
	return nil;
}


- (NSString *)timeAgoInWords {
	return [[self class] timeAgoInWordsFromTimeInterval:[self timeIntervalSinceNow]];
}


+ (NSString *)timeAgoCrypticFromTimeInterval:(NSTimeInterval)intervalInSeconds {
	double intervalInMinutes = round(-intervalInSeconds / 60.0f);
	
	if (intervalInMinutes <= 4) {
		return NSLocalizedString(@"Just now", @"Time ago cryptic one minute");
	} else if (intervalInMinutes >= 5 && intervalInMinutes <= 44) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fm", @"Time ago cryptic minutes format"), intervalInMinutes];
	} else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) {
		return NSLocalizedString(@"~1h ago", @"Time ago cryptic one hour");
	} else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fh", @"Time ago cryptic hours format"), round(intervalInMinutes/60.0f)];
	} else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) {
		return NSLocalizedString(@"~1d ago", @"Time ago cryptic one day");
	} else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fd", @"Time ago cryptic days format"), round(intervalInMinutes/1440.0f)];
	} else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) {
		return NSLocalizedString(@"~1M ago", @"Time ago cryptic one month");
	} else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fM", @"Time ago cryptic months format"), round(intervalInMinutes/43200.0f)];
	} else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) {
		return NSLocalizedString(@"~1Y ago", @"Time ago cryptic one year");
	} else {
		return [NSString stringWithFormat:NSLocalizedString(@"%.0fY+ ago", @"Time ago cryptic years format"), round(intervalInMinutes/525600.0f)];
	}
	return nil;
}


- (NSString *)timeAgoCryptic {
	return [[self class] timeAgoCrypticFromTimeInterval:[self timeIntervalSinceNow]];
}


- (NSDate *)adjustedDate {
	return [[[NSDate alloc] initWithTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT] sinceDate:self] autorelease];
}


- (NSString *)adjustedTimeAgoInWords {
	return [[self class] timeAgoInWordsFromTimeInterval:[self timeIntervalSinceNow] + [[NSTimeZone localTimeZone] secondsFromGMT]];
}

- (NSString *)unitsGroupStringFromDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *delta = [[[NSDateComponents alloc] init] autorelease];
    const BOOL haveWeeks = [delta respondsToSelector:@selector(weekOfYear)];
    unsigned int unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    if (haveWeeks) {
        unitFlags |= NSWeekOfYearCalendarUnit;
    }
    NSDateComponents *selfComps = [cal components:unitFlags fromDate:self];
    NSDateComponents *dateComps = [cal components:unitFlags fromDate:date];
    delta = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self toDate:date options:0];
    NSInteger deltaDays = [cal components:NSDayCalendarUnit fromDate:self toDate:date options:0].day;
    NSInteger deltaWeeks = 0;
    if(haveWeeks) {
        deltaWeeks = dateComps.weekOfYear - selfComps.weekOfYear;
    }
    NSInteger deltaMonths = dateComps.month - selfComps.month;
    NSInteger deltaYears = dateComps.year - selfComps.year;
    
    if(deltaDays == 0) {
        return NSLocalizedString(@"Today", @"Today");
    } else if (deltaDays == 1) {
        return NSLocalizedString(@"Yesterday", @"Yesterday");
    }

    if(haveWeeks) {
        if(deltaWeeks == 0) {
            return NSLocalizedString(@"This Week", @"This Week");
        } else if(deltaWeeks == 1) {
            return NSLocalizedString(@"Last Week", @"Last Week");
        }
    }

    if(deltaMonths == 0) {
        return NSLocalizedString(@"This Month", @"This Month");
    } else if(deltaMonths == 1) {
        return NSLocalizedString(@"Last Month", @"Last Month");
    }

    if(deltaYears == 0) {
        return NSLocalizedString(@"This Year", @"This Year");
    } else if(deltaYears == 1) {
        return NSLocalizedString(@"Last Year", @"Last Year");
    } else {
        return NSLocalizedString(@"More Than One Year Ago", @"More Than One Year Ago");
    }
}

@end
