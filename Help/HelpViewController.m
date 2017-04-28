/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Help/HelpViewController.m $
 * $Id: HelpViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "HelpViewController.h"

@interface HelpViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) NSString *titleConfig;
@property (nonatomic, retain) NSURL *urlConfig;
@property (nonatomic, retain) UIWebView *helpWeb;
@property (nonatomic, retain) UIActivityIndicatorView *busy;

@end

@implementation HelpViewController

@synthesize delegates, titleConfig, urlConfig, helpWeb, busy;

#pragma mark - lifecycle

// The designated initializer.
- (id)initWithDelegates:(id <Delegates>)d title:(NSString *)theTitle url:(NSURL *)theUrl
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.delegates = d;
		self.titleConfig = theTitle;
		self.urlConfig = theUrl;

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

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = titleConfig;
	
	// add our buttons
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];

	// set the source of the motd view
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.urlConfig];
	[self.helpWeb loadRequest:request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
	[titleConfig release];
	[urlConfig release];
	helpWeb.delegate = nil;
	[helpWeb release];
	[busy release];

	[super dealloc];
}

#pragma mark - button actions

- (IBAction)done:(id)sender
{
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeOther) return YES;
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[[self.delegates sessionDelegate] session] startNetworkActivity];
	[self.busy startAnimating];
	//self.loading = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	//self.loading = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[[self.delegates sessionDelegate] session] endNetworkActivity];
	[self.busy stopAnimating];
	self.helpWeb.hidden = NO;
	//self.loading = NO;	
}

@end
