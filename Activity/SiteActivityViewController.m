/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Activity/SiteActivityViewController.m $
 * $Id: SiteActivityViewController.m 2643 2012-02-11 23:56:28Z ggolden $
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

#import "SiteActivityViewController.h"
#import "SiteActivityCell.h"
#import "ActivityItem.h"
#import "SiteMapViewController.h"

@interface SiteActivityViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) ActivityOverview *overview;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UILabel *noneLabel;
@end

@implementation SiteActivityViewController

@synthesize list, overview, refresh, updated, updatedDate, updatedTime, noneLabel;

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super initWithSite:st delegates:d title:@"Activity"];
    if (self)
	{
		// further initialization
		
		// setup a tabBarItem
		UIImage *image = [UIImage imageNamed:@"trend.png"];
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Activity" image:image tag:0];
		self.tabBarItem = item;
		[item release];		
    }

    return self;
}

- (void)dealloc
{
	[list release];
	[overview release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[noneLabel release];
	
    [super dealloc];
}

- (SiteActivityCell *) cellForItem:(ActivityItem *)item
{
	SiteActivityCell *cell = [SiteActivityCell siteActivityCellInTable:self.list];

	[cell setName:item.name];
	[cell setStatus:item.status];
	[cell setLastVisit:item.lastVisit notVisitedAlert:item.notVisitedAlert];
	[cell setMeleteCount:item.modules];
	[cell setMnemeCount:item.submissions];
	[cell setJforumCount:item.posts];
	[cell setVisitCount:item.visits];
	[cell setSyllabusAccepted:item.syllabusAccepted];

	return cell;
}

- (void) refreshView
{
	// cause the table to refresh
	[self.list reloadData];
	
	// hide or show the "no students" label
	self.noneLabel.hidden = ([self.overview.items count] != 0);
}

// called on viewDidLoad to load up data
- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the map is loaded
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		[self.busy stopAnimating];
		self.refresh.enabled = YES;
		
		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		// save the activity overview
		self.overview = [results objectForKey:@"activity"];

		[self refreshView];
	};

	// clear the refresh fields
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";

	// load up the activity overview
	[self.busy startAnimating];
	[[self.delegates sessionDelegate].session getActivityForSite:self.site completion:completion];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// the members in this section, and the member we want
	NSArray *membersInSection = [self.overview membersInSectionNumbered:indexPath.section];
	ActivityItem *item = [membersInSection objectAtIndex:indexPath.row];
	
	// create the map view controller
	SiteMapViewController *smvc = [[SiteMapViewController alloc] initWithSite:self.site delegates:self.delegates item:item fromList:self.overview.items];

	// go there
	[self.navigationController pushViewController:smvc animated:YES];
	[smvc release];	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.overview.actualSectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *sectionMembers = [self.overview membersInSectionNumbered:section];
	return [sectionMembers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *membersInSection = [self.overview membersInSectionNumbered:indexPath.section];
	ActivityItem *item = [membersInSection objectAtIndex:indexPath.row];
	SiteActivityCell *cell = [self cellForItem:item];
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return self.overview.possibleSectionTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = [self.overview.actualSectionTitles objectAtIndex:section];
	if ([title isEqualToString:@"X"]) return @"X, Y, Z";
	if ([title isEqualToString:@"•"]) return @"Others";
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.overview sectionNumberForTitle:title];
}

#pragma mark - actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

@end
