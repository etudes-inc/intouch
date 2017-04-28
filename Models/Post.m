/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Post.m $
 * $Id: Post.m 2680 2012-02-22 03:37:24Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2012 Etudes, Inc.
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

#import "Post.h"


@interface Post()

@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *revised;
@property (nonatomic, retain) NSString *postId;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *fromUserId;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, assign) BOOL fromInstructor;
@property (nonatomic, assign) BOOL mayEdit;

@end

@implementation Post

@synthesize subject, date, revised, postId, from, fromUserId, body, avatar, fromInstructor, mayEdit;

#pragma mark - lifecycle

- (id) initWithId:(NSString *)theId subject:(NSString *)theSubject date:(NSDate *)theDate revised:(NSDate *)theRevisedDate from:(NSString *)theFrom
	   fromUserId:(NSString *)theFromUserId body:(NSString *)theBody avatar:(NSString *)theAvatar
   fromInstructor:(BOOL)theFromInstructor mayEdit:(BOOL)theMayEdit
{
	self = [super init];
    if (self)
	{
		self.postId	= theId;
		self.subject = theSubject;
		self.date = theDate;
		self.revised = theRevisedDate;
		self.from = theFrom;
		self.fromUserId = theFromUserId;
		self.body = theBody;
		self.avatar = theAvatar;
		self.fromInstructor = theFromInstructor;
		self.mayEdit= theMayEdit;
	}
	
    return self;
}

- (void)dealloc
{
	[postId release];
	[subject release];
	[date release];
	[revised release];
	[from release];
	[fromUserId release];
	[body release];
	[avatar release];
	
    [super dealloc];
}

+ (Post *) postForDef:(NSDictionary *)def
{
	NSString *thePostId = [def objectForKey:@"postId"];
	NSString *theSubject = [def objectForKey:@"subject"];
	NSNumber *theDate = [def objectForKey:@"date"];
	NSNumber *theRevisedDate = [def objectForKey:@"revised"];
	NSString *theFrom = [def objectForKey:@"from"];
	NSString *theFromUserId = [def objectForKey:@"fromUserId"];
	NSString *theBody = [def objectForKey:@"body"];
	NSString *theAvatar = [def objectForKey:@"avatar"];
	NSNumber *theFromInstructor = [def objectForKey:@"fromInstructor"];
	NSNumber *theMayEdit = [def objectForKey:@"mayEdit"];

	NSDate *date = nil;
	NSDate *revised = nil;
	if ([theDate intValue] != 0) date = [NSDate dateWithTimeIntervalSince1970:[theDate intValue]];
	if ([theRevisedDate intValue] != 0) revised = [NSDate dateWithTimeIntervalSince1970:[theRevisedDate intValue]];

	Post *post = [[Post alloc] initWithId:thePostId subject:theSubject date:date revised:revised from:theFrom fromUserId:theFromUserId
											  body:theBody avatar:theAvatar
										fromInstructor:[theFromInstructor boolValue] mayEdit:[theMayEdit boolValue]];
	return [post autorelease];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Post id:%@ subject:%@ date:%@ from:%@",
			self.postId, self.subject, self.date, self.from];
}

@end
