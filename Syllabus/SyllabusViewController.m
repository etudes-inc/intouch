/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Syllabus/SyllabusViewController.m $
 * $Id: SyllabusViewController.m 2582 2012-01-30 17:19:06Z ggolden $
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

#import "SyllabusViewController.h"
#import "NavBarTitle.h"
#import "EtudesColors.h"
#import "BrowserViewController.h"

@interface SyllabusViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) BOOL accepted;

@property (nonatomic, retain) UIWebView *bodyView;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) NSString *loadingUrl;

@end

@implementation SyllabusViewController

@synthesize delegates, site, accepted, bodyView, busy, loading, loadingUrl;

// The designated initializer.  
- (id)initWitSite:(Site *)theSite delegates:(id <Delegates>)theDelegates accepted:(BOOL)theAccepted
{
    self = [super init];
    if (self)
	{
		self.delegates = theDelegates;
		self.site = theSite;
		self.title = @"Syllabus";
		self.accepted = theAccepted;
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];

		// busy
		UIActivityIndicatorView *bsy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.busy = bsy;
		[bsy release];
		self.busy.center = CGPointMake(self.view.center.x, self.view.center.y - (2 * self.view.frame.origin.y));	
		[self.busy stopAnimating];
		[self.view addSubview:self.busy];
		
		// keep track of any requests in progress
		self.loadingUrl = nil;
	}
	
    return self;
}

- (void)dealloc
{
	[site release];
	bodyView.delegate = nil;
	[bodyView release];
	[busy release];
	[loadingUrl release];

    [super dealloc];
}

- (void) adjustView
{
}

- (void) loadBody:(NSString *)urlPath
{
	// the URL request to get the body
	NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
	NSURL *url = [NSURL URLWithString:urlPath relativeToURL:baseUrl];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setValue:[[self.delegates sessionDelegate ].session basicAuthHeaderValue] forHTTPHeaderField:@"Authorization"];
	
	// start loading the body - it will callback when completed (see webViewDidFinsihLoad:)
	self.bodyView.delegate = self;
	[self.bodyView loadRequest:request];
}

- (void) loadDetails
{
	// TODO: who should form this?
	[self loadBody:[NSString stringWithFormat:@"/cdp/doc/syllabus/%@", site.siteId]];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self adjustView];
	[self loadDetails];
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeOther)
	{
		// record the URL we are loading
		self.loadingUrl = request.URL.absoluteString;
		
		return YES;
	}
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		// internal
		NSString * urlStr = [[request URL] absoluteString];
		BrowserViewController *bvc = [[BrowserViewController alloc] initWitSite:self.site delegates:self.delegates url:urlStr];	
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
	NSString *failingUrl = [[[error userInfo] objectForKey:@"NSErrorFailingURLKey"] absoluteString];
	
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	self.loading = NO;
	
	// if the failed url is the one we are loading
	if (![failingUrl isEqualToString:self.loadingUrl])
	{
		[[[self.delegates sessionDelegate] session] alertServerCommunicationsTrouble];
	}
	
	// no longer loading
	self.loadingUrl = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{	
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	self.loading = NO;
	
	// no longer loading the URL
	self.loadingUrl = nil;
	
	self.bodyView.hidden = NO;
}


#pragma mark - Actions

// reply to an actions touch
- (IBAction) doActions:(id)sender
{
	if (accepted)
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Syllabus Accepted"
							  message: @"You have accepted the terms of the syllabus."
							  delegate: self
							  cancelButtonTitle: @"Ok"
							  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}

	else
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: @"Accept the Syllabus"
							  message: @"I have read the syllabus, and I accept its terms."
							  delegate: self
							  cancelButtonTitle: @"Cancel"
							  otherButtonTitles: @"Accept", nil];
		[alert show];
		[alert release];
	}
}

#pragma mark - action sheet delegate

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// index 1 is "Accept"
	if (buttonIndex == 1)
	{
		// send and forget
		// the completion block - when the map is loaded
		completion_block_s completion = ^(enum resultStatus status)
		{
		};

		[[self.delegates sessionDelegate].session sendSyllabusAcceptance:self.site completion:completion];
		self.accepted = YES;
	}
}

@end
