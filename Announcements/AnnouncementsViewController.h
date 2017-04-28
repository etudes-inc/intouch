/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/AnnouncementsViewController.h $
 * $Id: AnnouncementsViewController.h 2658 2012-02-15 19:47:51Z ggolden $
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
#import "SiteTabItemViewController.h"
#import "ETMessage.h"

@interface AnnouncementsViewController : SiteTabItemViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
@protected
	IBOutlet UITableView *list;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarButtonItem *compose;
	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	IBOutlet UILabel *noneLabel;
	ETMessage *msgToDelete;

	NSArray /* Message */ *announcements;
}

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegates;

// compose a new announcement
- (IBAction)compose:(id)sender;

// refresh
- (IBAction)refresh:(id)sender;

@end
