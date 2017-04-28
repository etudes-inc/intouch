/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Browser/BrowserViewController.m $
 * $Id: BrowserViewController.m 2582 2012-01-30 17:19:06Z ggolden $
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

#import "BrowserViewController.h"
#import "NavBarTitle.h"
#import "EtudesColors.h"

@interface BrowserViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Site *site;
@property (nonatomic, retain) NSString *url;

@property (nonatomic, retain) IBOutlet UIWebView *bodyView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *busy;
@property (nonatomic, retain) IBOutlet UIBarItem *prev;
@property (nonatomic, retain) IBOutlet UIBarItem *next;
@property (nonatomic, retain) IBOutlet UIBarItem *refresh;

@end

@implementation BrowserViewController

@synthesize delegates, site, url, bodyView, busy, prev, next, refresh;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWitSite:(Site *)theSite delegates:(id <Delegates>)theDelegates url:(NSString *)theUrl;
{
    self = [super init];
    if (self)
	{
		self.delegates = theDelegates;
		self.site = theSite;
		self.url = theUrl;
		
		self.title = @"Loading...";

		// the nav bar title
		//NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		//self.navigationItem.titleView = nbt;
		//[nbt release];

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

- (void)dealloc
{
	[site release];
	[url release];
	bodyView.delegate = nil;
	[bodyView release];
	[busy release];
	[prev release];
	[next release];
	[refresh release];

    [super dealloc];
}

- (void) loadBody:(NSString *)urlPath
{
	// the URL request to get the body
	NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
	NSURL *theUrl = [NSURL URLWithString:urlPath relativeToURL:baseUrl];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theUrl];
	[request setValue:[[self.delegates sessionDelegate ].session basicAuthHeaderValue] forHTTPHeaderField:@"Authorization"];
	
	// start loading the body - it will callback when completed (see webViewDidFinsihLoad:)
	[self.bodyView loadRequest:request];
}

- (void) loadDetails
{
	[self loadBody:self.url];	
}

- (void) reset
{
}

- (void) adjustView
{
	self.next.enabled = self.bodyView.canGoForward;
	self.prev.enabled = self.bodyView.canGoBack;
	self.title = [self.bodyView stringByEvaluatingJavaScriptFromString:@"document.title;"];
}

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// handle non http schemes by sending out for help
	if (![[[request URL] scheme] hasPrefix:@"http"])
	{
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[[self.delegates sessionDelegate] session] startNetworkActivity];
	[self.busy startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSString *failingUrl = [[[error userInfo] objectForKey:@"NSErrorFailingURLKey"] absoluteString];
	
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Alert"
						  message: [NSString stringWithFormat:@"Unable to load %@.", failingUrl]
						  delegate: self
						  cancelButtonTitle: @"OK"
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];

	[self adjustView];
}

#pragma mark - Actions

// reply to a prev
- (IBAction) doPrev:(id)sender
{
	[self.bodyView goBack];
}

// reply to a next
- (IBAction) doNext:(id)sender
{
	[self.bodyView goForward];
}

// reply to a refresh
- (IBAction) doRefresh:(id)sender
{
	[self.bodyView reload];
}

// reply to an actions touch
- (IBAction) doActions:(id)sender
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:nil
											   otherButtonTitles:@"Open in Safari", nil];
	[action showFromBarButtonItem:sender animated:YES];
	[action release];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// index 0 is "Open in Safari"
	if (buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL:[self.bodyView.request URL]];
	}
}

@end
