/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Site.m $
 * $Id: Site.m 2651 2012-02-14 00:31:22Z ggolden $
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

#import "Site.h"

@interface Site()

@property (nonatomic, retain) NSString *siteId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *siteDescription;
@property (nonatomic, assign) BOOL allowActivityMeter;
@property (nonatomic, assign) BOOL allowCourseMap;
@property (nonatomic, assign) BOOL allowNewAnnouncement;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL instructorPrivileges;
@property (nonatomic, assign) BOOL taPrivileges;
@property (nonatomic, assign) int online;
@property (nonatomic, assign) int unreadMessages;
@property (nonatomic, assign) BOOL unreadPosts;
@property (nonatomic, assign) int notVisitAlerts;

@end

@implementation Site

@synthesize siteId, title, siteDescription, allowActivityMeter, allowCourseMap, allowNewAnnouncement, visible, instructorPrivileges, taPrivileges;
@synthesize online, unreadMessages, unreadPosts, notVisitAlerts;

#pragma mark - lifecycle

- (id) initWithId:(NSString *)theSiteId title:(NSString *)theTitle siteDescription:(NSString *)theDescription
			activityMeter:(BOOL)allowAm courseMap:(BOOL)allowCm newAnnouncement:(BOOL) allowNewAnnc visible:(BOOL)theVisible
			instructorPrivileges:(BOOL)theInstructorPrivileges taPrivileges:(BOOL)theTaPrivileges
			online:(int)theOnline unreadMessages:(int)theUnreadMessages unreadPosts:(BOOL)theUnreadPosts notVisitAlerts:(int)theNotVisitAlerts

{
	self = [super init];
    if (self)
	{
		self.siteId = theSiteId;
		self.title = theTitle;
		self.siteDescription = theDescription;
		self.allowActivityMeter = allowAm;
		self.allowCourseMap = allowCm;
		self.allowNewAnnouncement = allowNewAnnc;
		self.visible = theVisible;
		self.instructorPrivileges = theInstructorPrivileges;
		self.taPrivileges = theTaPrivileges;
		self.online = theOnline;
		self.unreadMessages = theUnreadMessages;
		self.unreadPosts = theUnreadPosts;
		self.notVisitAlerts = theNotVisitAlerts;
    }

    return self;
}

- (void)dealloc
{
	[siteId release];
	[title release];
	[siteDescription release];
	
	[super dealloc];
}

+ (Site *) siteForDef:(NSDictionary *)def
{
	NSString *siteId = [def objectForKey:@"siteId"];
	NSString *title = [def objectForKey:@"title"];
	NSString *siteDescription = [def objectForKey:@"description"];
	NSNumber *allowAm = [def objectForKey:@"am"];
	NSNumber *allowCm = [def objectForKey:@"cm"];
	NSNumber *theInstructorPrivileges = [def objectForKey:@"instructorPrivileges"];
	NSNumber *theTaPrivileges = [def objectForKey:@"taPrivileges"];
	NSNumber *theOnLineCount = [def objectForKey:@"online"];
	NSNumber *theUnreadMessages = [def objectForKey:@"unreadMessages"];
	NSNumber *theNotVisitAlerts = [def objectForKey:@"notVisitAlerts"];
	NSNumber *allowNewAnnc = [def objectForKey:@"announcement"];
	NSNumber *theUnreadPosts = [def objectForKey:@"unreadPosts"];

	NSNumber *theVisible = [def objectForKey:@"visible"];
	
	Site *site = [[Site alloc] initWithId:siteId title:title siteDescription:siteDescription
							activityMeter:[allowAm boolValue] courseMap:[allowCm boolValue] newAnnouncement:[allowNewAnnc boolValue]
								  visible:[theVisible boolValue] instructorPrivileges:[theInstructorPrivileges boolValue]
				  taPrivileges:[theTaPrivileges boolValue]  online:[theOnLineCount intValue] unreadMessages:[theUnreadMessages intValue]
							  unreadPosts:[theUnreadPosts boolValue] 
						   notVisitAlerts:[theNotVisitAlerts intValue]];

	return [site autorelease];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Site id:%@ title:%@", self.siteId, self.title];
}

@end
