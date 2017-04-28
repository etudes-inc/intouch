/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Chat/ChatSendViewController.h $
 * $Id: ChatSendViewController.h 2702 2012-02-28 05:09:59Z ggolden $
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

#import <UIKit/UIKit.h>
#import "Delegates.h"

// completion block that has 1 string
typedef void (^completion_block_str)(NSString *body);

@interface ChatSendViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate>
{
@protected
	Site *site;
	id<Delegates> delegates;
	completion_block_str completion;
	completion_block_str cancel;
	
	IBOutlet UIScrollView *scroll;
	IBOutlet UITextView *bodyField;
	UIBarButtonItem *sendButton;
	UIBarButtonItem *cancelButton;	
}

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)delegates whenDone:(completion_block_str)block onCancel:(completion_block_str)block2;

@end
