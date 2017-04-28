/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/SiteMembersViewController.m $
 * $Id: SiteMembersViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SiteMembersViewController.h"
#import "Member.h"
#import "MemberViewController.h"
#import "MemberCell.h"

@interface SiteMembersViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) MembersInSections *members;
@property (nonatomic, retain) NSString *selectedMemberId;

@end

@implementation SiteMembersViewController

@synthesize list, refresh, updated, updatedDate, updatedTime, members, selectedMemberId;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
	self = [super initWithSite:st delegates:d title:@"Members"];
	if (self)
	{
		// further initialization

		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"112-group.png"] tag:0];
		//UITabBarItem *item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
		self.tabBarItem = item;
		[item release];
	}
	
	return self;
}

- (void)dealloc
{
	[list release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[members release];
	[selectedMemberId release];

    [super dealloc];
}

- (void) goToMember
{
	// find this member
	Member *mbr = [self.members memberWithId:self.selectedMemberId];
	if (mbr != nil)
	{
		MemberViewController *mvc = [[MemberViewController alloc] initWithMember:mbr fromList:self.members.members site:self.site delegates:self.delegates];
		[self.navigationController pushViewController:mvc animated:NO];
		[mvc release];			
	}
	self.selectedMemberId = nil;	
}

- (void) refreshView
{
	// cause the table to refresh
	[self.list reloadData];
	
	// if we have a specific member to view, go there
	if (self.selectedMemberId != nil)
	{
		[self goToMember];
	}
}

- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the announcements are loaded
	completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
	{
		// save the members
		self.members = [MembersInSections membersInSectionsWithMembers:results];

		[self.busy stopAnimating];
		self.refresh.enabled = YES;
		
		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		[self refreshView];
	};

	// clear the refresh fields
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";

	// load up the members
	[self.busy startAnimating];
	[[self.delegates sessionDelegate].session getMembersForSite:self.site refresh:YES completion:completion];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
	
	// if we have our members loaded, and a specific member to view, go there
	if ((self.members != nil) && (self.selectedMemberId != nil))
	{
		[self goToMember];
	}
}

#pragma mark - Cell management

- (MemberCell *)cellForInstructorAtIndex:(NSUInteger)index
{
	Member *mbr = [[self.members membersInSectionNumbered:0] objectAtIndex:index];
	MemberCell *cell = [MemberCell memberCellInTable:self.list];
	
	[cell setStatus:mbr.status];
	[cell setName:mbr.displayName];
	[cell setPresenceSite:mbr.online chat:mbr.inChat];

	return cell;
}

- (MemberCell *)cellForMember:(Member *)mbr
{
	MemberCell *cell = [MemberCell memberCellInTable:self.list];
	
	[cell setStatus:mbr.status];
	[cell setName:mbr.displayName];
	[cell setPresenceSite:mbr.online chat:mbr.inChat];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// the members in this section, and the member we want
	NSArray *membersInSection = [self.members membersInSectionNumbered:indexPath.section];
	Member *mbr = [membersInSection objectAtIndex:indexPath.row];
	
	// go there
	MemberViewController *mvc = [[MemberViewController alloc] initWithMember:mbr fromList:self.members.members site:self.site delegates:self.delegates];
	[self.navigationController pushViewController:mvc animated:YES];
	[mvc release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.members.actualSectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *sectionMembers = [self.members membersInSectionNumbered:section];
	return [sectionMembers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MemberCell *cell = nil;

	// for the instructors section, find
	if (indexPath.section == 0)
	{
		cell = [self cellForInstructorAtIndex:indexPath.row];
	}
	else
	{
		NSArray *membersInSection = [self.members membersInSectionNumbered:indexPath.section];
		Member *mbr = [membersInSection objectAtIndex:indexPath.row];
		cell = [self cellForMember:mbr];;
	}

	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return self.members.possibleSectionTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = [self.members.actualSectionTitles objectAtIndex:section];
	if ([title isEqualToString:@"*"]) return @"Logged In As";
	if ([title isEqualToString:@"•"]) return @"Instructors";
	if ([title isEqualToString:@"X"]) return @"X, Y, Z, ...";
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.members sectionNumberForTitle:title];
}

// Start viewing this member
- (void) startInMember:(NSString *)userId
{
	self.selectedMemberId = userId;
}

#pragma mark - Actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

@end
