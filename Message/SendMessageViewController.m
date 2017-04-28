/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Message/SendMessageViewController.m $
 * $Id: SendMessageViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SendMessageViewController.h"
#import "MemberSelectViewController.h"
#import "ETMessage.h"
#import "StringHtml.h"
#import "StringRe.h"

@interface SendMessageViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, copy) completion_block_SendMessageViewController completion;
@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) UILabel *toField;
@property (nonatomic, retain) UITextField *subjectField;
@property (nonatomic, retain) UITextView *bodyField;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) NSString *replyToMessageId;
@property (nonatomic, retain) NSMutableArray /* NSString */ *toUserIds;
@property (nonatomic, retain) NSMutableArray /* NSString */ *toDisplayNames;

- (void)registerForKeyboardNotifications;
- (IBAction) updateSendAvailability:(id)sender;

@end

@implementation SendMessageViewController

@synthesize delegates, site, completion;
@synthesize scroll, toField, subjectField, bodyField, busy, sendButton, cancelButton;
@synthesize replyToMessageId, toUserIds, toDisplayNames;

#pragma mark - lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_SendMessageViewController)block
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.toUserIds = [NSMutableArray array];
		self.toDisplayNames = [NSMutableArray array];
	}

    return self;
}

// Init with a recipient
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_SendMessageViewController)block
			toUser:(NSString *)userId displayingName:(NSString *)userDisplay;
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.toUserIds = [NSMutableArray arrayWithObjects:userId, nil];
		self.toDisplayNames = [NSMutableArray arrayWithObjects:userDisplay, nil];
	}

    return self;
}

// Init with a reply
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_SendMessageViewController)block
		 asReplyTo:(NSString *)messageId;
{
	self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.replyToMessageId = messageId;
		self.toUserIds = [NSMutableArray array];
		self.toDisplayNames = [NSMutableArray array];
	}
	
    return self;
}

- (void)dealloc
{
	[completion release];
	[site release];
	[scroll release];
	[replyToMessageId release];
	[toField release];
	[subjectField release];
	[bodyField release];
	[busy release];
	[sendButton release];
	[cancelButton release];
	[toUserIds release];
	[toDisplayNames release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) setToFieldText
{
	NSMutableString *text = [[NSMutableString alloc] init];
	BOOL first = YES;
	for (NSString *name in self.toDisplayNames)
	{
		if (!first)
		{
			[text appendString:@"   "];
		}

		[text appendString:name];
		first = NO;
	}

	self.toField.text = text;

	[text release];
}

- (void) loadInfo
{
	// 3 cases: nothing preset, to is preset, message is a reply (and we need to get the reply-to message for to, subject and body presets)
	
	if (self.replyToMessageId != nil)
	{
		// the completion block - when the message is loaded
		completion_block_sd loadDone = ^(enum resultStatus status, NSDictionary *results)
		{
			[self.busy stopAnimating];
			self.sendButton.enabled = YES;
			
			// save the message values we need
			ETMessage *message = [results objectForKey:@"message"];
			[self.toUserIds addObject: message.fromUserId];
			[self.toDisplayNames addObject: message.from];
			[self setToFieldText];

			// set the subject with Re:
			self.subjectField.text = [message.subject stringWithRe];
			
			// set the body with [quote]
			self.bodyField.text = [NSString stringWithFormat:@"[quote=%@]%@[/quote]", message.from, message.body];
			[self textViewDidChange:self.bodyField];
		};
		
		// load the message
		self.sendButton.enabled = NO;
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getMessageInSite:self.site messageId:self.replyToMessageId completion:loadDone plainText:YES];
	}
	
	// otherwise just set the to
	else if ([self.toUserIds count] > 0)
	{
		[self setToFieldText];
		[self updateSendAvailability:nil];

		// if we want to disable when we preset
		// self.toField.enabled = NO;
	}
	else
	{
		[self updateSendAvailability:nil];
	}
}

- (void) adjustView
{
	self.title = @"New Message";
	
	// add our buttons
	UIBarButtonItem *cnclBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																style:UIBarButtonItemStylePlain
															   target:self
															   action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cnclBtn;
	self.cancelButton = cnclBtn;
	[cnclBtn release];
	
	UIBarButtonItem *sndBtn = [[UIBarButtonItem alloc] initWithTitle:@"Post"
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(send:)];
	self.navigationItem.rightBarButtonItem = sndBtn;
	self.sendButton = sndBtn;
	[sndBtn release];
	
	// setup a touch for the to label - unless we are doing a reply, where this is fixed
	if (self.replyToMessageId == nil)
	{
		UIGestureRecognizer *toTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTo:)];
		[self.toField addGestureRecognizer:toTap];
		[toTap release];
	}
	[self registerForKeyboardNotifications];
	
	// set the content size of the scroll
	self.scroll.contentSize = self.scroll.frame.size;
	
	[self.busy stopAnimating];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self adjustView];
	
	[self loadInfo];
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

#pragma mark - actions

- (void)doCancel
{
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to discard this new message?" 
														delegate:self 
											   cancelButtonTitle:@"Resume Editing" 
										  destructiveButtonTitle:@"Discard" 
											   otherButtonTitles:nil];
	action.tag = 1;
	[action showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
	[action release];
}

- (void)doSend
{
	// run caller's completion block - body is sent as plain text
	if (self.completion)
	{
		self.completion(self.toUserIds, self.replyToMessageId, self.subjectField.text, self.bodyField.text);
	}
	
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to post this message?" 
														delegate:self 
											   cancelButtonTitle:@"Resume Editing" 
										  destructiveButtonTitle:nil 
											   otherButtonTitles:@"Post", nil];
	action.tag = 2;
	[action showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
	[action release];
}

// enable our send button only when we have subject and body and recipient
- (IBAction) updateSendAvailability:(id)sender
{
	BOOL complete = (([self.subjectField.text length] > 0) && ([self.bodyField hasText]) && ([self.toUserIds count] > 0));
	self.sendButton.enabled = complete;
}

// respond to touched in the to: field
- (IBAction) selectTo:(id)control
{
	[self.subjectField resignFirstResponder];
	[self.bodyField resignFirstResponder];

	// create the member select view controller
	// allow multiple select if instructor or ta
	MemberSelectViewController *msvc = [[MemberSelectViewController alloc]
										initWithSite:self.site delegates:self.delegates
										allowMultipleSelect:(self.site.instructorPrivileges || self.site.taPrivileges)
										preSelect:self.toUserIds];
	
	// on selection
	completion_block_ss whenSelected = ^(NSString *userId, NSString *displayName)
	{
		if (userId != nil) [self.toUserIds addObject:userId];
		if (displayName != nil) [self.toDisplayNames addObject:displayName];
		[self setToFieldText];
		
		[self.subjectField becomeFirstResponder];
		[self updateSendAvailability:nil];
	};
	msvc.whenSelected = whenSelected;
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:msvc animated:NO];
	[msvc release];
	
	// clear the current to list
	[self.toUserIds removeAllObjects];
	[self.toDisplayNames removeAllObjects];

	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

#pragma mark - keyboard handling
// see http://developer.apple.com/library/ios/#documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html

- (void)registerForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
	NSDictionary* info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
	self.scroll.contentInset = contentInsets;
	self.scroll.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	self.scroll.contentInset = contentInsets;
	self.scroll.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	// matches the original height of the text view
	static float THRESHOLD = 324;
	
	[self updateSendAvailability:nil];

	// adjust the frame of the text view to hold the content size, so it won't be scrolling.
	// don't let the frame get too short.
	if (textView.contentSize.height == textView.frame.size.height) return;
	if (textView.contentSize.height < THRESHOLD) return;
	
	// how did the content size change from this content change?
	float delta = textView.contentSize.height - textView.frame.size.height;

	// set our frame
	textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height + delta);

	// adjust the scroll view's content size to fit the new text view's frame
	self.scroll.contentSize = CGSizeMake(self.scroll.contentSize.width, self.scroll.contentSize.height + delta);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// YES to stop editing, NO to continue
	BOOL rv = NO;
	
	// return from Subject goes to Body
	if (textField == self.subjectField)
	{
		[self.bodyField becomeFirstResponder];
	}
	
	return rv;
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{	
	// index 0 is confirmation
	if (buttonIndex != 0) return;
	
	// tag 1 confirms cancel
	if (actionSheet.tag == 1)
	{
		[self doCancel];
	}	
	
	// tag 2 confirms send
	else if (actionSheet.tag == 2)
	{
		[self doSend];
	}
}

@end
