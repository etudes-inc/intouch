/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/DiscussionsViewController.h $
 * $Id: DiscussionsViewController.h 2618 2012-02-07 00:13:04Z ggolden $
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
#import "Category.h"

@interface DiscussionsViewController : SiteTabItemViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected	
	IBOutlet UITableView *list;
	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	NSString *categoryId;
	NSArray /* <Category> */ *categories;
	NSString *chatName;
	BOOL chatPresence;
}

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegates;

// Init as a nav view, not the top tab bar view, focused on a particular category
- (id)initAsNavWithSite:(Site *)site delegates:(id <Delegates>)delegates focusOnCategoryId:(NSString *)categoryId;

// refresh
- (IBAction)refresh:(id)sender;

@end
