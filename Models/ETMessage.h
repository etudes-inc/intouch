/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ETMessage.h $
 * $Id: ETMessage.h 2672 2012-02-16 21:22:54Z ggolden $
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


@interface ETMessage : NSObject
{
@protected
	NSString *subject;
	NSDate *date;
	NSDate *revised;
	NSString *messageId;
	NSString *from;
	NSString *fromUserId;
	NSString *bodyPath;
	NSString *body;
	NSString *avatar;
	BOOL unread;
	NSDate *releaseDate;
	BOOL draft;
	BOOL priority;
	BOOL replied;
}

+ (ETMessage *) messageForDef:(NSDictionary *)def;

@property (nonatomic, readonly, retain) NSString *subject;
@property (nonatomic, readonly, retain) NSDate *date;
@property (nonatomic, readonly, retain) NSDate *revised;
@property (nonatomic, readonly, retain) NSString *messageId;
@property (nonatomic, readonly, retain) NSString *from;
@property (nonatomic, readonly, retain) NSString *fromUserId;
@property (nonatomic, readonly, retain) NSString *bodyPath;
@property (nonatomic, readonly, retain) NSString *body;
@property (nonatomic, readonly, retain) NSString *avatar;
@property (nonatomic, readonly, assign) BOOL unread;
@property (nonatomic, readonly, retain) NSDate *releaseDate;
@property (nonatomic, readonly, assign) BOOL draft;
@property (nonatomic, readonly, assign) BOOL priority;
@property (nonatomic, readonly, assign) BOOL released;
@property (nonatomic, readonly, assign) BOOL fromInstructor;
@property (nonatomic, readonly, assign) BOOL replied;

- (id) initWithId:(NSString *)theId subject:(NSString *)theSubject date:(NSDate *)theDate revised:(NSDate *)theRevisedDate from:(NSString *)theFrom
	   fromUserId:(NSString *)theFromUserId bodyPath:(NSString *)theBodyPath body:(NSString *)theBody avatar:(NSString *)theAvatar
		   unread:(BOOL)theUnread releaseDate:(NSDate *)theReleaseDate draft:(BOOL)theDraft priority:(BOOL)thePriority
   fromInstructor:(BOOL)theFromInstructor replied:(BOOL)theReplied;

// take new values from the update
- (void) updateWithMessage:(ETMessage *)update;

// mark this as read
- (void) markAsRead;

// mark this as replied
- (void) markAsReplied;

@end
