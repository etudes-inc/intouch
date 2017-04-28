/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Messages/MessageViewController.m $
 * $Id: MessageViewController.m 11715 2015-09-24 23:01:14Z ggolden $
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

#import "MessageViewController.h"
#import "NavBarTitle.h"
#import "SendMessageViewController.h"
#import	"DateFormat.h"
#import "BrowserViewController.h"

@interface MessageViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Site *site;
@property (nonatomic, copy) completion_block_m onDelete;
@property (nonatomic, retain) ETMessage *message;
@property (nonatomic, retain) NSArray /* <ETMEssage> */ *list;

@property (nonatomic, retain) UILabel *subjectLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *fromLabel;
@property (nonatomic, retain) UIView *dividerView;
@property (nonatomic, retain) UIWebView *bodyView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *composeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *replyButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *deleteButton;

@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *editBusy;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) NSString *loadingUrl;

@property (nonatomic, assign) CGRect subjectFrame;
@property (nonatomic, assign) CGRect dateFrame;
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect dividerFrame;
@property (nonatomic, assign) CGRect bodyFrame;

@end

@implementation MessageViewController

@synthesize site, delegates, onDelete;
@synthesize message, list;
@synthesize subjectLabel, dateLabel, fromLabel, dividerView, bodyView, toolbar, composeButton, replyButton, deleteButton;
@synthesize busy, editBusy, loading;
@synthesize loadingUrl;
@synthesize subjectFrame, dateFrame, fromFrame, dividerFrame, bodyFrame;

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
		[self.view addSubview:self.busy];
		
		// keep track of any requests in progress
		self.loadingUrl = nil;
	}
	
    return self;
}

//  final adjustments, once loaded
- (void) adjustView
{
	self.subjectFrame = self.subjectLabel.frame;
	self.dateFrame = self.dateLabel.frame;
	self.fromFrame = self.fromLabel.frame;
	self.dividerFrame = self.dividerView.frame;
	self.bodyFrame = self.bodyView.frame;
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
		
		// move down the date, from, divider and body to make room
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x, self.dateLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
		[self.fromLabel setFrame:CGRectMake(self.fromLabel.frame.origin.x, self.fromLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.fromLabel.frame.size.width, self.fromLabel.frame.size.height)];
		[self.dividerView setFrame:CGRectMake(self.dividerView.frame.origin.x, self.dividerView.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											  self.dividerView.frame.size.width, self.dividerView.frame.size.height)];
		[self.bodyView setFrame:CGRectMake(self.bodyView.frame.origin.x, self.bodyView.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
										   self.bodyView.frame.size.width,
										   self.bodyView.frame.size.height - (self.subjectLabel.font.lineHeight * (lines-1)))];
	}

	self.subjectLabel.text = subject;
}

- (void) loadDate:(NSDate *)date
{
	self.dateLabel.text = [date stringInEtudesFormat];
}

- (void) loadFrom:(NSString *)from
{
	self.fromLabel.text = from;
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

- (void) reset
{
	// back to as-load frames and conditions
	self.subjectLabel.frame = self.subjectFrame;
	self.dateLabel.frame = self.dateFrame;
	self.fromLabel.frame = self.fromFrame;
	self.dividerView.frame = self.dividerFrame;
	self.bodyView.frame = self.bodyFrame;
	self.bodyView.hidden = YES;
}

- (void) loadDetails
{
	// TODO: which date?  show released? show draft?
	
	[self loadSubject:self.message.subject];
	[self loadDate:self.message.date];
	[self loadFrom:self.message.from];
	[self loadBody:self.message.bodyPath];

	// find the message in the list
	NSUInteger pos = [self.list indexOfObject:self.message];
	if (pos != NSNotFound)
	{
		self.title = [NSString stringWithFormat:@"Message  %u of %lu", pos+1, (unsigned long)[self.list count]];
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
	[dateLabel release];
	[fromLabel release];
	[dividerView release];
	bodyView.delegate = nil;
	[bodyView release];
	[toolbar release];
	[composeButton release];
	[replyButton release];
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

// compose a reply
- (IBAction)reply:(id)sender
{
	// on send - the body is plain text
	completion_block_SendMessageViewController completion = ^(NSArray *to, NSString *replyToMessageId, NSString *subject, NSString *body)
	{
		// NSLog(@"sending PM: to:%@ subject:%@ body:%@", to, subject, body);
		completion_block_s whenSent = ^(enum resultStatus status)
		{
			// record it locally
			[self.message markAsReplied];
		};
		
		[[self.delegates sessionDelegate].session sendPrivateMessageReplyTo:replyToMessageId site:self.site subject:subject body:body completion:whenSent plainText:YES];		
	};

	// create the send message view controller
	SendMessageViewController *smvc = [[SendMessageViewController alloc] initWithSite:self.site
																			delegates:self.delegates whenDone:completion asReplyTo:self.message.messageId];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:smvc animated:NO];
	[smvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// compose a new message
- (IBAction)compose:(id)sender
{	
	// on send - the body is plain text
	completion_block_SendMessageViewController completion = ^(NSArray *to, NSString *replyToMessageId, NSString *subject, NSString *body)
	{
		// NSLog(@"sending PM: to:%@ subject:%@ body:%@", to, subject, body);
		completion_block_s whenSent = ^(enum resultStatus status)
		{
			// NSLog(@"PM send complete: status:%d", status);
		};
		
		[[self.delegates sessionDelegate].session sendPrivateMessageTo:to site:self.site subject:subject body:body completion:whenSent plainText:YES];		
	};

	// create the send message view controller
	SendMessageViewController *smvc = [[SendMessageViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:smvc animated:NO];
	[smvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// delete the item - confirm first
- (IBAction)delete:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this message?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Delete" 
											   otherButtonTitles:nil];
	[action showFromBarButtonItem:self.deleteButton animated:YES];
	[action release];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// index 0 is the logout confirmation
	if (buttonIndex != 0) return;
	
	// delete locally
	if (self.onDelete)
	{
		self.onDelete(self.message);
	}
	
	// return
	[self.navigationController popViewControllerAnimated: YES];
}

@end
