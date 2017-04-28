/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Modules/SectionViewController.m $
 * $Id: SectionViewController.m 2582 2012-01-30 17:19:06Z ggolden $
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

#import "SectionViewController.h"
#import "NavBarTitle.h"
#import "EtudesColors.h"
#import "BrowserViewController.h"

@interface SectionViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Site *site;
@property (nonatomic, retain) Module *module;
@property (nonatomic, retain) Section *section;

@property (nonatomic, retain) IBOutlet UILabel *moduleTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *sectionTitleLabel;
@property (nonatomic, retain) IBOutlet UIWebView *bodyView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *busy;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) NSString *loadingUrl;

@end

@implementation SectionViewController

@synthesize delegates, site, module, section, moduleTitleLabel, sectionTitleLabel, bodyView, busy, loading, loadingUrl;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWitSite:(Site *)theSite delegates:(id <Delegates>)theDelegates module:(Module *)theModule section:(Section *)theSection;
{
    self = [super init];
    if (self)
	{
		self.delegates = theDelegates;
		self.site = theSite;
		self.title = @"Section";
		self.module = theModule;
		self.section = theSection;
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
		
		// next and prev
		NSUInteger pos = [self.module.sections indexOfObject:self.section];
		
		UIImage *up = [UIImage imageNamed:@"up.png"];
		UIImage *down = [UIImage imageNamed:@"down.png"];
		UISegmentedControl *nextPrevControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:up, down, nil]];
		
		[nextPrevControl addTarget:self action:@selector(nextPrev:) forControlEvents:UIControlEventValueChanged];
		nextPrevControl.momentary = YES;
		nextPrevControl.segmentedControlStyle = UISegmentedControlStyleBar;
		[nextPrevControl setEnabled:NO forSegmentAtIndex:0];
		[nextPrevControl setEnabled:NO forSegmentAtIndex:1];
		if (pos > 0)
		{
			[nextPrevControl setEnabled:YES forSegmentAtIndex:0];
		}
		if (pos < [self.module.sections count]-1)
		{
			[nextPrevControl setEnabled:YES forSegmentAtIndex:1];			
		}
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:nextPrevControl];
		[nextPrevControl release];
		self.navigationItem.rightBarButtonItem = button;
		[button release];

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
	[module release];
	[section release];
	[moduleTitleLabel release];
	[sectionTitleLabel release];
	bodyView.delegate = nil;
	[bodyView release];
	[busy release];
	[loadingUrl release];
	
    [super dealloc];
}

- (void) reset
{
	// back to as-loaded conditions
	self.bodyView.hidden = YES;
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

- (void) setModuleTitle:(NSString *)title
{
	self.moduleTitleLabel.text = title;
	// TODO: expand
}

- (void) setSectionTitle:(NSString *)title
{
	self.sectionTitleLabel.text = title;
	// TODO: expand
}

- (void) loadDetails
{
	// TODO: who should form this?
	[self loadBody:[NSString stringWithFormat:@"/cdp/doc/section/%@", self.section.sectionId]];
	[self setModuleTitle:self.module.title];
	[self setSectionTitle:self.section.title];

	// update the section as viewed
	section.viewed = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

#pragma mark - actions

// respond to the next/prev control
- (IBAction) nextPrev:(id)control
{
	// if loading a section, ignore
	if (self.loading) return;

	UISegmentedControl *segmentedControl = (UISegmentedControl *) control;
	NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
	
	// which message position
	NSUInteger pos = [self.module.sections indexOfObject:self.section];
	if (pos == NSNotFound) return;
	
	// prev
	if (selectedSegment == 0)
	{
		// prev message
		if (pos > 0)
		{
			pos--;
		}
	}
	
	else
	{
		// next message
		if (pos < [self.module.sections count]-1)
		{
			pos++;
		}
	}
	
	// stop loading if loading
	if (self.bodyView.loading)
	{
		[self.bodyView stopLoading];
	}
	
	// reset with the new message
	self.section = [self.module.sections objectAtIndex:pos];
	[self reset];
	[self loadDetails];
	
	// reset enabled for the controls
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	if (pos > 0)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	}
	if (pos < [self.module.sections count] -1)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}

@end
