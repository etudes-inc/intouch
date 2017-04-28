/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ActivityItem.m $
 * $Id: ActivityItem.m 2594 2012-01-31 17:37:21Z ggolden $
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

#import "ActivityItem.h"

@interface ActivityItem()

@end

@implementation ActivityItem

@synthesize userId, userIid, name, status, section, firstVisit, lastVisit, notVisitedAlert, visits, syllabusAccepted, modules;
@synthesize posts, submissions, avatar;

+ (ActivityItem *) activityItemForDef:(NSDictionary *)def
{
	ActivityItem *rv = [[ActivityItem alloc] init];
	
	NSString *theUserId = [def objectForKey:@"userId"];
	rv.userId = theUserId;

	NSString *theUserIid = [def objectForKey:@"iid"];
	rv.userIid = theUserIid;

	NSString *theName = [def objectForKey:@"name"];
	rv.name = theName;

	rv.status = [Member participantStatusForDef:[def objectForKey:@"status"]];

	NSString *theSection = [def objectForKey:@"section"];
	rv.section = theSection;

	NSNumber *the_firstVisit = [def objectForKey:@"firstVisit"];
	NSDate *theFirstVisit = nil;
	if ([the_firstVisit intValue] != 0) theFirstVisit = [NSDate dateWithTimeIntervalSince1970:[the_firstVisit intValue]];
	rv.firstVisit = theFirstVisit;
	
	NSNumber *the_lastVisit = [def objectForKey:@"lastVisit"];
	NSDate *theLasttVisit = nil;
	if ([the_lastVisit intValue] != 0) theLasttVisit = [NSDate dateWithTimeIntervalSince1970:[the_lastVisit intValue]];
	rv.lastVisit = theLasttVisit;

	NSNumber *the_notVisitedAlert = [def objectForKey:@"notVisitedAlert"];
	rv.notVisitedAlert = [the_notVisitedAlert boolValue];
	
	NSNumber *the_visits = [def objectForKey:@"visits"];
	rv.visits = [the_visits intValue];

	NSNumber *the_syllabusAccepted = [def objectForKey:@"syllabusAccepted"];
	NSDate *theSyllabusAccepted = nil;
	if ([the_syllabusAccepted intValue] != 0) theSyllabusAccepted = [NSDate dateWithTimeIntervalSince1970:[the_syllabusAccepted intValue]];
	rv.syllabusAccepted = theSyllabusAccepted;

	NSNumber *the_modules = [def objectForKey:@"modules"];
	rv.modules = [the_modules intValue];

	NSNumber *the_posts = [def objectForKey:@"posts"];
	rv.posts = [the_posts intValue];

	NSNumber *the_submissions = [def objectForKey:@"submissions"];
	rv.submissions = [the_submissions intValue];

	NSString *theAvatar = [def objectForKey:@"avatar"];
	rv.avatar = theAvatar;

	return [rv autorelease];
}

- (void) dealloc
{
	[userId release];
	[userIid release];
	[name release];
	[section release];
	[firstVisit release];
	[lastVisit release];
	[syllabusAccepted release];
	[avatar release];

    [super dealloc];
}

@end
