/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/PostViewController.h $
 * $Id: PostViewController.h 2694 2012-02-25 02:43:46Z ggolden $
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
#import "Topic.h"
#import "Post.h"

// completion block that has the subject and body from the view
typedef void (^completion_block_ss)(NSString *subject, NSString *body);

@interface PostViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
@protected
	Site *site;
	id<Delegates> delegates;
	completion_block_ss completion;
	IBOutlet UIScrollView *scroll;
	IBOutlet UITextField *subjectField;
	IBOutlet UITextView *bodyField;
	IBOutlet UILabel *subjectLabel;
	IBOutlet UIView *divider;
	IBOutlet UIActivityIndicatorView *busy;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *sendButton;
	Topic *topic;
	Post *post;
	Post *edit;
}

// The designated initializer as a new topic.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_ss) block;

// Init as a topic reply.
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_ss) block replyToTopic:(Topic *)topic;

// Init as a post reply.
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_ss) block replyToPost:(Post *)post;

// Init as a post edit.
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_ss) block editPost:(Post *)post;

@end
