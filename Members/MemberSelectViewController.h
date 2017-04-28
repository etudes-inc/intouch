/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/MemberSelectViewController.h $
 * $Id: MemberSelectViewController.h 2651 2012-02-14 00:31:22Z ggolden $
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
#import "NavDelegate.h"
#import "Delegates.h"
#import "MembersInSections.h"

typedef void (^completion_block_ss)(NSString *userId, NSString *displayName);

@interface MemberSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	Site *site;
	id <Delegates> delegates;
	completion_block_ss whenSelected;
	IBOutlet UIActivityIndicatorView *busy;
	IBOutlet UISegmentedControl *selector;

	IBOutlet UITableView *list;
	MembersInSections *members;
	
	NSMutableSet /* NSString */ *selectedMembers;
	BOOL allowMultipleSelect;
}

@property (nonatomic, copy) completion_block_ss whenSelected;

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegate allowMultipleSelect:(BOOL)theAllowMultipleSelect preSelect:(NSArray *)preSelect;

@end
