/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ETMessage.m $
 * $Id: ETMessage.m 2672 2012-02-16 21:22:54Z ggolden $
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

#import "ETMessage.h"


@interface ETMessage()

@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *revised;
@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *fromUserId;
@property (nonatomic, retain) NSString *bodyPath;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, retain) NSDate *releaseDate;
@property (nonatomic, assign) BOOL draft;
@property (nonatomic, assign) BOOL priority;
@property (nonatomic, assign) BOOL fromInstructor;
@property (nonatomic, assign) BOOL replied;
@end

@implementation ETMessage

@synthesize subject, date, revised, messageId, from, fromUserId, bodyPath, body, avatar, unread, draft, priority, releaseDate, fromInstructor, replied;

#pragma mark - lifecycle

- (id) initWithId:(NSString *)theId subject:(NSString *)theSubject date:(NSDate *)theDate revised:(NSDate *)theRevisedDate from:(NSString *)theFrom
	   fromUserId:(NSString *)theFromUserId bodyPath:(NSString *)theBodyPath body:(NSString *)theBody avatar:(NSString *)theAvatar
		   unread:(BOOL)theUnread releaseDate:(NSDate *)theReleaseDate draft:(BOOL)theDraft priority:(BOOL)thePriority
   fromInstructor:(BOOL)theFromInstructor  replied:(BOOL)theReplied
{
	self = [super init];
    if (self)
	{
		self.messageId	= theId;
		self.subject = theSubject;
		self.date = theDate;
		self.revised = theRevisedDate;
		self.from = theFrom;
		self.fromUserId = theFromUserId;
		self.bodyPath = theBodyPath;
		self.body = theBody;
		self.avatar = theAvatar;
		self.unread = theUnread;
		self.releaseDate = theReleaseDate;
		self.draft = theDraft;
		self.priority = thePriority;
		self.fromInstructor = theFromInstructor;
		self.replied = theReplied;
	}
	
    return self;
}

- (void)dealloc
{
	[messageId release];
	[subject release];
	[date release];
	[revised release];
	[from release];
	[fromUserId release];
	[bodyPath release];
	[body release];
	[avatar release];
	[releaseDate release];
	
    [super dealloc];
}

+ (ETMessage *) messageForDef:(NSDictionary *)def
{
	NSString *theMessageId = [def objectForKey:@"messageId"];
	NSString *theSubject = [def objectForKey:@"subject"];
	NSNumber *theDate = [def objectForKey:@"date"];
	NSNumber *theRevisedDate = [def objectForKey:@"revised"];
	NSString *theFrom = [def objectForKey:@"from"];
	NSString *theFromUserId = [def objectForKey:@"fromUserId"];
	NSString *theBodyPath = [def objectForKey:@"bodyPath"];
	NSString *theBody = [def objectForKey:@"body"];
	NSString *theAvatar = [def objectForKey:@"avatar"];
	NSNumber *theUnread = [def objectForKey:@"unread"];
	NSNumber *theReleaseDate = [def objectForKey:@"releaseDate"];
	NSNumber *theDraft = [def objectForKey:@"draft"];
	NSNumber *thePriority = [def objectForKey:@"priority"];
	NSNumber *theFromInstructor = [def objectForKey:@"fromInstructor"];
	NSNumber *theReplied = [def objectForKey:@"replied"];

	NSDate *date = nil;
	NSDate *revised = nil;
	NSDate *releaseDate = nil;
	if ([theDate intValue] != 0) date = [NSDate dateWithTimeIntervalSince1970:[theDate intValue]];
	if ([theRevisedDate intValue] != 0) revised = [NSDate dateWithTimeIntervalSince1970:[theRevisedDate intValue]];
	if ([theReleaseDate intValue] != 0) releaseDate = [NSDate dateWithTimeIntervalSince1970:[theReleaseDate intValue]];

	ETMessage *message = [[ETMessage alloc] initWithId:theMessageId subject:theSubject date:date revised:revised from:theFrom fromUserId:theFromUserId
											  bodyPath:theBodyPath body:theBody avatar:theAvatar unread:[theUnread boolValue] releaseDate:releaseDate
												 draft:[theDraft boolValue] priority:[thePriority boolValue]
										fromInstructor:[theFromInstructor boolValue] replied:[theReplied boolValue]];
	return [message autorelease];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Message id:%@ subject:%@ date:%@ from:%@",
			self.messageId, self.subject, self.date, self.from];
}

- (BOOL) released
{
	if (self.releaseDate == nil) return YES;
	
	NSDate *now = [NSDate date];
	// if now is earlier than the release date
	if ([now compare:self.releaseDate] == NSOrderedAscending)
	{
		return NO;
	}
	
	return YES;
}

// mark this as read
- (void) markAsRead
{
	// if already read, we are done
	if (!self.unread) return;
	
	// set un-unread
	self.unread = NO;
}

// mark this as replied
- (void) markAsReplied
{
	// if already replied, we are done
	if (self.replied) return;
	
	// set replied
	self.replied = YES;
}

// take new values from the update
- (void) updateWithMessage:(ETMessage *)update
{
	self.messageId	= update.messageId;
	self.subject = update.subject;
	self.date = update.date;
	self.revised = update.revised;
	self.from = update.from;
	self.fromUserId = update.fromUserId;
	self.bodyPath = update.bodyPath;
	self.body = update.body;
	self.avatar = update.avatar;
	self.unread = update.unread;
	self.releaseDate = update.releaseDate;
	self.draft = update.draft;
	self.priority = update.priority;
	self.fromInstructor = update.fromInstructor;
	self.replied = update.replied;
}

@end
