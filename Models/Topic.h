/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Topic.h $
 * $Id: Topic.h 2680 2012-02-22 03:37:24Z ggolden $
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
#import "Forum.h"

enum TopicType {regularTopic=0, announceTopic=1, stickyTopic=2, reuseTopic=3};

@interface Topic : NSObject
{
@protected
	Forum *forum;
	NSString *topicId;
	NSString *title;
	NSString *author;
	int numPosts;
	NSArray /* <Post> */ *posts;
	NSDate *postsLoaded;
	BOOL unread;
	enum TopicType type;
	BOOL published;
	NSDate *open;
	NSDate *due;
	NSDate *allowUntil;
	BOOL hideTillOpen;
	BOOL lockOnDue;
	BOOL graded;
	int minPosts;
	float points;
	BOOL readOnly;
	BOOL forumReadOnly;
	NSDate *latestPost;
	BOOL pastDueLocked;
	BOOL notYetOpen;
	BOOL blocked;
	NSString *blockedBy;
}

+ (Topic *) topicInForum:(Forum *)theForum forDef:(NSDictionary *)def;

@property (nonatomic, assign) Forum *forum;
@property (nonatomic, readonly, retain) NSString *topicId;
@property (nonatomic, readonly, retain) NSString *title;
@property (nonatomic, readonly, retain) NSString *author;
@property (nonatomic, readonly, assign) int numPosts;
@property (nonatomic, retain) NSArray *posts;
@property (nonatomic, readonly, retain) NSDate *postsLoaded;
@property (nonatomic, readonly, assign) BOOL unread;
@property (nonatomic, readonly, assign) enum TopicType type;
@property (nonatomic, readonly, assign) BOOL published;
@property (nonatomic, readonly, retain) NSDate *open;
@property (nonatomic, readonly, retain) NSDate *due;
@property (nonatomic, readonly, retain) NSDate *allowUntil;
@property (nonatomic, readonly, assign) BOOL hideTillOpen;
@property (nonatomic, readonly, assign) BOOL lockOnDue;
@property (nonatomic, readonly, assign) BOOL graded;
@property (nonatomic, readonly, assign) int minPosts;
@property (nonatomic, readonly, assign) float points;
@property (nonatomic, readonly, assign) BOOL readOnly;
@property (nonatomic, readonly, assign) BOOL forumReadOnly;
@property (nonatomic, readonly, retain) NSDate *latestPost;
@property (nonatomic, readonly, assign) BOOL pastDueLocked;
@property (nonatomic, readonly, assign) BOOL notYetOpen;
@property (nonatomic, readonly, assign) BOOL blocked;
@property (nonatomic, readonly, retain) NSString *blockedBy;

- (id) initInForum:(Forum *)theForum topicId:(NSString *)theTopicId title:(NSString *)theTitle author:(NSString *)theAuthor
		  numPosts:(int)theNumPosts unread:(BOOL)theUnread type:(enum TopicType)theType published:(BOOL)thePublished open:(NSDate *)theOpen
			   due:(NSDate *)theDue allowUntil:(NSDate *)theAllowUntil hideTillOpen:(BOOL)theHideTillOpen
		 lockOnDue:(BOOL)theLockOnDue graded:(BOOL)theGraded minPosts:(int)theMinPosts points:(float)thePoints
		  readOnly:(BOOL)theReadOnly forumReadOnly:(BOOL)theForumReadOnly latestPost:(NSDate *)theLatestPost pastDueLocked:(BOOL)thePastDueLocked
		notYetOpen:(BOOL)theNotYetOpen blocked:(BOOL)theBlocked blockedBy:(NSString *)theBlockedBy;

// mark this as read, and precolate that up to the forum if we have it
- (void) markAsRead;

// update to match values in the other
- (void) setToMatch:(Topic *)theOther;

@end
