/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Login/LoginViewController.m $
 * $Id: LoginViewController.m 11714 2015-09-24 22:36:20Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011 Etudes, Inc.
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

#import "LoginViewController.h"

@interface LoginViewController()

@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) UITextField *userId;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, assign) BOOL visible;

- (void)registerForKeyboardNotifications;

@end

@implementation LoginViewController

@synthesize delegates, completion;
@synthesize scroll, userId, password, loginButton, busy, visible;

#pragma mark - lifecycle

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		// further initialization
		self.delegates = d;
	}
	
    return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = @"Login";
	
	// add our buttons
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(cancelLogin:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	[self registerForKeyboardNotifications];
	
	// set the content size of the scroll
	self.scroll.contentSize = self.scroll.frame.size;
	
	// set the login information from prefs
	NSString *eid = [[self.delegates preferencesDelegate] userEid];
	NSString *pw = [[self.delegates preferencesDelegate] password];
	if (eid != nil)
	{
		userId.text = eid;
		
		if (pw != nil)
		{
			password.text = pw;
		}
	}

	// setup text field delegates
	[self.userId setDelegate:self];
	[self.password setDelegate:self];

	// clear busy
	[self.busy stopAnimating];
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.visible = NO;
	[super viewWillDisappear:animated];
}

- (void)dealloc
{
	[completion release];

	[userId release];
	[password release];
	[loginButton release];
	[scroll release];
	[busy release];

	[super dealloc];
}

#pragma mark - button actions

- (IBAction)help:(id)sender
{
	NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
	NSURL *url = [NSURL URLWithString:@"/e3/docs/login_help.html" relativeToURL:baseUrl];

	[[self.delegates sessionDelegate] helpFromViewController:self title:@"Login Help" url:url];
}

- (IBAction)cancelLogin:(id)sender
{
	// take the login view away
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
	
	// run callers completion block
	if (self.completion)
	{
		self.completion(notLoggedIn);
	}
}

- (IBAction)login:(id)sender
{
	completion_block_s completionBlock = ^(enum resultStatus status)
	{
		// run only if still visible
		if (self.visible)
		{
			// success?
			if (status == success)
			{
				// take the login view away
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
				
				// run callers completion block
				if (self.completion)
				{
					self.completion(status);
				}
			}

			else if (status == accessDenied)
			{
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle: @"Denied"
									  message: @"Incorrect user id or password."
									  delegate: self
									  cancelButtonTitle: @"OK"
									  otherButtonTitles: nil];
				[alert show];
				[alert release];
			}
			
			// re-enable the UI elements
			self.loginButton.enabled = YES;
			self.userId.enabled = YES;
			self.password.enabled = YES;
			[self.busy stopAnimating];
		}
	};
	
	// drop the keyboard if up
	[self.userId resignFirstResponder];
	[self.password resignFirstResponder];

	// prepare the UI for being busy / sending
	self.loginButton.enabled = NO;
	self.userId.enabled = NO;
	self.password.enabled = NO;
	[self.busy startAnimating];

	[[[self.delegates sessionDelegate] session] loginAsUser:userId.text password:self.password.text completion:completionBlock];
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

	// scroll the password text field into view (so both fields are in view)
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbSize.height;
	if (!CGRectContainsPoint(aRect, self.password.frame.origin))
	{
		CGPoint scrollPoint = CGPointMake(0.0, (self.password.frame.origin.y-kbSize.height)+20);
		[self.scroll setContentOffset:scrollPoint animated:YES];
	}
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	self.scroll.contentInset = contentInsets;
	self.scroll.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// YES to stop editing, NO to continue
	BOOL rv = NO;

	// for the UserId field, keep editing, but focus on the password field
	if (textField == self.userId)
	{
		[self.password becomeFirstResponder];
	}
	else
	{
		rv = YES;
		[self login:nil];
	}
	
	return rv;
}

@end
