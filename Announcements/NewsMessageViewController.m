/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/NewsMessageViewController.m $
 * $Id: NewsMessageViewController.m 11715 2015-09-24 23:01:14Z ggolden $
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

#import "NewsMessageViewController.h"
#import "NavBarTitle.h"
#import	"DateFormat.h"
#import "NewsComposeViewController.h"
#import "BrowserViewController.h"

@interface NewsMessageViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Site *site;
@property (nonatomic, copy) completion_block_m onDelete;
@property (nonatomic, retain) ETMessage *message;
@property (nonatomic, retain) NSArray /* <ETMessage> */ *list;

@property (nonatomic, retain) UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UIImageView *invisibleIcon;
@property (nonatomic, retain) IBOutlet UIImageView *unpublishedIcon;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *fromLabel;
@property (nonatomic, retain) UIView *dividerView;
@property (nonatomic, retain) UIWebView *bodyView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *deleteButton;

@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *editBusy;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) NSString *loadingUrl;

@property (nonatomic, assign) CGRect subjectFrame;
@property (nonatomic, assign) CGRect invisibleFrame;
@property (nonatomic, assign) CGRect unpublishedFrame;
@property (nonatomic, assign) CGRect dateFrame;
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect dividerFrame;
@property (nonatomic, assign) CGRect bodyFrame;

@end

@implementation NewsMessageViewController

@synthesize site, delegates, onDelete;
@synthesize message, list;
@synthesize subjectLabel, invisibleIcon, unpublishedIcon, dateLabel, fromLabel, dividerView, bodyView, toolbar, editButton, deleteButton;
@synthesize busy, editBusy, loading;
@synthesize loadingUrl;
@synthesize subjectFrame, invisibleFrame, unpublishedFrame, dateFrame, fromFrame, dividerFrame, bodyFrame;

// The designated initializer.  
- (id)initWithMessage:(ETMessage *)msg fromList:(NSArray *)msgList site:(Site *)theSite
			delegates:(id <Delegates>)d onDelete:(completion_block_m)block
{
    self = [super init];
    if (self)
	{
		self.message = msg;
		self.list = msgList;
		self.delegates = d;
		self.site = theSite;
		self.onDelete = block;
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
		
		// next and prev
		NSUInteger pos = [self.list indexOfObject:self.message];
		
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
		if (pos < [self.list count]-1)
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
		[self.busy setColor:[UIColor darkGrayColor]];
		[self.view addSubview:self.busy];
		
		// keep track of any requests in progress
		self.loadingUrl = nil;
	}
	
    return self;
}

// final adjustments once loaded
- (void) adjustView
{
	// hide the toolbar if we cannot make changes - this will not change with the different announcements in the site (i.e. with next/prev)
	if (!self.site.allowNewAnnouncement)
	{
		[self.bodyView setFrame:CGRectMake(self.bodyView.frame.origin.x, self.bodyView.frame.origin.y,
										   self.bodyView.frame.size.width, self.bodyView.frame.size.height + self.toolbar.frame.size.height)];
		self.toolbar.hidden = YES;
	}
	
	// record the intial frame sizes
	self.subjectFrame = self.subjectLabel.frame;
	self.dateFrame = self.dateLabel.frame;
	self.fromFrame = self.fromLabel.frame;
	self.dividerFrame = self.dividerView.frame;
	self.bodyFrame = self.bodyView.frame;
	self.invisibleFrame = self.invisibleIcon.frame;
	self.unpublishedFrame = self.unpublishedIcon.frame;

	self.invisibleIcon.hidden = YES;
	self.unpublishedIcon.hidden = YES;
}

// reset the view between messages (i.e. next/prev)
- (void) reset
{
	// back to as-load frames and conditions
	self.subjectLabel.frame = self.subjectFrame;
	self.dateLabel.frame = self.dateFrame;
	self.fromLabel.frame = self.fromFrame;
	self.dividerView.frame = self.dividerFrame;
	self.bodyView.frame = self.bodyFrame;
	self.bodyView.hidden = YES;
	self.invisibleIcon.frame = self.invisibleFrame;
	self.unpublishedIcon.frame = self.unpublishedFrame;
	self.invisibleIcon.hidden = YES;
	self.unpublishedIcon.hidden = YES;
	[self.editBusy stopAnimating];
	self.editButton.enabled = YES;
	self.deleteButton.enabled = YES;
}

- (void) loadSubject:(NSString *)subject
{
	// how many lines will the subject render in?
	CGSize theSize = [subject sizeWithFont:self.subjectLabel.font constrainedToSize:CGSizeMake(self.subjectLabel.bounds.size.width, FLT_MAX)
							 lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.subjectLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.subjectLabel setFrame:CGRectMake(self.subjectLabel.frame.origin.x, self.subjectLabel.frame.origin.y,
											   self.subjectLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.subjectLabel.numberOfLines = lines;
		
		// move down the date, icons, from, divider and body to make room
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x, self.dateLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
		[self.fromLabel setFrame:CGRectMake(self.fromLabel.frame.origin.x, self.fromLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.fromLabel.frame.size.width, self.fromLabel.frame.size.height)];
		[self.dividerView setFrame:CGRectMake(self.dividerView.frame.origin.x, self.dividerView.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											  self.dividerView.frame.size.width, self.dividerView.frame.size.height)];
		[self.bodyView setFrame:CGRectMake(self.bodyView.frame.origin.x, self.bodyView.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
										   self.bodyView.frame.size.width,
										   self.bodyView.frame.size.height - (self.subjectLabel.font.lineHeight * (lines-1)))];
		[self.invisibleIcon setFrame:CGRectMake(self.invisibleIcon.frame.origin.x, self.invisibleIcon.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
												self.invisibleIcon.frame.size.width, self.invisibleIcon.frame.size.height)];
		[self.unpublishedIcon setFrame:CGRectMake(self.unpublishedIcon.frame.origin.x, self.unpublishedIcon.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
												  self.unpublishedIcon.frame.size.width, self.unpublishedIcon.frame.size.height)];
	}
	
	self.subjectLabel.text = subject;
}

- (void) loadDate:(NSDate *)date draft:(BOOL)draft released:(BOOL)released releaseDate:(NSDate *)releaseDate
{
	if (draft)
	{
		self.dateLabel.text = [date stringInEtudesFormat];
		self.unpublishedIcon.hidden = NO;
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x + self.unpublishedIcon.frame.size.width, self.dateLabel.frame.origin.y,
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
		[self.fromLabel setFrame:CGRectMake(self.fromLabel.frame.origin.x + self.unpublishedIcon.frame.size.width, self.fromLabel.frame.origin.y,
											self.fromLabel.frame.size.width - self.unpublishedIcon.frame.size.width, self.fromLabel.frame.size.height)];
	}
	else if (released)
	{
		// use the later of the date (modified) and the releaseDate
		NSDate *later = [date laterDate:releaseDate];
		self.dateLabel.text = [later stringInEtudesFormat];
	}
	else
	{
		self.dateLabel.text = [releaseDate stringInEtudesFormat];
		self.invisibleIcon.hidden = NO;
		
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x + self.invisibleIcon.frame.size.width, self.dateLabel.frame.origin.y,
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
		[self.fromLabel setFrame:CGRectMake(self.fromLabel.frame.origin.x + self.invisibleIcon.frame.size.width, self.fromLabel.frame.origin.y,
											self.fromLabel.frame.size.width - self.invisibleIcon.frame.size.width, self.fromLabel.frame.size.height)];
	}
}

- (void) loadFrom:(NSString *)from
{
	self.fromLabel.text = from;
}

- (void) loadBodyFromPath:(NSString *)urlPath
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

/*
- (void) loadBody:(NSString *)body
{
	// start loading the body - it will callback when completed (see webViewDidFinsihLoad:)
	self.bodyView.delegate = self;
	NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
	[self.bodyView loadHTMLString:body baseURL:baseUrl];
}
*/

- (void) loadDetails
{
	[self loadSubject:self.message.subject];
	[self loadDate:self.message.date draft:message.draft released:message.released releaseDate:message.releaseDate];
	[self loadFrom:self.message.from];
	/*
	if (self.message.body != nil)
	{
		[self loadBody:self.message.body];		
	}
	*/
	if (self.message.bodyPath != nil)
	{
		[self loadBodyFromPath:self.message.bodyPath];
	}
	
	// find the message in the list
	NSUInteger pos = [self.list indexOfObject:self.message];
	if (pos != NSNotFound)
	{
		self.title = [NSString stringWithFormat:@"News  %u of %lu", pos+1, (unsigned long)[self.list count]];
		[((NavBarTitle *) self.navigationItem.titleView) setTitle:self.title];
	}
	
	// the body load tells the server that this user has read this item - record it locally
	[self.message markAsRead];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.editBusy stopAnimating];
	[self adjustView];
	[self loadDetails];
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

	[subjectLabel release];
	[invisibleIcon release];
	[unpublishedIcon release];
	[dateLabel release];
	[fromLabel release];
	[dividerView release];
	bodyView.delegate = nil;
	[bodyView release];
	[toolbar release];
	[editButton release];
	[deleteButton release];
	[busy release];
	[editBusy release];
	
	[message release];
	[list release];
	
	[site release];
	[onDelete release];

	[loadingUrl release];
	
	[super dealloc];
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
		// for Safari
		// [[UIApplication sharedApplication] openURL:[request URL]];
		// return NO;
		
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
	UISegmentedControl *segmentedControl = (UISegmentedControl *) control;
	NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
	
	// which message position
	NSUInteger pos = [self.list indexOfObject:self.message];
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
		if (pos < [self.list count]-1)
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
	self.message = [self.list objectAtIndex:pos];
	[self reset];
	[self loadDetails];
	
	// reset enabled for the controls
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	if (pos > 0)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	}
	if (pos < [self.list count] -1)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}

// edit the item
- (void) doEdit
{
	// on send - the body is plain text
	completion_block_ssbb completion = ^(NSString *subject, NSString *body, BOOL draft, BOOL priority)
	{
		// NSLog(@"sending news item: subject:%@ body:%@", subject, body);
		completion_block_sd whenPosted = ^(enum resultStatus status, NSDictionary *def)
		{
			// NSLog(@"post complete: status:%d", status);
			if (status == success)
			{
				// take the message from the results
				ETMessage *update = [def objectForKey:@"update"];
				
				NSNumber *editLockAlert = [def objectForKey:@"editLockAlert"];
				if ([editLockAlert boolValue])
				{
					UIAlertView *alert = [[UIAlertView alloc]
										  initWithTitle: @"Alert"
										  message: @"This item is currently being edited.  Your changes were not accepted."
										  delegate: self
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
					[alert show];
					[alert release];
				}

				// update the message
				[self.message updateWithMessage:update];
				
				// refresh to show the edited message
				[self reset];
				[self loadDetails];
			}
		};
		[[self.delegates sessionDelegate].session sendUpdatedNewsForSite:self.site messageId:self.message.messageId
																 subject:subject body:body draft:draft priority:priority completion:whenPosted plainText:YES];		
	};

	// create the new compose view controller
	NewsComposeViewController *ncvc = [[NewsComposeViewController alloc] initWithSite:self.site
																			delegates:self.delegates whenDone:completion editingId:self.message.messageId];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:ncvc animated:NO];
	[ncvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// delete the item - confirm first
- (IBAction)delete:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this item?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Delete" 
											   otherButtonTitles:nil];
	action.tag = 2;
	[action showFromToolbar:self.toolbar];
	[action release];
}

// edit the item - confirm first
- (IBAction)edit:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Some formatting may be lost.  Do you want to edit this item?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:nil 
											   otherButtonTitles:@"Edit", nil];
	action.tag = 1;
	[action showFromToolbar:self.toolbar];
	[action release];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{	
	// index 0 is confirmation
	if (buttonIndex != 0) return;
	
	// tag 1 confirms edit
	if (actionSheet.tag == 1)
	{
		[self doEdit];
	}	

	// tag 2 confirms delete
	else if (actionSheet.tag == 2)
	{
		// delete locally
		if (self.onDelete)
		{
			self.onDelete(self.message);
		}

		// return
		[self.navigationController popViewControllerAnimated: YES];
	}
}

@end
