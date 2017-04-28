/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/DateFormat.m $
 * $Id: DateFormat.m 2582 2012-01-30 17:19:06Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011, 2012 Etudes, Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

#import "DateFormat.h"

@implementation NSDate (DateFormat)

+ (NSString *) stringInEtudesFormatOrDash:(NSDate *)date
{
	if (date == nil) return @"-";
	return [date stringInEtudesFormat];
}

- (NSString *) stringInEtudesFormat
{
	return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (BOOL) dateInSameDay:(NSDate *)firstDate asDate:(NSDate *)secondDate
{
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyy-MM-dd"];	
	BOOL rv = [[fmt stringFromDate:firstDate] isEqualToString:[fmt stringFromDate:secondDate]];
	[fmt release];
	return rv;
}

- (NSString *) stringInAdaptiveShortFormat
{
	NSString *rv = nil;

	// if same day, use a short time
	if ([self dateInSameDay:self asDate:[NSDate date]])
	{
		rv = [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
	}
	
	// else use a medium date
	else
	{
		rv = [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
	}
	
	return rv;
}

@end
