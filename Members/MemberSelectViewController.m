/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/MemberSelectViewController.m $
 * $Id: MemberSelectViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "MemberSelectViewController.h"

@interface MemberSelectViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) UIActivityIndicatorView *busy;

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) MembersInSections *members;
@property (nonatomic, retain) UISegmentedControl *selector;
@property (nonatomic, retain) NSMutableSet /* NSString */ *selectedMembers;

@property (nonatomic, assign) BOOL allowMultipleSelect;

@end

@implementation MemberSelectViewController

@synthesize site, delegates, whenSelected, busy, list, members, selector, selectedMembers, allowMultipleSelect;

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d allowMultipleSelect:(BOOL)theAllowMultipleSelect preSelect:(NSArray *)preSelect
{
	self = [super init];
	if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.allowMultipleSelect = theAllowMultipleSelect;
		
		// setup the initially selected members
		NSMutableSet *sel = [[NSMutableSet alloc] init];
		self.selectedMembers = sel;
		[sel release];

		if (self.allowMultipleSelect && (preSelect != nil))
		{
			for (NSString *userId in preSelect)
			{
				[self.selectedMembers addObject:userId];
			}
		}
	}

	return self;
}

- (void)dealloc
{
	[site release];
	[whenSelected release];
	[busy release];
	[list release];
	[members release];
	[selector release];
	[selectedMembers release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) loadInfo
{
	// the completion block - when the announcements are loaded
	completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
	{
		// save the forums
		self.members = [MembersInSections membersInSectionsWithMembers:results];
		
		[self.busy stopAnimating];
		
		// cause the table to refresh
		[self.list reloadData];		
	};
	
	// load up the sites (get one more than then limit so we know if there are more or not)
	[self.busy startAnimating];
	[[self.delegates sessionDelegate].session getMembersForSite:self.site refresh:NO completion:completion];	
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
}

// on load
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Members";
	
	if (self.allowMultipleSelect)
	{
		// add our buttons
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(done:)];
		self.navigationItem.rightBarButtonItem = doneButton;
		[doneButton release];
		
		UISegmentedControl *sel = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Selected",@"All", nil]];
		sel.segmentedControlStyle = UISegmentedControlStyleBar;
		sel.selectedSegmentIndex = 1;
		[sel addTarget:self action:@selector(selectorAction) forControlEvents:UIControlEventValueChanged];
		self.selector = sel;
		[sel release];
		
		UIBarButtonItem *selectorItem = [[UIBarButtonItem alloc] initWithCustomView:self.selector];
		self.navigationItem.leftBarButtonItem = selectorItem;
		[selectorItem release];
		
		UIActivityIndicatorView *bsy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.busy = bsy;
		[bsy release];
		self.busy.center = CGPointMake(self.view.center.x, self.view.center.y - (2 * self.view.frame.origin.y));	
		[self.busy stopAnimating];
		[self.view addSubview:self.busy];
	}
	
	else
	{
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(cancel:)];
		self.navigationItem.rightBarButtonItem = cancelButton;
		[cancelButton release];
	}
	
	[self loadInfo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) showingAll
{
	return ((!self.allowMultipleSelect) || (self.selector.selectedSegmentIndex == 1));
}

- (Member *) memberForIndexPath:(NSIndexPath *)indexPath
{
	if ([self showingAll])
	{
		// the members in this section, and the member we want
		NSArray *membersInSection = [self.members membersInSectionNumbered:indexPath.section];
		Member *mbr = [membersInSection objectAtIndex:indexPath.row];
		return mbr;
	}
	else
	{
		int count = 0;
		for (Member *mbr in self.members.members)
		{
			if ([self.selectedMembers containsObject:mbr.userId])
			{
				count++;
				if (indexPath.row == (count-1))
				{
					return mbr;
				}
			}
		}
	}

	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Member *mbr = [self memberForIndexPath:indexPath];
	
	if (self.allowMultipleSelect)
	{
		if ([self.selectedMembers containsObject:mbr.userId])
		{
			[self.selectedMembers removeObject:mbr.userId];
		}
		else
		{
			[self.selectedMembers addObject:mbr.userId];
		}
		
		[self.list reloadData];
	}

	else
	{
		// run callers completion block
		if (self.whenSelected)
		{
			self.whenSelected(mbr.userId, mbr.displayName);
		}
		
		// take the send message view away
		[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([self showingAll])
	{
		return [self.members.actualSectionTitles count];
	}
	else
	{
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([self showingAll])
	{
		NSArray *sectionMembers = [self.members membersInSectionNumbered:section];
		return [sectionMembers count];
	}
	else
	{
		return [self.selectedMembers count];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"SiteMemeberCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	Member *mbr = [self memberForIndexPath:indexPath];
	
	cell.textLabel.text = mbr.displayName;
	
	if (self.allowMultipleSelect && [self.selectedMembers containsObject:mbr.userId])
	{
		cell.imageView.image = [UIImage imageNamed:@"finish.gif"];
	}
	else
	{
		cell.imageView.image = nil;
	}

	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if ([self showingAll])
	{
		return self.members.possibleSectionTitles;
	}
	else
	{
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([self showingAll])
	{
		NSString *title = [self.members.actualSectionTitles objectAtIndex:section];
		if ([title isEqualToString:@"*"]) return @"Logged In As";
		if ([title isEqualToString:@"•"]) return @"Instructors";
		if ([title isEqualToString:@"X"]) return @"X, Y, Z, ...";
		return title;
	}
	else
	{
		return @"Selected Members";
	}
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.members sectionNumberForTitle:title];
}

#pragma mark - SegmentedController Action

- (IBAction) selectorAction
{
	// cause the table to refresh
	[self.list reloadData];
	
	// hide or show the "you have no sites" label
//	self.noneLabel.hidden = !(self.count == NO);
}

#pragma mark - actions

- (IBAction)done:(id)sender
{
	// run callers completion block
	if (self.whenSelected)
	{
		for (Member *mbr in self.members.members)
		{
			if ([self.selectedMembers containsObject:mbr.userId])
			{
				self.whenSelected(mbr.userId, mbr.displayName);
			}
		}
		
		if ([self.selectedMembers count] == 0)
		{
			self.whenSelected(nil, nil);
		}
	}

	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
