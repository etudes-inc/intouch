/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/MemberViewController.m $
 * $Id: MemberViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "MemberViewController.h"
#import "NavBarTitle.h"
#import "SendMessageViewController.h"
#import "MembersInSections.h"
#import "EtudesColors.h"

@interface MemberViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Member *member;
@property (nonatomic, retain) NSArray /* <Member> */ *members;
@property (nonatomic, retain) NSString *memberId;
@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *role;
@property (nonatomic, retain) UILabel *iid;
@property (nonatomic, retain) UITableView *list;
@property (nonatomic, assign) BOOL canSendEmail;
@property (nonatomic, retain) UIActivityIndicatorView *avatarLoading;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSArray *cells;
@property (nonatomic, retain) NSArray *actions;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) IBOutlet UIImageView *statusIcon;

@end

@implementation MemberViewController

@synthesize site, delegates, member, members, memberId, avatar, name, list, role, iid;
@synthesize canSendEmail, avatarLoading, scrollView, cells, actions, busy, statusIcon;

// The designated initializer - with a member  
- (id)initWithMember:(Member *)mbr fromList:(NSArray *)mbrs site:(Site *)st delegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
		
		self.site = st;
		self.title = @"Member";
		self.member = mbr;
		self.members = mbrs;

		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
		
		// check if email sending is enabled
		self.canSendEmail = [MFMailComposeViewController canSendMail];

		// next and prev
		NSUInteger pos = [self.members indexOfObject:self.member];
		
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
		if (pos < [self.members count]-1)
		{
			[nextPrevControl setEnabled:YES forSegmentAtIndex:1];			
		}
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:nextPrevControl];
		[nextPrevControl release];
		self.navigationItem.rightBarButtonItem = button;
		[button release];
	}
	
    return self;
}

// The designated initializer - with just a member id  
- (id)initWithMemberId:(NSString *)mbrId site:(Site *)st delegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
		
		self.site = st;
		self.title = @"Member";
		self.memberId = mbrId;
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
		
		// check if email sending is enabled
		self.canSendEmail = [MFMailComposeViewController canSendMail];

		// No next / prev in this mode

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

- (void)dealloc
{
	[site release];
	[member release];
	[members release];
	[memberId release];
	[avatar release];
	[name release];
	[list release];
	[role release];
	[iid release];
	[avatarLoading release];
	[scrollView release];
	[cells release];
	[actions release];
	[busy release];
	[statusIcon release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) setupStatus:(enum ParticipantStatus)status
{
	NSString *iconName = nil;
	NSString *ext = @"png";
	
	switch (status)
	{
		case enrolled_participantStatus:
			iconName = @"user_enrolled";
			self.name.textColor = [UIColor blackColor];
			break;
			
		case dropped_participantStatus:
			iconName = @"user_dropped";
			self.name.textColor = [UIColor colorEtudesRed];
			break;
			
		case blocked_participantStatus:
			// for instructors, we show the blocked, but otherwise, we use the dropped icon
			if (self.site.instructorPrivileges)
			{
				iconName = @"user_blocked";
			}
			else
			{
				iconName = @"user_dropped";
			}
			self.name.textColor = [UIColor colorEtudesRed];
			break;

		case hat_participantStatus:
			iconName = @"user_suit";
			self.name.textColor = [UIColor blackColor];
			break;
	}
	
	UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:iconName ofType:ext]];
	self.statusIcon.image = image;
}

- (void) loadAvatar:(NSString *)theAvatar
{
	completion_block_i completion = ^(UIImage * image)
	{
		[self.avatarLoading stopAnimating];
		if (image != nil)
		{
			self.avatar.image = image;
		}
	};

	if (theAvatar != nil)
	{
		[self.avatarLoading startAnimating];
		[[self.delegates sessionDelegate].session loadAvatarImage:theAvatar completion:completion];
	}
	else
	{
		// reload non-avatar
		UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"non-avatar" ofType:@"jpg"]];
		self.avatar.image = image;
	}
}

- (void) loadCells
{
	NSMutableArray *newCells = [[NSMutableArray alloc] init];
	NSMutableArray *newActions = [[NSMutableArray alloc] init];
	
	// include PM unless the member is not active
	if (self.member.active)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = @"send a message";
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.detailTextLabel.textColor = [UIColor blueColor];
		cell.textLabel.text = @"message";
		
		[newActions addObject:[NSValue valueWithPointer:@selector(sendMessage)]];
		
		[cell release];
	}

	if (self.member.showEmail && self.member.email != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.email;
		if (self.canSendEmail)
		{
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.detailTextLabel.textColor = [UIColor blueColor];
		}
		else
		{
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		cell.textLabel.text = @"email";

		[newActions addObject:[NSValue valueWithPointer:@selector(sendEmail)]];
		
		[cell release];
	}

	if (self.member.website != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.website;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.detailTextLabel.textColor = [UIColor blueColor];
		cell.textLabel.text = @"www";
		
		[newActions addObject:[NSValue valueWithPointer:@selector(visitWebsite)]];
		
		[cell release];		
	}

	if (self.member.facebook != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.facebook;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.detailTextLabel.textColor = [UIColor blueColor];
		cell.textLabel.text = @"Facebook";
		
		[newActions addObject:[NSValue valueWithPointer:@selector(sendFacebook)]];
		
		[cell release];		
	}
	
	if (self.member.twitter != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.twitter;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.detailTextLabel.textColor = [UIColor blueColor];
		cell.textLabel.text = @"Twitter";
		
		[newActions addObject:[NSValue valueWithPointer:@selector(sendTwitter)]];
		
		[cell release];		
	}

	if (self.member.msn != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.msn;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"MSN";

		[newActions addObject:[NSValue valueWithPointer:NULL]];
		
		[cell release];		
	}

	if (self.member.yahoo != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.yahoo;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"Yahoo";
		
		[newActions addObject:[NSValue valueWithPointer:NULL]];
		
		[cell release];		
	}

	if (self.member.aim != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.aim;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"AIM";
		
		[newActions addObject:[NSValue valueWithPointer:NULL]];
		
		[cell release];		
	}

	if (self.member.location != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.location;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"location";
		
		[newActions addObject:[NSValue valueWithPointer:NULL]];
		
		[cell release];		
	}
	
	if (self.member.occupation != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.occupation;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"occupation";
		
		[newActions addObject:[NSValue valueWithPointer:NULL]];
		
		[cell release];		
	}
	
	if (self.member.interests != nil)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
		[newCells addObject:cell];
		
		cell.detailTextLabel.text = self.member.interests;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"interests";
		
		[newActions addObject:[NSValue valueWithPointer:NULL]];
		
		[cell release];		
	}

	self.cells = newCells;
	[newCells release];
	
	self.actions = newActions;
	[newActions release];
}

- (void) loadFields
{
	self.name.text = self.member.displayName;
	// for instructors, we will show the exact role, but otherwise, we will show "student" for "blocked"
	if ((self.site.instructorPrivileges) || (!([self.member.role isEqualToString:@"Blocked"])))
	{
		self.role.text = self.member.role;
	}
	else
	{
		self.role.text = @"Student";
	}
	[self loadAvatar:self.member.avatar];
	[self setupStatus:self.member.status];

	if ((self.site.instructorPrivileges) && (self.member.iid != nil))
	{
		self.iid.text = self.member.iid;
	}
	else
	{
		self.iid.text = nil;
	}

	// the list's height to begin with
	//CGSize listSize = self.list.frame.size;
	
	// build an info cell for each info we will show
	[self loadCells];
	
	// compute the list's height
	NSUInteger tableHeight = (2 * 10 /* header and footer*/) + (self.cells.count * 44 /* row height */);
	
	[self.list setFrame:CGRectMake(self.list.frame.origin.x, self.list.frame.origin.y,
								   self.list.frame.size.width, tableHeight)];
	
	// move the send message button down
	//[self.message setFrame:CGRectMake(self.message.frame.origin.x, self.message.frame.origin.y + (tableHeight - listSize.height),
	//								  self.message.frame.size.width, self.message.frame.size.height)];
	
	// set the content size
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.list.frame.origin.y + self.list.frame.size.height);
	
	// cause the table to refresh
	[self.list reloadData];
}

- (void) loadInfo
{
	// if we have a member, go right into it
	if (self.member != nil)
	{
		[self loadFields];
	}
	
	// otherwise we need to load the members, and find our member
	else
	{
		// the completion block - when the announcements are loaded
		completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
		{
			// save the forums
			MembersInSections *membersInSections = [MembersInSections membersInSectionsWithMembers:results];
			
			// find this member - don't set the list thought, since we don't support next/prev in this mode
			self.member = [membersInSections memberWithId:self.memberId];

			[self.busy stopAnimating];
			
			// load the UI
			[self loadFields];
		};

		// load up the members
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getMembersForSite:self.site refresh:NO completion:completion];	
	}	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
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

// send a PM
- (IBAction) sendMessage
{
	// on send - the body is in plain text
	completion_block_SendMessageViewController completion = ^(NSArray *to, NSString *replyToMessageId, NSString *subject, NSString *body)
	{
		// NSLog(@"sending PM: to:%@ subject:%@ body:%@", to, subject, body);
		completion_block_s whenSent = ^(enum resultStatus status)
		{
			// NSLog(@"PM send complete: status:%d", status);
		};

		[[self.delegates sessionDelegate].session sendPrivateMessageTo:to site:self.site subject:subject body:body completion:whenSent plainText:YES];		
	};

	// create the send message view controller, with "to" preset
	SendMessageViewController *smvc = [[SendMessageViewController alloc] initWithSite:self.site
																			delegates:self.delegates whenDone:completion toUser:self.member.userId displayingName:self.member.displayName];

	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:smvc animated:NO];
	[smvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// send email to the user's email address
- (void) sendEmail
{
	// ignore if no email set or cannot send
	if ((self.member.email == nil) || (!self.member.showEmail) || (!self.canSendEmail)) return;

	// create a mail compose popup
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;

	// fill in some fields
	[controller setBccRecipients:[NSArray arrayWithObject:[[[self.delegates sessionDelegate] session] email]]];
	[controller setToRecipients:[NSArray arrayWithObject:self.member.email]];
	
	// present the popup
	[self presentViewController:controller animated:YES completion:nil];
	[controller release];
}

// load the user's website
- (void) visitWebsite
{
	if (self.member.website == nil) return;

	NSURL *url = [NSURL URLWithString:self.member.website];
	[[UIApplication sharedApplication] openURL:url];
}

// send to facebook
- (void) sendFacebook
{
	NSString *address = [NSString stringWithFormat:@"http://www.facebook.com/%@",self.member.facebook];

	NSURL *url = [NSURL URLWithString:address];
	[[UIApplication sharedApplication] openURL:url];	
}

// send to twitter
- (void) sendTwitter
{
	NSString *address = [NSString stringWithFormat:@"http://twitter.com/#!/%@",self.member.facebook];
	
	NSURL *url = [NSURL URLWithString:address];
	[[UIApplication sharedApplication] openURL:url];	
}

// respond to the next/prev control
- (IBAction) nextPrev:(id)control
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *) control;
	NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
	
	// which message position
	NSUInteger pos = [self.members indexOfObject:self.member];
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
		if (pos < [self.members count]-1)
		{
			pos++;
		}
	}

	// reset with the new member
	self.member = [self.members objectAtIndex:pos];
	[self loadInfo];
	
	// reset enabled for the controls
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	if (pos > 0)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	}
	if (pos < [self.members count] -1)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSValue *value = [self.actions objectAtIndex:indexPath.row];
	if ([value pointerValue] != NULL)
	{
		SEL selector = [value pointerValue];
		[self performSelector:selector];
	}

	// clear the selection
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.cells count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.cells objectAtIndex:indexPath.row];
	return cell;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// dismiss the compose popup
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
