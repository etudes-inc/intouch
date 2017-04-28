/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Topic.m $
 * $Id: Topic.m 2556 2012-01-25 16:43:49Z ggolden $
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

#import "Topic.h"

@interface Topic()

@property (nonatomic, retain) NSString *topicId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, assign) int numPosts;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, assign) enum TopicType type;
@property (nonatomic, assign) BOOL published;
@property (nonatomic, retain) NSDate *open;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSDate *allowUntil;
@property (nonatomic, assign) BOOL hideTillOpen;
@property (nonatomic, assign) BOOL lockOnDue;
@property (nonatomic, assign) BOOL graded;
@property (nonatomic, assign) int minPosts;
@property (nonatomic, assign) float points;
@property (nonatomic, assign) BOOL readOnly;
@property (nonatomic, assign) BOOL forumReadOnly;
@property (nonatomic, retain) NSDate *latestPost;
@property (nonatomic, assign) BOOL pastDueLocked;
@property (nonatomic, assign) BOOL notYetOpen;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, retain) NSString *blockedBy;

@end

@implementation Topic

@synthesize topicId, title, author, numPosts, posts, postsLoaded, forum, unread, type;
@synthesize published, open, due, allowUntil, hideTillOpen, lockOnDue, graded, minPosts, points, readOnly, forumReadOnly, latestPost, pastDueLocked, notYetOpen;
@synthesize blocked, blockedBy;

#pragma mark - lifecycle

+ (Topic *) topicInForum:(Forum *)theForum forDef:(NSDictionary *)def
{
	NSString *theTopicId = [def objectForKey:@"topicId"];
	NSString *theTitle = [def objectForKey:@"title"];
	NSString *theAuthor = [def objectForKey:@"author"];
	NSNumber *theNumPosts = [def objectForKey:@"numPosts"];
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
	NSNumber *theReadOnly = [def objectForKey:@"readOnly"];
	NSNumber *theForumReadOnly = [def objectForKey:@"forumReadOnly"];
	NSNumber *theLatestPost = [def objectForKey:@"latestPost"];
	NSNumber *thePastDueLocked = [def objectForKey:@"pastDueLocked"];
	NSNumber *theNotYetOpen = [def objectForKey:@"notYetOpen"];
	NSString *theBlockedBy = [def objectForKey:@"blocked"];

	NSDate *open = nil;
	NSDate *due = nil;
	NSDate *allowUntil = nil;
	NSDate *latestPost = nil;
	if ([theOpen intValue] != 0) open = [NSDate dateWithTimeIntervalSince1970:[theOpen intValue]];
	if ([theDue intValue] != 0) due = [NSDate dateWithTimeIntervalSince1970:[theDue intValue]];
	if ([theAllowUntil intValue] != 0) allowUntil = [NSDate dateWithTimeIntervalSince1970:[theAllowUntil intValue]];
	if ([theLatestPost intValue] != 0) latestPost = [NSDate dateWithTimeIntervalSince1970:[theLatestPost intValue]];

	Topic *topic = [[Topic alloc] initInForum:theForum topicId:theTopicId title:theTitle author:theAuthor
									 numPosts:[theNumPosts intValue] unread:[theUnread boolValue] type:[theType intValue]
									published:[thePublished boolValue] open:open due:due allowUntil:allowUntil
								 hideTillOpen:[theHideTillOpen boolValue] lockOnDue:[theLockOnDue boolValue] graded:[theGraded boolValue]
									 minPosts:[theMinPosts intValue] points:[thePoints floatValue] readOnly:[theReadOnly boolValue]
								forumReadOnly:[theForumReadOnly boolValue] latestPost:latestPost pastDueLocked:[thePastDueLocked boolValue]
								   notYetOpen:[theNotYetOpen boolValue] blocked:(theBlockedBy != nil) blockedBy:theBlockedBy];
	return [topic autorelease];
}

- (id) initInForum:(Forum *)theForum topicId:(NSString *)theTopicId title:(NSString *)theTitle author:(NSString *)theAuthor
		  numPosts:(int)theNumPosts unread:(BOOL)theUnread type:(enum TopicType)theType  published:(BOOL)thePublished open:(NSDate *)theOpen
			   due:(NSDate *)theDue allowUntil:(NSDate *)theAllowUntil hideTillOpen:(BOOL)theHideTillOpen
		 lockOnDue:(BOOL)theLockOnDue graded:(BOOL)theGraded minPosts:(int)theMinPosts points:(float)thePoints
		  readOnly:(BOOL)theReadOnly forumReadOnly:(BOOL)theForumReadOnly latestPost:(NSDate *)theLatestPost pastDueLocked:(BOOL)thePastDueLocked
		notYetOpen:(BOOL)theNotYetOpen blocked:(BOOL)theBlocked blockedBy:(NSString *)theBlockedBy
{
	self = [super init];
    if (self)
	{
		self.forum = theForum;
		self.topicId = theTopicId;
		self.title = theTitle;
		self.author = theAuthor;
		self.numPosts = theNumPosts;
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
		self.readOnly = theReadOnly;
		self.forumReadOnly = theForumReadOnly;
		self.latestPost = theLatestPost;
		self.pastDueLocked = thePastDueLocked;
		self.notYetOpen = theNotYetOpen;
		self.blocked = theBlocked;
		self.blockedBy = theBlockedBy;
	}
	
    return self;
}

- (void)dealloc
{
	[topicId release];
	[title release];
	[author release];
	[posts release];
	[postsLoaded release];
	[open release];
	[due release];
	[allowUntil release];
	[latestPost release];
	[blockedBy release];

    [super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Topic id:%@ title:%@", self.topicId, self.title];
}

- (void) setPosts:(NSArray *)thePosts
{
	if (posts != thePosts)
	{
		[posts release];
		posts = nil;
		[postsLoaded release];
		postsLoaded = nil;
		
		if (thePosts != nil)
		{
			posts = [thePosts retain];
			
			// mark the date that the posts were loaded
			postsLoaded	= [[NSDate date] retain];
		}
	}
}

// mark this as read, and precolate that up to the forum if we have it
- (void) markAsRead
{
	// if already read, we are done
	if (!self.unread) return;
	
	// set un-unread
	self.unread = NO;
	
	// if we have a forum, ask it to re-calculate it's unread status
	if (self.forum != nil)
	{
		[self.forum updateUnread];
	}
}

// update to match values in the other
- (void) setToMatch:(Topic *)theOther
{
	// stay in the same forum, and keep the same id - don't mess with the posts
	self.title = theOther.title;
	self.author = theOther.author;
	self.numPosts = theOther.numPosts;
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
	self.readOnly = theOther.readOnly;
	self.forumReadOnly = theOther.forumReadOnly;
	self.latestPost = theOther.latestPost;
	self.pastDueLocked = theOther.pastDueLocked;
	self.notYetOpen = theOther.notYetOpen;
	self.blocked = theOther.blocked;
	self.blockedBy = theOther.blockedBy;
}

@end
