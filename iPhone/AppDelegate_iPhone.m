/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/iPhone/AppDelegate_iPhone.m $
 * $Id: AppDelegate_iPhone.m 11715M 2015-10-07 19:26:44Z (local) $
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

#import "AppDelegate_iPhone.h"
#import "SitesViewController.h"
#import "SiteViewController.h"

@implementation AppDelegate_iPhone

// #define PRODUCTION
#define LOCAL
// #define PIXEL

#ifdef LOCAL
#define ETUDES_SERVER_PROTOCOL @"http"
#define ETUDES_SERVER_HOST @"localhost"
#define ETUDES_SERVER_PORT 8080
#endif

#ifdef PIXEL
#define ETUDES_SERVER_PROTOCOL @"http"
#define ETUDES_SERVER_HOST @"pixel.local"
#define ETUDES_SERVER_PORT 8080
#endif

#ifdef PRODUCTION
#define ETUDES_SERVER_PROTOCOL @"https"
#define ETUDES_SERVER_HOST @"e3.etudes.org"
#define ETUDES_SERVER_PORT 443
#endif

#pragma mark - Application lifecycle

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// get our version numbers
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	// NSLog(@"version %@ build %@", version, build);
	
	// set the navbar and toolbar background images for all of our UINavigarionBar and UIToolbar instances in the app
	UIImage *navbarImage = [UIImage imageNamed:@"navbar.png"];
	[[UINavigationBar appearance] setBackgroundImage:navbarImage forBarMetrics:UIBarMetricsDefault];

	UIImage *toolbarImage = [UIImage imageNamed:@"toolbar.png"];
	[[UIToolbar appearance] setBackgroundImage:toolbarImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];

	// create the Etudes session
	EtudesServerSession *sn = [[EtudesServerSession alloc] initWithProtocol:ETUDES_SERVER_PROTOCOL host:ETUDES_SERVER_HOST port:ETUDES_SERVER_PORT
													 preferences:self version:version build:build];
	self.session = sn;
	[sn release];

	// if no preferences login info, send to gateway
	// if we have login but no site info, send to sites
	// otherwise send to the site

	completion_block_s block0 = ^(enum resultStatus status)
	{
		// already at gateway - nothing to do
	};

	completion_block_s block1 = ^(enum resultStatus status)
	{
		// Sites in a nav
		UINavigationController *nav = [[UINavigationController alloc] init];
		SitesViewController *sites = [[SitesViewController alloc] initWithDelegates:self];
		[nav pushViewController:sites animated:NO];
		[sites release];
		
		// make sites controller the new main navigation controller
		[self setMainViewController:nav direction:1];
		[nav release];
	};

	completion_block_s block2 = ^(enum resultStatus status)
	{
		// make a site controller for the prefered site
		Site *site = [self site];
		SiteViewController *svc = [[SiteViewController alloc] initWithSite:site delegates:self];

		// make site controller the new main navigation controller
		[self setMainViewController:svc direction:1];
		[svc release];
	};

	[self.session authenticateFromPreferences:block0 badSite:block1 success:block2];
	
	// start with the gateway
	[self setMainViewControllerToGateway];

	// display
	[self.window makeKeyAndVisible];

	return YES;
}

- (void)dealloc
{
	[super dealloc];
}

@end
