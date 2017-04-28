/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/NewsMessageViewController.h $
 * $Id: NewsMessageViewController.h 2654 2012-02-14 22:33:42Z ggolden $
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

@interface NewsMessageViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
@protected
	id <Delegates> delegates;
	Site *site;
	completion_block_m onDelete;
	ETMessage *message;
	NSArray /* <ETMessage> */ *list;
	NSString *loadingUrl;
	BOOL loading;

	IBOutlet UILabel *subjectLabel;
	IBOutlet UIImageView *invisibleIcon;
	IBOutlet UIImageView *unpublishedIcon;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *fromLabel;
	IBOutlet UIView *dividerView;
	IBOutlet UIWebView *bodyView;
	IBOutlet UIActivityIndicatorView *busy;
	IBOutlet UIActivityIndicatorView *editBusy;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *editButton;
	IBOutlet UIBarButtonItem *deleteButton;
	
	CGRect subjectFrame;
	CGRect invislbleFrame;
	CGRect unpublishedFrame;
	CGRect dateFrame;
	CGRect fromFrame;
	CGRect dividerFrame;
	CGRect bodyFrame;
}

// The designated initializer.  
- (id)initWithMessage:(ETMessage *)message fromList:(NSArray *)list site:(Site *)site
			delegates:(id <Delegates>)delegates onDelete:(completion_block_m)block;

// edit the item
- (IBAction)edit:(id)sender;

// delete the item
- (IBAction)delete:(id)sender;

@end
