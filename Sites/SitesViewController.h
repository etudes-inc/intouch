/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Sites/SitesViewController.h $
 * $Id: SitesViewController.h 2643 2012-02-11 23:56:28Z ggolden $
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
//#import "EtudesServerSession.h"
#import "NavDelegate.h"
#import "Delegates.h"

@interface SitesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
@protected
	IBOutlet UITableView *list;
	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	IBOutlet UISegmentedControl *selector;
	IBOutlet UILabel *noneLabel;

	id <Delegates> delegates;

	NSArray *sites;
	BOOL initialAuthentiationComplete;
	IBOutlet UIActivityIndicatorView *busy;

	int count;
}

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)delegates;

// refresh
- (IBAction)refresh:(id)sender;

@end
