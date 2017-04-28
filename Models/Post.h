/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Post.h $
 * $Id: Post.h 2680 2012-02-22 03:37:24Z ggolden $
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

#import <Foundation/Foundation.h>


@interface Post : NSObject
{
@protected
	NSString *subject;
	NSDate *date;
	NSDate *revised;
	NSString *postId;
	NSString *from;
	NSString *fromUserId;
	NSString *body;
	NSString *avatar;
	BOOL fromInstructor;
	BOOL mayEdit;
}

+ (Post *)postForDef:(NSDictionary *)def;

@property (nonatomic, readonly, retain) NSString *subject;
@property (nonatomic, readonly, retain) NSDate *date;
@property (nonatomic, readonly, retain) NSDate *revised;
@property (nonatomic, readonly, retain) NSString *postId;
@property (nonatomic, readonly, retain) NSString *from;
@property (nonatomic, readonly, retain) NSString *fromUserId;
@property (nonatomic, readonly, retain) NSString *body;
@property (nonatomic, readonly, retain) NSString *avatar;
@property (nonatomic, readonly, assign) BOOL fromInstructor;
@property (nonatomic, readonly, assign) BOOL mayEdit;

- (id) initWithId:(NSString *)theId subject:(NSString *)theSubject date:(NSDate *)theDate revised:(NSDate *)theRevisedDate from:(NSString *)theFrom
	   fromUserId:(NSString *)theFromUserId body:(NSString *)theBody avatar:(NSString *)theAvatar
   fromInstructor:(BOOL)theFromInstructor mayEdit:(BOOL)theMayEdit;

// take new values from the update
//- (void) updateWithMessage:(ETMessage *)update;

@end
