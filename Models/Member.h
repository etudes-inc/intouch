/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Member.h $
 * $Id: Member.h 2634 2012-02-10 01:37:16Z ggolden $
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

enum ParticipantStatus
{
	enrolled_participantStatus,
	blocked_participantStatus,
	dropped_participantStatus,
	hat_participantStatus
};

@interface Member : NSObject
{
@protected
    NSString *userId;
	NSString *displayName;
	BOOL showEmail;
	NSString *email;
	NSString *avatar;
	NSString *role;
	NSString *website;
	NSString *msn;
	NSString *yahoo;
	NSString *facebook;
	NSString *twitter;
	NSString *occupation;
	NSString *interests;
	NSString *aim;
	NSString *location;
	enum ParticipantStatus status;
	NSString *iid;
	BOOL online;
	BOOL inChat;
	BOOL isLoginUser;
}

+ (Member *) memberForDef:(NSDictionary *)def;

+ (enum ParticipantStatus) participantStatusForDef:(NSNumber *)def;

@property (nonatomic, readonly, retain) NSString *userId;
@property (nonatomic, readonly, retain) NSString *displayName;
@property (nonatomic, readonly, assign) BOOL showEmail;
@property (nonatomic, readonly, retain) NSString *email;
@property (nonatomic, readonly, retain) NSString *avatar;
@property (nonatomic, readonly, retain) NSString *role;
@property (nonatomic, readonly, retain) NSString *website;
@property (nonatomic, readonly, retain) NSString *msn;
@property (nonatomic, readonly, retain) NSString *yahoo;
@property (nonatomic, readonly, retain) NSString *facebook;
@property (nonatomic, readonly, retain) NSString *twitter;
@property (nonatomic, readonly, retain) NSString *occupation;
@property (nonatomic, readonly, retain) NSString *interests;
@property (nonatomic, readonly, retain) NSString *aim;
@property (nonatomic, readonly, retain) NSString *location;
@property (nonatomic, readonly, assign) enum ParticipantStatus status;
@property (nonatomic, readonly, retain) NSString *iid;
@property (nonatomic, readonly, assign) BOOL online;
@property (nonatomic, readonly, assign) BOOL inChat;
@property (nonatomic, readonly, assign) BOOL isLoginUser;

// check if the member is active, not blocked or dropped
@property (nonatomic, readonly) BOOL active;

- (id) initWithId:(NSString *)theId displayName:(NSString *)theName showEmail:(BOOL)theShowEmail
			email:(NSString *)theEmail avatar:(NSString *)theAvatar role:(NSString *)theRole website:(NSString *)theWebsite
			  msn:(NSString *)theMsn yahoo:(NSString *)theYahoo facebook:(NSString *)theFacebook twitter:(NSString *)theTwitter
	   occupation:(NSString *)theOccupation interests:(NSString *)theInterests aim:(NSString *)theAim location:(NSString *)theLocation
		   status:(enum ParticipantStatus)theStatus iid:(NSString *)theIid online:(BOOL)theOnline inChat:(BOOL)theInChat isLoginUser:(BOOL)theIsLoginUser;

@end
