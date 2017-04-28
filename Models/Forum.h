/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Forum.h $
 * $Id: Forum.h 2373 2011-12-16 21:52:43Z ggolden $
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
#import "Category.h"

enum ForumType {regularForum=0, replyOnlyForum=1, readOnlyForum=2};

@interface Forum : NSObject
{
@protected
	Category *category;
	NSString *forumId;
	NSString *title;
	NSString *forumDescription;
	int numTopics;
	// TODO: status
	NSArray /* <Topic> */ *topics;
	NSDate *topicsLoaded;
	BOOL unread;
	enum ForumType type;
	BOOL published;
	NSDate *open;
	NSDate *due;
	NSDate *allowUntil;
	BOOL hideTillOpen;
	BOOL lockOnDue;
	BOOL graded;
	int minPosts;
	float points;
	BOOL pastDueLocked;
	BOOL notYetOpen;
	BOOL blocked;
	NSString *blockedBy;
}

+ (Forum *) forumInCategory:(Category *)theCategory forDef:(NSDictionary *)def;

@property (nonatomic, readonly, assign) Category *category;
@property (nonatomic, readonly, retain) NSString *forumId;
@property (nonatomic, readonly, retain) NSString *title;
@property (nonatomic, readonly, retain) NSString *forumDescription;
@property (nonatomic, readonly, assign) int numTopics;
@property (nonatomic, retain) NSArray /* <Topic> */ *topics;
@property (nonatomic, readonly, retain) NSDate *topicsLoaded;
@property (nonatomic, readonly, assign) BOOL unread;
@property (nonatomic, readonly, assign) enum ForumType type;
@property (nonatomic, readonly, assign) BOOL published;
@property (nonatomic, readonly, retain) NSDate *open;
@property (nonatomic, readonly, retain) NSDate *due;
@property (nonatomic, readonly, retain) NSDate *allowUntil;
@property (nonatomic, readonly, assign) BOOL hideTillOpen;
@property (nonatomic, readonly, assign) BOOL lockOnDue;
@property (nonatomic, readonly, assign) BOOL graded;
@property (nonatomic, readonly, assign) int minPosts;
@property (nonatomic, readonly, assign) float points;
@property (nonatomic, readonly, assign) BOOL pastDueLocked;
@property (nonatomic, readonly, assign) BOOL notYetOpen;
@property (nonatomic, readonly, assign) BOOL blocked;
@property (nonatomic, readonly, retain) NSString *blockedBy;

- (id) initInCategory:(Category *)theCategory forumId:(NSString *)theForumId title:(NSString *)theTitle description:(NSString *)theDescription
			numTopics:(int)theNumTopics unread:(BOOL)theUnread type:(enum ForumType)theType published:(BOOL)thePublished open:(NSDate *)theOpen
				  due:(NSDate *)theDue allowUntil:(NSDate *)theAllowUntil hideTillOpen:(BOOL)theHideTillOpen
			lockOnDue:(BOOL)theLockOnDue graded:(BOOL)theGraded minPosts:(int)theMinPosts points:(float)thePoints pastDueLocked:(BOOL)thePastDueLocked
		   notYetOpen:(BOOL)theNotYetOpen blocked:(BOOL)theBlocked blockedBy:(NSString *)theBlockedBy;

// reset our unread indicator based on the read status of our loaded topics
- (void) updateUnread;

// update to match values in the other
- (void) setToMatch:(Forum *)theOther;

@end
