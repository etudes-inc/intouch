/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Chat/ChatSendViewController.m $
 * $Id: ChatSendViewController.m 11714 2015-09-24 22:36:20Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2012 Etudes, Inc.
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

#import "ChatSendViewController.h"

@interface ChatSendViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, copy) completion_block_str completion;
@property (nonatomic, copy) completion_block_str cancel;
@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) UITextView *bodyField;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;

- (void) registerForKeyboardNotifications;
- (IBAction) updateSendAvailability:(id)sender;

@end

@implementation ChatSendViewController

@synthesize delegates, site, completion, cancel;
@synthesize scroll, bodyField, sendButton, cancelButton;

#pragma mark - lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_str)block onCancel:(completion_block_str)block2
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.cancel = block2;
	}
	
    return self;
}

- (void)dealloc
{
	[completion release];
	[cancel release];
	[site release];
	[scroll release];
	[bodyField release];
	[sendButton release];
	[cancelButton release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) adjustView
{
	self.title = @"Chat";
	
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

	[self registerForKeyboardNotifications];
	
	// set the content size of the scroll
	self.scroll.contentSize = self.scroll.frame.size;
	
	[self updateSendAvailability:nil];

	[self.bodyField becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self adjustView];
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
	// run caller's completion block - body is sent as plain text
	if (self.cancel)
	{
		self.cancel(self.bodyField.text);
	}
	
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to discard this message?"
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
		self.completion(self.bodyField.text);
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
	BOOL complete = [self.bodyField hasText];
	self.sendButton.enabled = complete;
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
