/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Site.h $
 * $Id: Site.h 2651 2012-02-14 00:31:22Z ggolden $
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

#import <Foundation/Foundation.h>

@interface Site : NSObject
{
@protected
	NSString *siteId;
	NSString *title;
	NSString *siteDescription;
	BOOL allowActivityMeter;
	BOOL allowCourseMap;
	BOOL allowNewAnnouncement;
	BOOL visible;
	BOOL instructorPrivileges;
	int online;
	int unreadMessages;
	BOOL unreadPosts;
	int notVisitAlerts;
}

+ (Site *) siteForDef:(NSDictionary *)def;

- (id) initWithId:(NSString *)theSiteId title:(NSString *)theTitle siteDescription:(NSString *)theDescription activityMeter:(BOOL)allowAm
		courseMap:(BOOL)allowCm newAnnouncement:(BOOL)allowNewAnnc visible:(BOOL)visible instructorPrivileges:(BOOL)instructorPrivileges
	 taPrivileges:(BOOL)taPrivileges online:(int)online unreadMessages:(int)unreadMessages unreadPosts:(BOOL)unreadPosts
   notVisitAlerts:(int)notVisitAlerts;

@property (nonatomic, readonly, retain) NSString *siteId;
@property (nonatomic, readonly, retain) NSString *title;
@property (nonatomic, readonly, retain) NSString *siteDescription;
@property (nonatomic, readonly, assign) BOOL allowActivityMeter;
@property (nonatomic, readonly, assign) BOOL allowCourseMap;
@property (nonatomic, readonly, assign) BOOL allowNewAnnouncement;
@property (nonatomic, readonly, assign) BOOL visible;
@property (nonatomic, readonly, assign) BOOL instructorPrivileges;
@property (nonatomic, readonly, assign) BOOL taPrivileges;
@property (nonatomic, readonly, assign) int online;
@property (nonatomic, readonly, assign) int unreadMessages;
@property (nonatomic, readonly, assign) BOOL unreadPosts;
@property (nonatomic, readonly, assign) int notVisitAlerts;

@end
