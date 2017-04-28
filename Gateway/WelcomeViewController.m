/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Gateway/WelcomeViewController.m $
 * $Id: WelcomeViewController.m 2683M 2015-09-25 02:48:23Z (local) $
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

#import "WelcomeViewController.h"
#import "SitesViewController.h"
#import "TextEditCell.h"

@interface WelcomeViewController()

@property (nonatomic, assign) id <Delegates> delegates;

@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, retain) UITableView *fields;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) UILabel *versionLabel;
@property (nonatomic, retain) UILabel *inst1Label;
@property (nonatomic, retain) UILabel *inst2Label;
@property (nonatomic, retain) NSArray /* TextEditCell */ *cells;
@property (nonatomic, assign) UITextField *loginField;
@property (nonatomic, assign) UITextField *passwordField;

- (void)registerForKeyboardNotifications;

@end

@implementation WelcomeViewController

@synthesize delegates, scroll, fields, loginButton, busy, versionLabel, inst1Label, inst2Label, cells, loginField, passwordField;

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
	}

    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// busy
	UIActivityIndicatorView *bsy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	bsy.center = CGPointMake(self.view.center.x, self.view.center.y - (2 * self.view.frame.origin.y));	
	[bsy stopAnimating];
	[self.view addSubview:bsy];
	self.busy = bsy;
	[bsy release];
	
	// the editing fields
	TextEditCell *cell1 = [TextEditCell textEditCell];
	TextEditCell *cell2 = [TextEditCell textEditCell];
	
	self.cells = [NSArray arrayWithObjects:cell1, cell2, nil];
	self.loginField = cell1.textField;
	self.passwordField = cell2.textField;
	
	cell1.textField.delegate = self;
	cell1.titleLabel.text =@"User id";
	cell1.textField.returnKeyType = UIReturnKeyNext;
	cell1.textField.placeholder = @"Etudes User id";
	
	cell2.textField.delegate = self;
	cell2.titleLabel.text = @"Password";
	cell2.textField.secureTextEntry = YES;
	cell2.textField.returnKeyType =UIReturnKeyGo;
	cell2.textField.placeholder = @"Required";
	
	inst1Label.textColor = [UIColor blueColor];
	inst2Label.textColor = [UIColor blueColor];
	UIGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginHelp:)];
	[self.inst1Label addGestureRecognizer:avatarTap];
	[avatarTap release];

	avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginHelp:)];
	[self.inst2Label addGestureRecognizer:avatarTap];
	[avatarTap release];

	// the nav bar title (version info and app name)
	NSString *version = [NSString stringWithFormat:@"%@ / %@",
						 [[self.delegates sessionDelegate] session].version, [[self.delegates sessionDelegate] session].build];
	self.versionLabel.text = version;

	// fit under the status bar up top (20 pixels)
	[self.view setFrame:CGRectMake(0, 20, 320, 460)];

	[self registerForKeyboardNotifications];
	
	// set the content size of the scroll
	self.scroll.contentSize = self.scroll.frame.size;

	// set the login information from preferences
	NSString *eid = [[self.delegates preferencesDelegate] userEid];
	NSString *pw = [[self.delegates preferencesDelegate] password];
	if (eid != nil)
	{
		self.loginField.text = eid;
		
		if (pw != nil)
		{
			self.passwordField.text = pw;
		}
	}
}

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
	[scroll release];
	[fields release];
	[loginButton release];
	[busy release];
	[versionLabel release];
	[inst1Label release];
	[inst2Label release];
	[cells release];
	
    [super dealloc];
}

#pragma mark actions

- (IBAction)login:(id)sender
{
	completion_block_s completionBlock = ^(enum resultStatus status)
	{
		// success?
		if (status == success)
		{
			// make a sites view (in a nav)
			UINavigationController *nav = [[UINavigationController alloc] init];
			SitesViewController *sites = [[SitesViewController alloc] initWithDelegates:self.delegates];
			[nav pushViewController:sites animated:NO];
			[sites release];
			
			// make sites the new main navigation controller
			[[self.delegates navDelegate] setMainViewController:nav direction:0];
			[nav release];
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
		self.loginField.enabled = YES;
		self.passwordField.enabled = YES;
		[self.busy stopAnimating];
	};
	
	// drop the keyboard if up
	[self.loginField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	
	// prepare the UI for being busy / sending
	self.loginButton.enabled = NO;
	self.loginField.enabled = NO;
	self.passwordField.enabled = NO;
	[self.busy startAnimating];
	
	[[[self.delegates sessionDelegate] session] loginAsUser:self.loginField.text password:self.passwordField.text completion:completionBlock];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TextEditCell *cell = [self.cells objectAtIndex:indexPath.row];
	return cell.frame.size.height;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.cells count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TextEditCell *cell = [self.cells objectAtIndex:indexPath.row];
	return cell;
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
	
/*	// scroll the login area into view
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbSize.height;
	if (!CGRectContainsPoint(aRect, self.loginButton.frame.origin))
	{
		CGPoint scrollPoint = CGPointMake(0.0, (self.loginButton.frame.origin.y-kbSize.height)+38);
		[self.scroll setContentOffset:scrollPoint animated:YES];
	}*/
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
	if (self.loginField == textField)
	{
		[self.passwordField becomeFirstResponder];
	}
	else
	{
		rv = YES;
		[self login:nil];
	}

	return rv;
}

#pragma mark - actions

// respond to a tap on the avatar
- (IBAction) loginHelp:(UIGestureRecognizer *)sender 
{
	NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
	NSURL *url = [NSURL URLWithString:@"/e3/docs/login_help.html" relativeToURL:baseUrl];
	
	[[self.delegates sessionDelegate] helpFromViewController:self title:@"Login Help" url:url];
}

@end
