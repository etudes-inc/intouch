/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Modules/ModuleViewController.h $
 * $Id: ModuleViewController.h 2631 2012-02-09 20:49:56Z ggolden $
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
#import "Module.h"

@interface ModuleViewController : SiteTabItemViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	NSString *moduleId;
	IBOutlet UIBarButtonItem *refresh;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIView *titleBkg;
	IBOutlet UIView *titleSeparator;
	IBOutlet UITableView *sectionsTable;
	Module *module;
	CGRect titleFrame;
	CGRect sectionsFrame;
}

// The designated initializer.  
- (id)initWitSite:(Site *)site delegates:(id <Delegates>)delegates moduleId:(NSString *)theModuleId;

// refresh
- (IBAction)refresh:(id)sender;

@end
