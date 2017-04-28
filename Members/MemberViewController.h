/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/MemberViewController.h $
 * $Id: MemberViewController.h 2172 2011-10-30 20:43:12Z ggolden $
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

#import <UIKit/UIKit.h>
#import "Site.h"
#import "Delegates.h"
#import "Member.h"
#import <MessageUI/MessageUI.h>

@interface MemberViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
{
@protected
	Site *site;
	id <EtudesServerSessionDelegate> sessionDelegate;
	Member *member;
	NSArray /* <Member> */ *members;
	NSString *memberId;
	
	IBOutlet UIImageView *avatar;
	IBOutlet UILabel *name;
	IBOutlet UILabel *role;
	IBOutlet UILabel *iid;
	IBOutlet UITableView *list;
	IBOutlet UIActivityIndicatorView *avatarLoading;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIActivityIndicatorView *busy;
	IBOutlet UIImageView *statusIcon;

	BOOL canSendEmail;
	NSArray *cells;
	NSArray *actions;
}

// The designated initializer - with a member  
- (id)initWithMember:(Member *)member fromList:(NSArray *)members site:(Site *)site delegates:(id <Delegates>)delegates;

// The designated initializer - with just a member id  
- (id)initWithMemberId:(NSString *)memberId site:(Site *)site delegates:(id <Delegates>)delegates;

// send a PM
- (IBAction) sendMessage;

// send email to the user's email address
- (void) sendEmail;

// load the user's website
- (void) visitWebsite;

// send to facebook
- (void) sendFacebook;

// send to twitter
- (void) sendTwitter;

@end
