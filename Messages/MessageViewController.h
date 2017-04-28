/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Messages/MessageViewController.h $
 * $Id: MessageViewController.h 2656 2012-02-15 00:14:46Z ggolden $
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
#import "EtudesServerSession.h"
#import "ETMessage.h"
#import "Site.h"
#import "Delegates.h"

// completion block that has the message
typedef void (^completion_block_m)(ETMessage *msg);

@interface MessageViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
@protected
	id <Delegates> delegates;
	Site *site;
	ETMessage *message;
	NSArray /* <ETMEssage> */ *list;
	NSString *loadingUrl;
	BOOL loading;
	
	IBOutlet UILabel *subjectLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *fromLabel;
	IBOutlet UIView *dividerView;
	IBOutlet UIWebView *bodyView;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIActivityIndicatorView *busy;
	IBOutlet UIActivityIndicatorView *editBusy;
	IBOutlet UIBarButtonItem *composeButton;
	IBOutlet UIBarButtonItem *replyButton;
	IBOutlet UIBarButtonItem *deleteButton;
	CGRect subjectFrame;
	CGRect dateFrame;
	CGRect fromFrame;
	CGRect dividerFrame;
	CGRect bodyFrame;
}

// compose a reply
- (IBAction)reply:(id)sender;

// compose a new message
- (IBAction)compose:(id)sender;

// delete a message
- (IBAction)delete:(id)sender;

// The designated initializer.  
- (id)initWithMessage:(ETMessage *)message fromList:(NSArray *)list site:(Site *)site
			delegates:(id <Delegates>)delegates onDelete:(completion_block_m)block;

@end
