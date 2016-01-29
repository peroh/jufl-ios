//
//  Last Updated by Alok on 19/02/14.
//  Copyright (c) 2014 Aryansbtloe. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitDay)
	                                           fromDate:self
	                                             toDate:[NSDate date]
	                                            options:0];
	return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];

	return (int)[midnight timeIntervalSinceNow] / (60 * 60 * 24) * -1;
}

- (NSString *)stringDaysAgo {
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = @"Today";
			break;

		case 1:
			text = @"Yesterday";
			break;

		default:
			text = [NSString stringWithFormat:@"%lu days ago", (unsigned long)daysAgo];
	}
	return text;
}

- (NSUInteger)weekday {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitWeekday) fromDate:self];
	return [weekdayComponents weekday];
}

+ (NSDate *)dateFromString:(NSString *)string {
	return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}


+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime {
	/*
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];

	NSDate *today = [NSDate date];
	NSDateComponents *offsetComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
	                                                 fromDate:today];

	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	NSString *displayString = nil;

	// comparing against midnight
	NSComparisonResult midnight_result = [date compare:midnight];
	if (midnight_result == NSOrderedDescending) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		}
		else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	}
	else {
		// check if date is within last 7 days
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-7];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
		NSComparisonResult lastweek_result = [date compare:lastweek];
		if (lastweek_result == NSOrderedDescending) {
			if (displayTime) {
				[displayFormatter setDateFormat:@"EEEE h:mm a"];
			}
			else {
				[displayFormatter setDateFormat:@"EEEE"]; // Tuesday
			}
		}
		else {
			// check if same calendar year
			NSInteger thisYear = [offsetComponents year];

			NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
			                                               fromDate:date];
			NSInteger thatYear = [dateComponents year];
			if (thatYear >= thisYear) {
				if (displayTime) {
					[displayFormatter setDateFormat:@"MMM d h:mm a"];
				}
				else {
					[displayFormatter setDateFormat:@"MMM d"];
				}
			}
			else {
				if (displayTime) {
					[displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
				}
				else {
					[displayFormatter setDateFormat:@"MMM d, yyyy"];
				}
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
	}

	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];

	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
	return [[self class] stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayToDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *today = [NSDate date];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:today toDate:date options:0];
    
    NSInteger yearRemaining = components.year;
    NSInteger monthsRemaining = components.month;
    NSInteger daysRemaining = components.day;
    NSInteger hoursRemaning = components.hour;
    NSInteger minutesRemaning = components.minute;
    NSInteger secondsRemaning = components.second;
    
    NSMutableString *remaningTimeString = [NSMutableString string];
    
    
    if (yearRemaining > 0) {
        [remaningTimeString appendString:[NSString stringWithFormat:@"%liY ",(long)yearRemaining]];
        if (monthsRemaining > 0) {
            [remaningTimeString appendString:[NSString stringWithFormat:@"%liM ",(long)monthsRemaining]];
        }
    }
    
    else if (monthsRemaining > 0) {
        [remaningTimeString appendString:[NSString stringWithFormat:@"%liM ",(long)monthsRemaining]];
        if (daysRemaining > 0) {
            [remaningTimeString appendString:[NSString stringWithFormat:@"%lid ",(long)daysRemaining]];
        }
    }
    
    else if (daysRemaining > 0) {
        [remaningTimeString appendString:[NSString stringWithFormat:@"%lid ",(long)daysRemaining]];
        if (hoursRemaning > 0) {
            [remaningTimeString appendString:[NSString stringWithFormat:@"%lih ",(long)hoursRemaning]];
        }
    }
    else if(hoursRemaning>0)
    {
        [remaningTimeString appendString:[NSString stringWithFormat:@"%lih ",(long)hoursRemaning]];
        if(minutesRemaning>0)
        {
            [remaningTimeString appendString:[NSString stringWithFormat:@"%lim ",(long)minutesRemaning]];
        }
    }
    else if(minutesRemaning>0)
    {
        [remaningTimeString appendString:[NSString stringWithFormat:@"%lim ",(long)minutesRemaning]];
    }
    
    else if(secondsRemaning>0)
    {
        [remaningTimeString appendString:[NSString stringWithFormat:@"%lis ",(long)secondsRemaning]];
    }

    return [NSString stringWithString:remaningTimeString];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	return timestamp_str;
}

- (NSString *)string {
	return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:dateStyle];
	[outputFormatter setTimeStyle:timeStyle];
	NSString *outputString = [outputFormatter stringFromDate:self];
	return outputString;
}

- (NSDate *)beginningOfWeek {
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *beginningOfWeek = nil;
	BOOL ok = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginningOfWeek
	                       interval:NULL forDate:self];
	if (ok) {
		return beginningOfWeek;
	}

	// couldn't calc via range, so try to grab Sunday, assuming gregorian style
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];

	/*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 1)];
	beginningOfWeek = nil;
	beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];

	//normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
	                                           fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	// Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
	                                           fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
	NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
	// to get the end of week for a particular date, add (7 - weekday) days
	[componentsToAdd setDay:(7 - [weekdayComponents weekday])];
	NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];

	return endOfWeek;
}

+ (NSString *)dateFormatString {
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
//	return @"HH:mm:ss";
    return @"hh:mm a";
}

+ (NSString *)timestampFormatString {
//	return @"yyyy-MM-dd HH:mm:ss";
    return @"hh:mm a dd/MM/yy";
}

// preserving for compatibility
+ (NSString *)dbFormatString {
	return [NSDate timestampFormatString];
}

- (NSString*)gmtDateString{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:DATE_FORMAT_USED];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	NSString * gmtDateString = [dateFormatter stringFromDate:self];
	return gmtDateString;
}

- (NSString*)localDateString{
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:DATE_FORMAT_USED];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString * localDateString = [dateFormatter stringFromDate:self];
	return localDateString;
}

@end

@implementation NSString (Helper)

- (NSString*)gmtDateString{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:DATE_FORMAT_USED];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
	return [dateFormatter stringFromDate:[NSDate dateFromString:self]];
}

- (NSString*)localDateString{
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:DATE_FORMAT_USED];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	return [dateFormatter stringFromDate:[NSDate dateFromString:self]];
}
- (NSString*)localDateStringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:[NSDate dateFromString:self withFormat:format]];
}

@end
