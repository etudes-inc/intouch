/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/NewsComposeViewController.h $
 * $Id: NewsComposeViewController.h 2694 2012-02-25 02:43:46Z ggolden $
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

// completion block that has the subject and body from the view
typedef void (^completion_block_ssbb)(NSString *subject, NSString *body, BOOL draft, BOOL priority);

@interface NewsComposeViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
@protected
	Site *site;
	id<Delegates> delegates;
	completion_block_ssbb completion;
	NSString *editMessageId;
	IBOutlet UIScrollView *scroll;
	IBOutlet UITextField *subjectField;
	IBOutlet UITextView *bodyField;
	IBOutlet UILabel *subjectLabel;
	IBOutlet UIView *divider;
	IBOutlet UISwitch *draftSwitch;
	IBOutlet UISwitch *prioritySwitch;
	IBOutlet UIActivityIndicatorView *busy;
	UIBarButtonItem *publishButton;
	UIBarButtonItem *cancelButton;
}

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_ssbb) block;

// Init to edit
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_ssbb)block editingId:(NSString *)messageId;

@end
