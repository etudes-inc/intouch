/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Sites/SitesViewController.m $
 * $Id: SitesViewController.m 2702 2012-02-28 05:09:59Z ggolden $
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

#import "SitesViewController.h"
#import "SiteViewController.h"
#import "Site.h"
#import "SiteCell.h"

@interface SitesViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UISegmentedControl *selector;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, copy) NSArray *sites;
@property (nonatomic, assign) BOOL initialAuthentiationComplete;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) UILabel *noneLabel;

@end

@implementation SitesViewController

@synthesize list, refresh, updated, updatedDate, updatedTime, selector, delegates;
@synthesize sites, initialAuthentiationComplete, busy, count, noneLabel;

#pragma mark - Lifecycle

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
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
	[sites release];
	[busy release];
	[selector release];
	[noneLabel release];

    [super dealloc];
}

#pragma mark - Data Handling

// count the visible sites, or if we are set to "all", all the sites
- (void) countSites
{
	int cnt = 0;
	BOOL visibleOnly = self.selector.selectedSegmentIndex == 0;
	if (self.sites != nil)
	{
		for (Site *site in self.sites)
		{
			if (visibleOnly)
			{
				if (site.visible) cnt++;
			}
			else
			{
				cnt++;
			}
		}
	}
	
	self.count = cnt;
}

- (SiteCell *) cellForIndexPath:(NSIndexPath *)indexPath
{
	Site *site = [self.sites objectAtIndex:indexPath.row];

	SiteCell *cell = [SiteCell siteCellInTable:self.list];

	[cell setSiteTitle:site.title];
	[cell setNumOnlineUsers:site.online];
	[cell setNumUnreadMessages:site.unreadMessages];
	[cell setUnreadPosts:site.unreadPosts];

	if (site.instructorPrivileges)
	{
		[cell setNumAlertUsers:site.notVisitAlerts];
	}
	else
	{
		[cell setNumAlertUsers:0];
	}
	
	return cell;
}

- (void) loadSites
{
	// the completion block - when the sites are loaded
	completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
	{
		// save the sites
		self.sites = results;
		
		[self.busy stopAnimating];
		
		// count sites
		[self countSites];

		NSDate *now = [NSDate date];
		self.refresh.enabled = YES;
		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		// cause the table to refresh
		[self.list reloadData];

		// hide or show the "you have no sites" label
		self.noneLabel.hidden = !(self.count == NO);
	};

	// load up the sites
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";
	[self.busy startAnimating];
	[[self.delegates sessionDelegate].session getSites:completion];	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.initialAuthentiationComplete = NO;

	self.title = @"Sites";
	
	// add our buttons
	UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
																	style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(logout:)];
	self.navigationItem.rightBarButtonItem = logoutButton;
	[logoutButton release];
	
	UISegmentedControl *sel = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Visible",@"All", nil]];
	sel.segmentedControlStyle = UISegmentedControlStyleBar;
	sel.selectedSegmentIndex = 0;
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
	[self.busy setColor:[UIColor darkGrayColor]];
	[self.view addSubview:self.busy];
}

- (void)viewDidAppear:(BOOL)animated
{
	// put up login if not already done so
	if (!self.initialAuthentiationComplete)
	{
		self.initialAuthentiationComplete = YES;
		
		// the completion block
		completion_block_s completion = ^(enum resultStatus status)
		{
			if (status == success) [self loadSites];
		};
		
		[[self.delegates sessionDelegate] authenticateOverViewController:self completion:completion];
	}
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	// assume one section - return # sites
    return self.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SiteCell *cell = [self cellForIndexPath:indexPath];
	return cell;
}

#pragma mark - TableView Delegate

// match SiteCell.xib
#define HEIGHT 116
#define ALERT_HEIGHT 16

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat adjust = 0;
	
	Site *site = [self.sites objectAtIndex:indexPath.row];	
	
	int alertCount = 0;
	if (site.instructorPrivileges)
	{
		alertCount = site.notVisitAlerts;
	}

	if (alertCount == 0)
	{
		adjust -= ALERT_HEIGHT;
	}
	
	CGFloat rv = HEIGHT + adjust;
	
	// SiteCell *sc = [self cellForIndexPath:indexPath];
	// if (sc.frame.size.height != rv) NSLog(@"sc mismatch path: %@   view height: %f   computed height: %f", indexPath, sc.frame.size.height, rv);
	
	return rv;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the site
	Site *site = [self.sites objectAtIndex:indexPath.row];
	
	// switch to the site controller
	SiteViewController *svc = [[SiteViewController alloc] initWithSite: site delegates:self.delegates];
	[[self.delegates navDelegate] setMainViewController: svc direction:0];
	[svc release];
	
	// record the site preferences
	[[self.delegates preferencesDelegate] setSite:site];
}

#pragma mark - Logout Action

- (IBAction)logout:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to logout?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Logout" 
											   otherButtonTitles:nil];
	// [action showInView:self.view];
	[action showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
	[action release];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// index 0 is the logout confirmation
	if (buttonIndex != 0) return;

	// logout the session
	[[self.delegates sessionDelegate ].session logout];

	// put the gateway up
	[[self.delegates navDelegate] setMainViewControllerToGateway];
}

#pragma mark - SegmentedController Action

- (IBAction) selectorAction
{
	// count sites - this count is based on the segmented control value
	[self countSites];

	// cause the table to refresh
	[self.list reloadData];
	
	// hide or show the "you have no sites" label
	self.noneLabel.hidden = !(self.count == NO);
}

#pragma mark - Actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadSites];
}

@end
