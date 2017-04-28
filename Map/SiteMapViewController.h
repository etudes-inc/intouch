/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapViewController.h $
 * $Id: SiteMapViewController.h 2643 2012-02-11 23:56:28Z ggolden $
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
#import "CourseMap.h"
#import "ActivityItem.h"

@interface SiteMapViewController : SiteTabItemViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	IBOutlet UITableView *list;
	CourseMap *map;
	ActivityItem *aItem;
	NSArray *aItems;

	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIImageView *avatarImage;
	IBOutlet UIActivityIndicatorView *avatarLoading;
	IBOutlet UIImageView *statusIcon;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *sectionLabel;
	IBOutlet UILabel *iidLabel;
	IBOutlet UISegmentedControl *filteredControl;
	IBOutlet UIView *idView;
	IBOutlet UILabel *noneLabel;

	BOOL showIdView;
}

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegates;

// Init with an ActivityMeter item
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegates item:(ActivityItem *)theItem fromList:(NSArray *)theList;

// refresh
- (IBAction)refresh:(id)sender;

// respond to the filtered control
- (IBAction) studentAll:(id)control;

@end
