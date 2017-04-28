/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/SiteMembersViewController.h $
 * $Id: SiteMembersViewController.h 2613 2012-02-03 21:44:38Z ggolden $
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
#import "MembersInSections.h"

@interface SiteMembersViewController : SiteTabItemViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	IBOutlet UITableView *list;
	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	MembersInSections *members;
	NSString *selectedMemberId;
}

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegate;

// Start viewing this member
- (void) startInMember:(NSString *)userId;

// refresh
- (IBAction)refresh:(id)sender;

@end
