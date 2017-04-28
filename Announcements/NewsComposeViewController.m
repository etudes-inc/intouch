/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/NewsComposeViewController.m $
 * $Id: NewsComposeViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "NewsComposeViewController.h"
#import "StringHtml.h"
#import "ETMessage.h"

@interface NewsComposeViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, copy) completion_block_ssbb completion;
@property (nonatomic, retain) NSString *editMessageId;
@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) UITextField *subjectField;
@property (nonatomic, retain) UITextView *bodyField;
@property (nonatomic, retain) UIView *divider;
@property (nonatomic, retain) UIBarButtonItem *publishButton;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UISwitch *draftSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *prioritySwitch;
@property (nonatomic, retain) UIActivityIndicatorView *busy;

- (void)registerForKeyboardNotifications;
- (IBAction) updatePublishAvailability:(id)sender;
- (IBAction) updatePublishTitle:(id)sender;

@end

@implementation NewsComposeViewController

@synthesize site, delegates, completion, editMessageId;
@synthesize scroll, subjectField, bodyField, divider, publishButton, cancelButton, draftSwitch, prioritySwitch, busy;

#pragma mark - lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_ssbb) block
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
	}
	
    return self;
}

// Init to edit
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_ssbb)block editingId:(NSString *)messageId
{
	self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.editMessageId = messageId;
	}
	
    return self;
}
- (void)dealloc
{
	[site release];
	[completion release];
	[editMessageId release];
	[scroll release];
	[subjectField release];
	[bodyField release];
	[subjectLabel release];
	[divider release];
	[publishButton release];
	[cancelButton release];
	[draftSwitch release];
	[prioritySwitch release];
	[busy release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) adjustView
{
	// set the title
	self.title = @"News Item";
	
	// add our buttons
	UIBarButtonItem *cnclBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																style:UIBarButtonItemStylePlain
															   target:self
															   action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cnclBtn;
	self.cancelButton = cnclBtn;
	[cnclBtn release];
	
	UIBarButtonItem *pubBnt = [[UIBarButtonItem alloc] initWithTitle:@"Post"
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(send:)];
	self.navigationItem.rightBarButtonItem = pubBnt;
	self.publishButton = pubBnt;
	[pubBnt release];
	
	[self registerForKeyboardNotifications];

	// set the content size of the scroll
	self.scroll.contentSize = CGSizeMake(self.scroll.frame.size.width, self.scroll.frame.size.height);

	[self.busy stopAnimating];
}

- (void) loadInfo
{
	if (self.editMessageId != nil)
	{
		// the completion block - when the news item is loaded
		completion_block_sd loadDone = ^(enum resultStatus status, NSDictionary *results)
		{
			[self.busy stopAnimating];
			self.publishButton.enabled = YES;
			
			// save the message values we need
			ETMessage *message = [results objectForKey:@"message"];
			
			self.subjectField.text = message.subject;
			self.bodyField.text = message.body;
			[self textViewDidChange:self.bodyField];

			[self.draftSwitch setOn:message.draft];
			[self.prioritySwitch setOn:message.priority];

			[self updatePublishAvailability:nil];
			[self updatePublishTitle:nil];
			
			// set the cursor in Subject
			[self.subjectField becomeFirstResponder];
			
			NSNumber *editLockAlert = [results objectForKey:@"editLockAlert"];
			if ([editLockAlert boolValue])
			{
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle: @"Alert"
									  message: @"This item is currently being edited.  You may not have the updated version, and your changes may not be accepted."
									  delegate: self
									  cancelButtonTitle: @"OK"
									  otherButtonTitles: nil];
				[alert show];
				[alert release];
			}
		};

		// load the message
		self.publishButton.enabled = NO;
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getNewsInSite:self.site messageId:self.editMessageId completion:loadDone plainText:YES];
	}
	
	// setup for a new item
	else
	{
		[self.draftSwitch setOn:YES];

		[self updatePublishAvailability:nil];
		[self updatePublishTitle:nil];

		// set the cursor in Subject
		[self.subjectField becomeFirstResponder];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self adjustView];
	[self loadInfo];
}

- (void) viewDidUnload
{
    [super viewDidUnload];	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions

- (void) doCancel
{
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancel:(id)sender
{
	NSString *msg = @"Do you want to discard changes to this item?";
	if (self.editMessageId == nil)
	{
		msg = @"Do you want to discard this new item?";
	}

	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:msg 
														delegate:self 
											   cancelButtonTitle:@"Resume Editing" 
										  destructiveButtonTitle:@"Discard" 
											   otherButtonTitles:nil];
	action.tag = 1;
	[action showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
	[action release];
}

- (void) doSend
{
	// run callers completion block
	if (self.completion)
	{
		self.completion(self.subjectField.text, self.bodyField.text, self.draftSwitch.on, self.prioritySwitch.on);
	}
	
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) send:(id)sender
{
	NSString *actionTitle = @"Post";
	NSString *msg = @"Do you want to post this item?";
	if (self.draftSwitch.on)
	{
		actionTitle = @"Draft";
		msg = @"Do you want to save this draft?";
	}

	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:msg 
														delegate:self 
											   cancelButtonTitle:@"Resume Editing" 
										  destructiveButtonTitle:nil
											   otherButtonTitles:actionTitle, nil];
	action.tag = 2;
	[action showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
	[action release];
}

// enable our publish button only when we have subject and body
- (IBAction) updatePublishAvailability:(id)sender
{
	BOOL complete = (([self.subjectField.text length] > 0) && ([self.bodyField hasText]));
	self.publishButton.enabled = complete;
}

- (IBAction) updatePublishTitle:(id)sender
{
	if (self.draftSwitch.on)
	{
		self.publishButton.title = @"Draft";
	}
	else
	{
		self.publishButton.title = @"Post";
	}
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
	static float THRESHOLD = 330;

	[self updatePublishAvailability:nil];

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
	
	// tag 1 confirms edit
	if (actionSheet.tag == 1)
	{
		[self doCancel];
	}	
	
	// tag 2 confirms delete
	else if (actionSheet.tag == 2)
	{
		[self doSend];
	}
}

@end
