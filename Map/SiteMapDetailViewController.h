/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapDetailViewController.h $
 * $Id: SiteMapDetailViewController.h 2529 2012-01-19 19:32:51Z ggolden $
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
#import "Delegates.h"
#import "CourseMapItem.h"

@interface SiteMapDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	Site *site;
	id <Delegates> delegates;
	CourseMapItem *item;
	NSArray *items;
	BOOL inAm;

	IBOutlet UIScrollView *scrollView;
	IBOutlet UIImageView *iconImage;
	IBOutlet UIImageView *progressImage;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *status2Label;
	IBOutlet UITableView *tableView;
	
	CGRect titleFrame;
	CGRect statusFrame;
	CGRect status2Frame;
	CGRect tableFrame;
	CGRect progressFrame;
}

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegates courseMapItem:(CourseMapItem *)item fromList:(NSArray *)list inAM:(BOOL)inAM;

@end
