/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Gateway/GatewayViewController.m $
 * $Id: GatewayViewController.m 2582 2012-01-30 17:19:06Z ggolden $
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

#import "GatewayViewController.h"
#import "SitesViewController.h"
#import "BrowserViewController.h"
#import "NavBarTitle.h"

@interface GatewayViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) UIWebView *motd;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, assign) BOOL loading;

@end

@implementation GatewayViewController

@synthesize motd;
@synthesize delegates;
@synthesize busy, loading;

#define MOTD_URL @"/e3/docs/motd.html"

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
		self.loading = NO;

		// busy
		UIActivityIndicatorView *bsy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.busy = bsy;
		[bsy release];
		self.busy.center = CGPointMake(self.view.center.x, self.view.center.y - (2 * self.view.frame.origin.y));	
		[self.busy stopAnimating];
		[self.view addSubview:self.busy];
    }

    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	// self.title = @"Gateway";
	
	// the nav bar title (version info and app name)
	NSString *version = [NSString stringWithFormat:@"%@ / %@",
						 [[self.delegates sessionDelegate] session].version, [[self.delegates sessionDelegate] session].build];
	NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:version title:@"Etudes inTouch"];
	self.navigationItem.titleView = nbt;
	[nbt release];

	// add our buttons
	UIBarButtonItem *enterButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
																	style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(enter:)];
	self.navigationItem.rightBarButtonItem = enterButton;
	[enterButton release];
	
	// set the source of the motd view
	NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
	NSURL *url = [NSURL URLWithString:MOTD_URL relativeToURL:baseUrl];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[self.motd loadRequest:request];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	// if still loading
	if (self.loading)
	{
		[[[self.delegates sessionDelegate] session] endNetworkActivity];
	}

	motd.delegate = nil;
	[motd release];
	[busy release];

    [super dealloc];
}

- (IBAction) enter:(id)sender
{
	// offer login, and if successfull...
	completion_block_s completion = ^(enum resultStatus status)
	{
		if (status == success)
		{
			UINavigationController *nav = [[UINavigationController alloc] init];
			SitesViewController *sites = [[SitesViewController alloc] initWithDelegates:self.delegates];
			[nav pushViewController:sites animated:NO];
			[sites release];

			// make sites the new main navigation controller
			[[self.delegates navDelegate] setMainViewController:nav direction:0];
			[nav release];
		}
	};
	
	[[self.delegates sessionDelegate] authenticateOverViewController:self completion:completion];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// NSLog(@"type:%d request:%@\n", navigationType, request);

	if (navigationType == UIWebViewNavigationTypeOther) return YES;

	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		// open in safari
		//[[UIApplication sharedApplication] openURL:[request URL]];
		//return NO;
		
		// internal
		NSString * urlStr = [[request URL] absoluteString];
		BrowserViewController *bvc = [[BrowserViewController alloc] initWitSite:nil delegates:self.delegates url:urlStr];	
		[self.navigationController pushViewController:bvc animated:YES];
		[bvc release];
	}

	return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[[self.delegates sessionDelegate] session] startNetworkActivity];
	[self.busy startAnimating];
	self.loading = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	self.loading = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	self.loading = NO;	
}

@end
