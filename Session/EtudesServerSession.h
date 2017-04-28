/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Session/EtudesServerSession.h $
 * $Id: EtudesServerSession.h 2707 2012-02-29 01:16:46Z ggolden $
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
#import "SessionStuff.h"
#import "Site.h"
#import "Forum.h"
#import "Topic.h"
#import "PreferencesDelegate.h"
#import "Member.h"

@class EtudesServerSession;

@protocol EtudesServerSessionDelegate

- (EtudesServerSession *) session;
- (void) authenticateOverViewController:(UIViewController *)viewController completion:(completion_block_s)block;
- (void) helpFromViewController:(UIViewController *)viewController title:(NSString *)title url:(NSURL *)url;

@end

/*
 An Etudes Server Session object is used to communicate with an Etudes Server.
 Requests are made of the server for various packages of data.
 Information updates are sent to the server.
 The user has to login before using anything else in the session.
 The user must logoff when done.
 */
@interface EtudesServerSession : NSObject
{
@protected
	// logged in
	BOOL active;

	// URL to the root of the server (dns, port)
	NSURL *serverUrl;
	NSString *serverProtocol;
	NSString *serverHost;
	NSInteger serverPort;

	// version information
	NSString *version;
	NSString *build;

	// authenticated user id, internal id, password and email
	NSString *userId;
	NSString *internalUserId;
	NSString *password;
	NSString *email;

	// Site Members cache
	NSArray /* <Member> */ *cachedSiteMembers;
	NSString *cachedSiteMembersSiteId;
	NSString *cachedSiteMembersUserId;

	id <PreferencesDelegate> preferencesDelegate;
	
	int networkCount;
}

// check if logged in (YES) or not (NO)
@property (nonatomic, assign, readonly) BOOL active;
@property (nonatomic, retain, readonly) NSString *internalUserId;
@property (nonatomic, retain, readonly) NSURL *serverUrl;
@property (nonatomic, retain, readonly) NSString *serverProtocol;
@property (nonatomic, retain, readonly) NSString *serverHost;
@property (nonatomic, assign, readonly) NSInteger serverPort;
@property (nonatomic, retain, readonly) NSString *email;
@property (nonatomic, retain, readonly) NSString *version;
@property (nonatomic, retain, readonly) NSString *build;

// construct with the server components
- (id) initWithProtocol:(NSString *)theProtocol host:(NSString *)theHost port:(NSInteger)thePort
			preferences:(id <PreferencesDelegate>)preferencesDelegate
				version:(NSString *)theVersion build:(NSString *)theBuild;

// attempt a login based on stored user preference info, checking that the preferences site is still valid for the user
// authentication is asynchronous - runs one of the completion blocks when done:
// if user login works, and the internal id matches, and the site is valid for the user, block2
// if the login works, an the internal id matches, but the site is no longer valid for the user, block1
// if the login fails or the user id has changed, block0
- (void) authenticateFromPreferences:(completion_block_s)block0 badSite:(completion_block_s)block1 success:(completion_block_s)block2;

// completion parameters are:
// - 
- (BOOL) loginAsUser:(NSString *)userId password:(NSString *)password completion:(completion_block_s)block;

// login as a user with a password - return YES if successful
// login is asynchronous - runs completion block when done
// completion parameters are:
// - 
- (BOOL) loginAsUser:(NSString *)userId password:(NSString *)password completion:(completion_block_s)block;

// logout
// logout is immediate
- (BOOL) logout;

// get the current user's list of sites
// asynchronous - runs the completion block with the Sites in the array when done
- (BOOL) getSites:(completion_block_sa)block;

// get the announcements for the site
// asynchronous - runs the completion block with the Announcements in the array when done
- (BOOL) getAnnouncementsForSite:(Site *)site limit:(NSInteger)limit completion:(completion_block_sa)block;

// get a news item by this id, possibly converted into plain text
// asynchronous - runs the completion block with the ETMessage in the dictionary entry "message" when done
- (BOOL) getNewsInSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block plainText:(BOOL)plainText;

// get the chat messages for the site
// asynchronous - runs the completion block with the Announcements in the array when done
- (BOOL) getChatForSite:(Site *)site lastSeenMessageId:(NSString *)lastSeenMessageId completion:(completion_block_sd)block;

// get the private messages for the site
// asynchronous - runs the completion block with the Announcements in the array when done
- (BOOL) getPrivateMessagesForSite:(Site *)site limit:(NSInteger)limit completion:(completion_block_sa)block;

// get a private message by this id, possibly converted into plain text
// asynchronous - runs the completion block with the ETMessage in the dictionary entry "message" when done
- (BOOL) getMessageInSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block plainText:(BOOL)plainText;

// get the discussion categories and forums for the site, with chat info
// asynchronous - runs the completion block with the arrays of categories, chat name and presence in the dictionary
- (BOOL) getForumsForSite:(Site *)site category:(NSString *)categoryId completion:(completion_block_sd)block;

// get the CourseMap for the site
// asynchronous - runs the completion block with the dictionary with "courseMap" item containing the CourseMap.
- (BOOL) getCourseMapForSite:(Site *)site forUserId:(NSString *)forUserId completion:(completion_block_sd)block;

// get the Module for the site
// asynchronous - runs the completion block with the dictionary with "module" item containing the module.
- (BOOL) getModuleForSite:(Site *)site moduleId:(NSString *)moduleId completion:(completion_block_sd)block;

// get the Activity Meter Overview for the site
// asynchronous - runs the completion block with the dictionary with "activity" item containing the AM overview items.
- (BOOL) getActivityForSite:(Site *)site completion:(completion_block_sd)block;

// get the topics for the forum - also getting the updated forum object
// asynchronous - runs the completion block with the arrays of actual items in the dictionary by item group name.
- (BOOL) getTopicsForForumId:(NSString *)forumId site:(Site *)site completion:(completion_block_sd)block;

// get the recent topics for the site
// asynchronous - runs the completion block with the arrays of actual items in the dictionary by item group name.
- (BOOL) getRecentTopicsForSite:(Site *)site completion:(completion_block_sa)block;

// get the posts for a topic: marks the topic as read - also delivers an updated topic and forum
// asynchronous - runs the completion block when done
- (BOOL) getPosts:(NSString *)topicId site:(Site *)site completion:(completion_block_sd)block;

// get the plain text body for a post
// asynchronous - runs the completion block when done
- (BOOL) getPostBody:(Site *)site postId:(NSString *)postId completion:(completion_block_sd)block;

// get the quoted, plain text body for a post
// asynchronous - runs the completion block when done
- (BOOL) getPostBodyQuote:(Site *)site postId:(NSString *)postId completion:(completion_block_sd)block;

// get the members for the site.  if refresh, get new data from the server, else consider using cached
// asynchronous - runs the completion block with the Members in the array when done
- (BOOL) getMembersForSite:(Site *)site refresh:(BOOL)refresh completion:(completion_block_sa)block;

// send an edit to a post
// asynchronous - runs the completion block with the status when done
- (BOOL) sendEditToPost:(NSString *)postId site:(Site *)site
				 subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText;

// send a post as a reply to another post in the topic
// asynchronous - runs the completion block with the status when done
- (BOOL) sendReplyToPost:(NSString *)postId topic:(Topic *)topic site:(Site *)site
				 subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText;

// send a post
// asynchronous - runs the completion block with the status when done
- (BOOL) sendPostToTopic:(Topic *)topic site:(Site *)site
				 subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText;

// send a topic
// asynchronous - runs the completion block with the status when done
- (BOOL) sendTopicToForum:(Forum *)forum site:(Site *)site
				  subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText;

// send a chat message
// asynchronous - runs the completion block with the status when done
- (BOOL) sendChatForSite:(Site *)site body:(NSString *)body completion:(completion_block_s)block;

// send a Private Message (body may be in plain text)
// asynchronous - runs the completion block with the status when done
- (BOOL) sendPrivateMessageTo:(NSArray *)to site:(Site *)site
					  subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText;

// send a Private Message reply (body may be in plain text)
// asynchronous - runs the completion block with the status when done
- (BOOL) sendPrivateMessageReplyTo:(NSString *)messageId site:(Site *)site
					  subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText;

// send a new news item
// asynchronous - runs the completion block with the status when done
- (BOOL) sendNewNewsForSite:(Site *)site subject:(NSString *)subject
					   body:(NSString *)body draft:(BOOL)draft priority:(BOOL)priority completion:(completion_block_s)block plainText:(BOOL)plainText;

// send an updated news item
// asynchronous - runs the completion block with the status and the updated message when done
- (BOOL) sendUpdatedNewsForSite:(Site *)site messageId:(NSString *)messageId subject:(NSString *)subject body:(NSString *)body
						  draft:(BOOL)draft priority:(BOOL)priority completion:(completion_block_sd)block plainText:(BOOL)plainText;

// send an acceptance for syllabus
// asynchronous - runs the completion block with the status when done
- (BOOL) sendSyllabusAcceptance:(Site *)site completion:(completion_block_s)block;

// delete a private message
// asynchronous - runs the completion block with the status when done
- (BOOL) deleteMessageForSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block;

// delete a post
// asynchronous - runs the completion block with the status when done
- (BOOL) deletePostForSite:(Site *)site postId:(NSString *)postId completion:(completion_block_sd)block;

// delete a news item
// asynchronous - runs the completion block with the status when done
- (BOOL) deleteNewsForSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block;

// delete a chat message
// asynchronous - runs the completion block with the status when done
- (BOOL) deleteChatForSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block;

// test
- (BOOL) test:(completion_block_sd)block;

// pull the basic authorization header value for other requests
// set with:  [request setValue:[self.sessionDelegate.session basicAuthHeaderValue] forHTTPHeaderField:@"Authorization"];
- (NSString *) basicAuthHeaderValue;

// load a user avatar image from the server
- (BOOL) loadAvatarImage:(NSString *)avatarPath completion:(completion_block_i) block;

// there is network activity - make sure the spinner is spinning - balance with a call to endNetworkActivity
- (void) startNetworkActivity;

// network activity is ended, remove the spinner if there is no other network activity
- (void) endNetworkActivity;

// inform the user that we had trouble loading something from the server
- (void) alertServerCommunicationsTrouble;

@end
