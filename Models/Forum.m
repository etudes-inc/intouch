/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Forum.m $
 * $Id: Forum.m 2556 2012-01-25 16:43:49Z ggolden $
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

#import "Forum.h"
#import "Topic.h"

@interface Forum()

@property (nonatomic, assign) Category *category;
@property (nonatomic, retain) NSString *forumId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *forumDescription;
@property (nonatomic, assign) int numTopics;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, assign) enum ForumType type;
@property (nonatomic, assign) BOOL published;
@property (nonatomic, retain) NSDate *open;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSDate *allowUntil;
@property (nonatomic, assign) BOOL hideTillOpen;
@property (nonatomic, assign) BOOL lockOnDue;
@property (nonatomic, assign) BOOL graded;
@property (nonatomic, assign) int minPosts;
@property (nonatomic, assign) float points;
@property (nonatomic, assign) BOOL pastDueLocked;
@property (nonatomic, assign) BOOL notYetOpen;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, retain) NSString *blockedBy;

@end

@implementation Forum

@synthesize forumId, category, title, forumDescription, numTopics, topics, topicsLoaded, unread, type;
@synthesize published, open, due, allowUntil, hideTillOpen, lockOnDue, graded, minPosts, points, pastDueLocked, notYetOpen;
@synthesize blocked, blockedBy;

#pragma mark - lifecycle

+ (Forum *) forumInCategory:(Category *)theCategory forDef:(NSDictionary *)def
{
	NSString *theForumId = [def objectForKey:@"forumId"];
	NSString *theTitle = [def objectForKey:@"title"];
	NSString *theDescription = [def objectForKey:@"description"];
	if ([theDescription length] == 0) theDescription = nil;
	NSNumber *theNumTopics = [def objectForKey:@"numTopics"];
	NSNumber *theUnread = [def objectForKey:@"unread"];
	NSNumber *theType = [def objectForKey:@"type"];
	NSNumber *theOpen = [def objectForKey:@"open"];
	NSNumber *theDue = [def objectForKey:@"due"];
	NSNumber *theAllowUntil = [def objectForKey:@"allowUntil"];
	NSNumber *theHideTillOpen = [def objectForKey:@"hideTillOpen"];
	NSNumber *theLockOnDue = [def objectForKey:@"lockOnDue"];
	NSNumber *thePublished = [def objectForKey:@"published"];
	NSNumber *theGraded = [def objectForKey:@"graded"];
	NSNumber *theMinPosts = [def objectForKey:@"minPosts"];
	NSNumber *thePoints = [def objectForKey:@"points"];
	NSNumber *thePastDueLocked = [def objectForKey:@"pastDueLocked"];
	NSNumber *theNotYetOpen = [def objectForKey:@"notYetOpen"];
	NSString *theBlockedBy = [def objectForKey:@"blocked"];

	NSDate *open = nil;
	NSDate *due = nil;
	NSDate *allowUntil = nil;
	if ([theOpen intValue] != 0) open = [NSDate dateWithTimeIntervalSince1970:[theOpen intValue]];
	if ([theDue intValue] != 0) due = [NSDate dateWithTimeIntervalSince1970:[theDue intValue]];
	if ([theAllowUntil intValue] != 0) allowUntil = [NSDate dateWithTimeIntervalSince1970:[theAllowUntil intValue]];
	
	Forum *forum = [[Forum alloc] initInCategory:theCategory forumId:theForumId title:theTitle description:theDescription
									   numTopics:[theNumTopics intValue] unread:[theUnread boolValue]
											type:[theType intValue] published:[thePublished boolValue] open:open due:due allowUntil:allowUntil
									hideTillOpen:[theHideTillOpen boolValue] lockOnDue:[theLockOnDue boolValue] graded:[theGraded boolValue]
										minPosts:[theMinPosts intValue] points:[thePoints floatValue] pastDueLocked:[thePastDueLocked boolValue]
									  notYetOpen:[theNotYetOpen boolValue] blocked:(theBlockedBy != nil) blockedBy:theBlockedBy];
	return [forum autorelease];
}

- (id) initInCategory:(Category *)theCategory forumId:(NSString *)theForumId title:(NSString *)theTitle description:(NSString *)theDescription
			numTopics:(int)theNumTopics unread:(BOOL)theUnread type:(enum ForumType)theType published:(BOOL)thePublished open:(NSDate *)theOpen
				  due:(NSDate *)theDue allowUntil:(NSDate *)theAllowUntil hideTillOpen:(BOOL)theHideTillOpen
			lockOnDue:(BOOL)theLockOnDue graded:(BOOL)theGraded minPosts:(int)theMinPosts points:(float)thePoints pastDueLocked:(BOOL)thePastDueLocked
		   notYetOpen:(BOOL)theNotYetOpen blocked:(BOOL)theBlocked blockedBy:(NSString *)theBlockedBy
{
	self = [super init];
    if (self)
	{
		self.category = theCategory;
		self.forumId = theForumId;
		self.title = theTitle;
		self.forumDescription = theDescription;
		self.numTopics = theNumTopics;
		self.unread = theUnread;
		self.type = theType;
		self.published = thePublished;
		self.open = theOpen;
		self.due = theDue;
		self.allowUntil = theAllowUntil;
		self.hideTillOpen = theHideTillOpen;
		self.lockOnDue = theLockOnDue;
		self.graded = theGraded;
		self.minPosts = theMinPosts;
		self.points = thePoints;
		self.pastDueLocked = thePastDueLocked;
		self.notYetOpen = theNotYetOpen;
		self.blocked = theBlocked;
		self.blockedBy = theBlockedBy;
	}
	
    return self;
}

- (void)dealloc
{
	[forumId release];
	[title release];
	[forumDescription release];
	[topics release];
	[topicsLoaded release];
	[open release];
	[due release];
	[allowUntil release];
	[blockedBy release];

    [super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Forum id:%@ title:%@", self.forumId, self.title];
}

- (void) setTopics:(NSArray *)theTopics
{
	if (topics != theTopics)
	{
		[topics release];
		topics = nil;
		[topicsLoaded release];
		topicsLoaded = nil;

		if (theTopics != nil)
		{
			topics = [theTopics retain];

			// mark the date that the topics were loaded
			topicsLoaded = [[NSDate date] retain];
			
			// set these topics as being in this forum
			for (Topic *t in topics)
			{
				t.forum = self;
			}
		}
	}
}

// reset our unread indicator based on the read status of our loaded topics
- (void) updateUnread
{
	for (Topic *t in self.topics)
	{
		if (t.unread)
		{
			self.unread = YES;
			return;
		}
	}
	
	self.unread = NO;
}

// update to match values in the other
- (void) setToMatch:(Forum *)theOther
{
	// stay in the same category, and keep the same id - don't mess with the forums
	self.title = theOther.title;
	self.forumDescription = theOther.forumDescription;
	self.numTopics = theOther.numTopics;
	self.unread = theOther.unread;
	self.type = theOther.type;
	self.published = theOther.published;
	self.open = theOther.open;
	self.due = theOther.due;
	self.allowUntil = theOther.allowUntil;
	self.hideTillOpen = theOther.hideTillOpen;
	self.lockOnDue = theOther.lockOnDue;
	self.graded = theOther.graded;
	self.minPosts = theOther.minPosts;
	self.points = theOther.points;
	self.pastDueLocked = theOther.pastDueLocked;
	self.notYetOpen = theOther.notYetOpen;
	self.blocked = theOther.blocked;
	self.blockedBy = theOther.blockedBy;
}

@end
