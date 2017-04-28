/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/PostViewController.m $
 * $Id: PostViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "PostViewController.h"
#import "StringHtml.h"
#import "StringRe.h"

@interface PostViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, copy) completion_block_ss completion;
@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) UITextField *subjectField;
@property (nonatomic, retain) UITextView *bodyField;
@property (nonatomic, retain) UILabel *subjectLabel;
@property (nonatomic, retain) UIView *divider;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) Topic *topic;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) Post *edit;

- (void)registerForKeyboardNotifications;
- (IBAction) updatePostAvailability:(id)sender;

@end

@implementation PostViewController

@synthesize site, delegates, completion;
@synthesize scroll, subjectField, bodyField, subjectLabel, divider;
@synthesize topic, post, edit;
@synthesize busy, cancelButton, sendButton;

#pragma mark - lifecycle

// The designated initializer as a new topic.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_ss) block
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

// Init as a topic reply.
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_ss) block replyToTopic:(Topic *)t
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.topic = t;
	}
	
    return self;
}

// Init as a post reply.
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_ss) block replyToPost:(Post *)p
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.post = p;
	}
	
    return self;
}

// Init as a post edit.
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d whenDone:(completion_block_ss) block editPost:(Post *)p
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.site = st;
		self.delegates = d;
		self.completion = block;
		self.edit = p;
	}
	
    return self;
}

- (void)dealloc
{
	[site release];
	[completion release];
	[scroll release];
	[subjectField release];
	[bodyField release];
	[subjectLabel release];
	[divider release];
	[busy release];
	[cancelButton release];
	[sendButton release];
	[topic release];
	[post release];
	[edit release];
	
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
	[self.busy stopAnimating];

	if (self.post != nil)
	{
		self.title = @"Reply To Post";

		// set the cursor in Body
		[self.bodyField becomeFirstResponder];		
	}

	else if (self.topic != nil)
	{
		self.title = @"Reply To Topic";

		// set the cursor in Body
		[self.bodyField becomeFirstResponder];		
	}
	
	else if (self.edit != nil)
	{
		self.title = @"Edit Post";
		
		// set the cursor in Body
		[self.bodyField becomeFirstResponder];		
	}
	else
	{
		self.title = @"New Topic";

		// set the cursor in Subject
		[self.subjectField becomeFirstResponder];
	}

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
	
	// seed the subject fields
	if (self.topic != nil)
	{
		self.subjectField.text = [self.topic.title stringWithRe];
	}
	else if (self.post != nil)
	{
		self.subjectField.text = [self.post.subject stringWithRe];
	}
	else if (self.edit != nil)
	{
		self.subjectField.text = self.edit.subject;
	}

	[self updatePostAvailability:nil];

	self.scroll.contentSize = self.scroll.frame.size;
}

- (void) loadInfo
{
	if (self.post != nil)
	{
		// the completion block - when the news item is loaded
		completion_block_sd loadDone = ^(enum resultStatus status, NSDictionary *results)
		{
			[self.busy stopAnimating];
			self.subjectField.enabled = YES;
			self.bodyField.editable = YES;
			
			// get the post's body in quote format
			NSString *quoteBody = [results objectForKey:@"body"];
			
			// set it into the edit body
			self.bodyField.text = quoteBody;
			[self textViewDidChange:self.bodyField];			
			
			// set the cursor in Body
			[self.bodyField becomeFirstResponder];		
		};
		
		// load the post body for quote
		self.sendButton.enabled = NO;
		self.subjectField.enabled = NO;
		self.bodyField.editable = NO;
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getPostBodyQuote:self.site postId:self.post.postId completion:loadDone];
	}
	
	else if (self.edit != nil)
	{
		// the completion block - when the news item is loaded
		completion_block_sd loadDone = ^(enum resultStatus status, NSDictionary *results)
		{
			[self.busy stopAnimating];
			self.subjectField.enabled = YES;
			self.bodyField.editable = YES;
			
			// get the post's body in quote format
			NSString *body = [results objectForKey:@"body"];
			
			// set it into the edit body
			self.bodyField.text = body;
			[self textViewDidChange:self.bodyField];			
			
			// set the cursor in Body
			[self.bodyField becomeFirstResponder];		
		};
		
		// load the post body for quote
		self.sendButton.enabled = NO;
		self.subjectField.enabled = NO;
		self.bodyField.editable = NO;
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getPostBody:self.site postId:self.edit.postId completion:loadDone];
	}
}

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

// enable our post button only when we have subject and body
- (IBAction) updatePostAvailability:(id)sender
{
	BOOL complete = (([self.subjectField.text length] > 0) && ([self.bodyField hasText]));
	self.sendButton.enabled = complete;
}

#pragma mark - actions

- (void)doCancel
{
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
	NSString *actionTitle = nil;
	if (self.post != nil)
	{
		actionTitle = @"Do you want to discard this reply?";
	}
	
	else if (self.topic != nil)
	{
		actionTitle = @"Do you want to discard this reply?";
	}
	
	else if (self.edit != nil)
	{
		actionTitle = @"Do you want to discard changes to this post?";
	}
	else
	{
		actionTitle = @"Do you want to discard this new topic?";
	}

	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:actionTitle
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
	self.cancelButton.enabled = NO;
	self.sendButton.enabled = NO;
	
	// run callers completion block - send the body as plain text
	if (self.completion)
	{
		self.completion(self.subjectField.text, self.bodyField.text);
	}
	
	// take the send message view away
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender
{
	NSString *actionTitle = nil;
	if (self.post != nil)
	{
		actionTitle = @"Do you want to post this reply?";
	}
	
	else if (self.topic != nil)
	{
		actionTitle = @"Do you want to post this reply?";
	}
	
	else if (self.edit != nil)
	{
		actionTitle = @"Do you want to save changes to this post?";
	}
	else
	{
		actionTitle = @"Do you want to post this new topic?";
	}

	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:actionTitle
														delegate:self 
											   cancelButtonTitle:@"Resume Editing" 
										  destructiveButtonTitle:nil 
											   otherButtonTitles:@"Post", nil];
	action.tag = 2;
	[action showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
	[action release];
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
	static float THRESHOLD = 372;
	
	[self updatePostAvailability:nil];
	
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
