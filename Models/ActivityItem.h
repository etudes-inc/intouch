/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ActivityItem.h $
 * $Id: ActivityItem.h 2594 2012-01-31 17:37:21Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011 Etudes, Inc.
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

#import <Foundation/Foundation.h>
#import "CourseMap.h"
#import "Member.h"

@interface ActivityItem : NSObject
{
@protected
	NSString *userId;
	NSString *userIid;
	NSString *name;
	enum ParticipantStatus status;
	NSString *section;
	NSDate *firstVisit;
	NSDate *lastVisit;
	BOOL notVisitedAlert;
	int visits;
	NSDate *syllabusAccepted;
	int modules;
	int posts;
	int submissions;
	NSString *avatar;
}

+ (ActivityItem *) activityItemForDef:(NSDictionary *)def;

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *userIid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) enum ParticipantStatus status;
@property (nonatomic, retain) NSString *section;
@property (nonatomic, retain) NSDate *firstVisit;
@property (nonatomic, retain) NSDate *lastVisit;
@property (nonatomic, assign) BOOL notVisitedAlert;
@property (nonatomic, assign) int visits;
@property (nonatomic, retain) NSDate *syllabusAccepted;
@property (nonatomic, assign) int modules;
@property (nonatomic, assign) int posts;
@property (nonatomic, assign) int submissions;
@property (nonatomic, retain) NSString *avatar;

@end
