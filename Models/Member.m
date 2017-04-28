/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Member.m $
 * $Id: Member.m 2634 2012-02-10 01:37:16Z ggolden $
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

#import "Member.h"

@interface Member()

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, assign) BOOL showEmail;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *role;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *msn;
@property (nonatomic, retain) NSString *yahoo;
@property (nonatomic, retain) NSString *facebook;
@property (nonatomic, retain) NSString *twitter;
@property (nonatomic, retain) NSString *occupation;
@property (nonatomic, retain) NSString *interests;
@property (nonatomic, retain) NSString *aim;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, assign) enum ParticipantStatus status;
@property (nonatomic, retain) NSString *iid;
@property (nonatomic, assign) BOOL online;
@property (nonatomic, assign) BOOL inChat;
@property (nonatomic, assign) BOOL isLoginUser;

@end

@implementation Member

@synthesize userId, displayName, showEmail, email, avatar, role, website;
@synthesize msn, yahoo, facebook, twitter, occupation, interests, aim, location, status, iid;
@synthesize online, inChat, isLoginUser;

+ (Member *) memberForDef:(NSDictionary *)def
{
	NSString *theId = [def objectForKey:@"userId"];
	NSString *theName = [def objectForKey:@"displayName"];
	NSString *theEmail = [def objectForKey:@"email"];
	NSString *theAvatar = [def objectForKey:@"avatar"];
	NSString *theRole = [def objectForKey:@"role"];
	NSNumber *theShowEmail = [def objectForKey:@"showEmail"];
	NSString *theWebSite = [def objectForKey:@"website"];
	NSString *theMsn = [def objectForKey:@"msn"];
	NSString *theYahoo = [def objectForKey:@"yahoo"];
	NSString *theFacebook = [def objectForKey:@"facebook"];
	NSString *theTwitter = [def objectForKey:@"twitter"];
	NSString *theOccupation = [def objectForKey:@"occupation"];
	NSString *theInterests = [def objectForKey:@"interests"];
	NSString *theAim = [def objectForKey:@"aim"];
	NSString *theLocation = [def objectForKey:@"location"];
	enum ParticipantStatus theStatus = [Member participantStatusForDef:[def objectForKey:@"status"]];
	NSString *theIid = [def objectForKey:@"iid"];
	
	NSNumber *the_onLine = [def objectForKey:@"online"];
	BOOL theOnline = [the_onLine boolValue];

	NSNumber *the_inChat = [def objectForKey:@"inChat"];
	BOOL theInChat = [the_inChat boolValue];

	NSNumber *the_isLoginUser = [def objectForKey:@"isLoginUser"];
	BOOL theIsLoginUser = [the_isLoginUser boolValue];

	Member *member = [[Member alloc] initWithId:theId displayName:theName showEmail:[theShowEmail boolValue]
										  email:theEmail avatar:theAvatar role:theRole website:theWebSite
											msn:theMsn yahoo:theYahoo facebook:theFacebook twitter:theTwitter
									 occupation:theOccupation interests:theInterests aim:theAim
									   location:theLocation status:theStatus iid:theIid online:theOnline inChat:theInChat isLoginUser:theIsLoginUser];

	return [member autorelease];
}

+ (enum ParticipantStatus) participantStatusForDef:(NSNumber *)def
{
	enum ParticipantStatus theStatus = enrolled_participantStatus;
	switch ([def intValue])
	{
		case 1:
			theStatus = blocked_participantStatus;
			break;
			
		case 2:
			theStatus = dropped_participantStatus;
			break;
		
		case 999:
			theStatus = hat_participantStatus;
			break;
	}
	
	return theStatus;
}

- (id) initWithId:(NSString *)theId displayName:(NSString *)theName showEmail:(BOOL)theShowEmail
			email:(NSString *)theEmail avatar:(NSString *)theAvatar role:(NSString *)theRole website:(NSString *)theWebsite
			  msn:(NSString *)theMsn yahoo:(NSString *)theYahoo facebook:(NSString *)theFacebook twitter:(NSString *)theTwitter
	   occupation:(NSString *)theOccupation interests:(NSString *)theInterests aim:(NSString *)theAim location:(NSString *)theLocation
		   status:(enum ParticipantStatus)theStatus iid:(NSString *)theIid online:(BOOL)theOnline inChat:(BOOL)theInChat
	  isLoginUser:(BOOL)theIsLoginUser
{
	self = [super init];
    if (self)
	{
		self.userId = theId;
		self.displayName = theName;
		self.showEmail = theShowEmail;
		self.email = theEmail;
		self.avatar = theAvatar;
		self.role = theRole;
		self.website = theWebsite;
		self.msn = theMsn;
		self.yahoo = theYahoo;
		self.facebook = theFacebook;
		self.twitter = theTwitter;
		self.occupation = theOccupation;
		self.interests = theInterests;
		self.aim = theAim;
		self.location = theLocation;
		self.status = theStatus;
		self.iid = theIid;
		self.online = theOnline;
		self.inChat = theInChat;
		self.isLoginUser = theIsLoginUser;
	}
	
    return self;	
}

- (void)dealloc
{
	[userId release];
	[displayName release];
	[email release];
	[avatar	release];
	[role release];
	[website release];
	[msn release];
	[yahoo release];
	[facebook release];
	[twitter release];
	[occupation release];
	[interests release];
	[aim release];
	[location release];
	
    [super dealloc];
}
- (BOOL) active
{
	return ((self.status == enrolled_participantStatus) || (self.status == hat_participantStatus));
}

@end
