/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Site/SiteViewController.m $
 * $Id: SiteViewController.m 2063 2011-10-09 19:46:00Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011 Etudes, Inc.
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

#import "SiteViewController.h"
#import "SiteMsgsViewController.h"
#import "SiteMapViewController.h"
#import "SiteActivityViewController.h"
#import "DiscussionsViewController.h"
#import "AnnouncementsViewController.h"
#import "MessagesViewController.h"
#import "SiteMembersViewController.h"

@interface SiteViewController()

@property (nonatomic, assign) id <Delegates> delegates;

@property (nonatomic, retain) Site *site;

@end


@implementation SiteViewController

@synthesize delegates;
@synthesize site;

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.delegates = d;

		self.site = st;
		self.title = self.site.title;

		// put in the tabs

		// Course Map or Activity Meter - in a nav
		UINavigationController *activityNav = [[UINavigationController alloc] init];
		bool amNotCm = self.site.allowActivityMeter;
		if (amNotCm)
		{
			SiteActivityViewController *activityVc = [[SiteActivityViewController alloc] initWithSite:self.site delegates:self.delegates];
			[activityNav pushViewController:activityVc animated:NO];
			[activityVc release];
		}
		// TODO: check the site.allowCourseMap permission
		else
		{
			SiteMapViewController *mapVc = [[SiteMapViewController alloc] initWithSite:self.site delegates:self.delegates];
			[activityNav pushViewController:mapVc animated:NO];
			[mapVc release];
		}

		// Discussions - in a nav
		UINavigationController *discussionsNav = [[UINavigationController alloc] init];
		DiscussionsViewController *discussionsVc = [[DiscussionsViewController alloc] initWithSite:self.site delegates:self.delegates];
		[discussionsNav pushViewController:discussionsVc animated:NO];
		[discussionsVc release];

		// Announcements - in a nav
		UINavigationController *announcementsNav = [[UINavigationController alloc] init];
		AnnouncementsViewController *announcementsVc = [[AnnouncementsViewController alloc] initWithSite:self.site delegates:self.delegates];
		[announcementsNav pushViewController:announcementsVc animated:NO];
		[announcementsVc release];

		// Private Messages - in a nav
		UINavigationController *messagesNav = [[UINavigationController alloc] init];
		MessagesViewController *messagesVc = [[MessagesViewController alloc] initWithSite:self.site delegates:self.delegates];
		[messagesNav pushViewController:messagesVc animated:NO];
		[messagesVc release];

		// Members - in a nav
		UINavigationController *membersNav = [[UINavigationController alloc] init];
		SiteMembersViewController *membersVc = [[SiteMembersViewController alloc] initWithSite:self.site delegates:self.delegates];
		[membersNav pushViewController:membersVc animated:NO];
		[membersVc release];

		self.viewControllers = [NSArray arrayWithObjects:activityNav, discussionsNav, announcementsNav, messagesNav, membersNav, nil];	
		[activityNav release];
		[discussionsNav release];
		[announcementsNav release];
		[messagesNav release];
		[membersNav release];
	}

    return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[site release];
    [super dealloc];
}

// Select the members tab
- (void) selectMembersTabWithMember:(NSString *)memberId
{
	// set the members view to this user
	UINavigationController *membersNav = [self.viewControllers objectAtIndex:4];
	SiteMembersViewController *membersVc = [membersNav.viewControllers objectAtIndex:0];
	[membersVc startInMember:memberId];
	
	// go back to the list view if we are in a member view
	[membersNav popToRootViewControllerAnimated:NO];

	// select the members view
	self.selectedIndex = 4;
}

@end
