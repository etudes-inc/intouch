/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Chat/ChatViewController.h $
 * $Id: ChatViewController.h 2701 2012-02-28 00:40:16Z ggolden $
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
#import "Site.h"
#import "EtudesServerSession.h"
#import "Delegates.h"
#import "SiteTabItemViewController.h"
#import "ColorMapper.h"
#import "ETMessage.h"

@interface ChatViewController : SiteTabItemViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	id <EtudesServerSessionDelegate> sessionDelegate;
	IBOutlet UITableView *list;
	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	IBOutlet UILabel *noneLabel;

	NSArray /* <ETMessage> */ *messages;
	NSTimer *timer;
	ColorMapper *colors;
	ETMessage *selectedMessage;
}

// The designated initializer.  
- (id) initWithSite:(Site *)site delegates:(id <Delegates>)delegates;

// send a new chat
- (IBAction) chat:(id)control;

// refresh
- (IBAction) refresh:(id)sender;

@end
