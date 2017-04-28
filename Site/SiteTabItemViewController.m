/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Site/SiteTabItemViewController.m $
 * $Id: SiteTabItemViewController.m 2702 2012-02-28 05:09:59Z ggolden $
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

#import "SiteTabItemViewController.h"
#import "SitesViewController.h"
#import "NavBarTitle.h"

@implementation SiteTabItemViewController

@synthesize site;
@synthesize delegates;
@synthesize busy;
@synthesize lastReload;
@synthesize autoReloadThreshold;

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d title:(NSString *)title
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
		
		self.site = st;
		self.title = title;
		
		// logout button
		UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(logout:)];
		self.navigationItem.rightBarButtonItem = logoutButton;
		[logoutButton release];

		// change site button
		UIBarButtonItem *sitesButton = [[UIBarButtonItem alloc] initWithTitle:@"Sites"
																		style:UIBarButtonItemStylePlain
																	   target:self
																	   action:@selector(sites:)];
		self.navigationItem.leftBarButtonItem = sitesButton;
		[sitesButton release];

		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];

		// derived class needs to setup a tabBarItem
		
		// default to an auto-reload threshold of 1 minute
		self.autoReloadThreshold = 60;
		self.lastReload = nil;
    }
	
    return self;
}

// Init as a nav, not a tab view 
- (id)initAsNavWithSite:(Site *)st delegates:(id <Delegates>)d title:(NSString *)title
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
		
		self.site = st;
		self.title = title;

		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];

		// default to an auto-reload threshold of 1 minute
		self.autoReloadThreshold = 60;
		self.lastReload = nil;
	}
	
    return self;
}

- (void)dealloc
{
	[site release];
	[busy release];
	[lastReload release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// load view's data
- (void) loadInfo
{
	self.lastReload = [NSDate date];

	// derived class can implement this method to load up data.
}

// adjust the view - one time after load
- (void) adjustView
{
	// derived class can implement this method to adjust the view once loaded.
}

// get the data into the view
- (void) refreshView
{
	// derived class can implement this method to get data into the view.
}

// on load
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIActivityIndicatorView *bsy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.busy = bsy;
	[bsy release];
	self.busy.center = CGPointMake(self.view.center.x, self.view.center.y - (2 * self.view.frame.origin.y));	
	[self.busy stopAnimating];
	[self.busy setColor:[UIColor darkGrayColor]];
	[self.view addSubview:self.busy];

    // Do any additional setup after loading the view from its nib.
	[self adjustView];
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	BOOL willReload = NO;
	
	// load if we have not loaded yet
	if (self.lastReload == nil) willReload = YES;

	// load if we have a threshold and are past it since last reload
	if ((self.autoReloadThreshold > 0) && (self.lastReload != nil) && (([self.lastReload timeIntervalSinceNow] * -1) > self.autoReloadThreshold))
		willReload = YES;
	
	// reload if needed
	if (willReload)
	{
		[self loadInfo];
	}
	
	// otherwise refresh the view
	else
	{
		[self refreshView];
	}
}

#pragma mark - Actions

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

- (IBAction)sites:(id)sender
{
	// put the sites up
	UINavigationController *nav = [[UINavigationController alloc] init];
	SitesViewController *svc = [[SitesViewController alloc] initWithDelegates:self.delegates];
	[nav pushViewController:svc animated:NO];
	[svc release];
	[[self.delegates navDelegate] setMainViewController: nav direction:0];
	[nav release];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// index 0 is the logout confirmation
	if (buttonIndex != 0) return;
	
	// logout the session
	[[self.delegates sessionDelegate].session logout];

	// put the gateway up
	[[self.delegates navDelegate] setMainViewControllerToGateway];
}

@end
