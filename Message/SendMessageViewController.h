/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Message/SendMessageViewController.h $
 * $Id: SendMessageViewController.h 2694 2012-02-25 02:43:46Z ggolden $
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

#import <UIKit/UIKit.h>
#import "Delegates.h"

// completion block
typedef void (^completion_block_SendMessageViewController)(NSArray /* NSString */ *userIds, NSString *replyToMessageId,
														   NSString *subject, NSString *body);

@interface SendMessageViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
@protected
	Site *site;
	id<Delegates> delegates;
	completion_block_SendMessageViewController completion;
  
	IBOutlet UIScrollView *scroll;
	IBOutlet UILabel *toField;
	IBOutlet UITextField *subjectField;
	IBOutlet UITextView *bodyField;
	IBOutlet UIActivityIndicatorView *busy;
	UIBarButtonItem *sendButton;
	UIBarButtonItem *cancelButton;

	NSString *replyToMessageId;
	NSMutableArray /* NSString */ *toUserIds;
	NSMutableArray /* NSString */ *toDisplayNames;
}

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_SendMessageViewController)block;

// Init with a recipient
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates  whenDone:(completion_block_SendMessageViewController)block
			toUser:(NSString *)userId displayingName:(NSString *)userDisplay;

// Init with a reply
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates  whenDone:(completion_block_SendMessageViewController)block
		 asReplyTo:(NSString *)messageId;

@end
