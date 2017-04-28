/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Site/SiteMsgsViewController.m $
 * $Id: SiteMsgsViewController.m 1429 2011-04-26 17:56:28Z ggolden $
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

#import "SiteMsgsViewController.h"
#import "Message.h"
#import "MessageViewController.h"
#import "GatewayViewController.h"
#import "SitesViewController.h"
#import "AnnouncementsViewController.h"
#import "MessagesViewController.h"
#import "DiscussionsViewController.h"
#import "ChatViewController.h"
#import "NavBarTitle.h"
#import "TopicViewController.h"

@interface SiteMsgsViewController()

@property (nonatomic, retain) Site *site;

@property (nonatomic, assign) id <EtudesServerSessionDelegate> sessionDelegate;
@property (nonatomic, assign) id <NavDelegate> navDelegate;

@property (nonatomic, copy) NSArray *announcements;
@property (nonatomic, copy) NSArray *privateMessages;
@property (nonatomic, copy) NSArray *topics;
@property (nonatomic, copy) NSArray *chats;

@property (nonatomic, retain) UITableView *list;

@end

@implementation SiteMsgsViewController

@synthesize sessionDelegate, navDelegate;
@synthesize site;
@synthesize announcements, privateMessages, topics, chats;
@synthesize list;

// The designated initializer.  
- (id)initWithSite:(Site *)st sessionDelegate:(id <EtudesServerSessionDelegate>)sd navDelegate:(id <NavDelegate>)nd
{
    self = [super init];
    if (self)
	{
		self.sessionDelegate = sd;
		self.navDelegate = nd;

		self.site = st;
		self.title = @"Messages";
		
		// logout button
		UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(logout:)];
		self.navigationItem.rightBarButtonItem = logoutButton;
		[logoutButton release];

		// change site button
		UIBarButtonItem *sitesButton = [[UIBarButtonItem alloc] initWithTitle:@"Sites"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(sites:)];
		self.navigationItem.leftBarButtonItem = sitesButton;
		[sitesButton release];
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];

		UIImage *image = [UIImage imageNamed:@"mailopened.png"];
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Messages" image:image tag:0];
		self.tabBarItem = item;
		[item release];		
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

// show 3 recent items
#define LIMIT 3

- (void) loadInfo
{
	// the completion block - when the announcements are loaded
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// save the announcements, privateMessages, posts and chats
		self.announcements = [results objectForKey:@"announcements"];
		self.privateMessages = [results objectForKey:@"privateMessages"];
		self.topics = [results objectForKey:@"topics"];
		self.chats = [results objectForKey:@"chats"];

		// cause the table to refresh
		[self.list reloadData];
	};
	
	// load up the sites (get one more than then limit so we know if there are more or not)
	[self.sessionDelegate.session getRecentMessagesForSite:self.site limit:LIMIT+1 completion:completion];	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self loadInfo];
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
	[site release];

	[announcements release];
	[privateMessages release];
	[topics release];
	[chats release];

	[list release];

    [super dealloc];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the message
	Message *msg = nil;
	NSArray *msgList = nil;
	NSString *type = nil;
	switch (indexPath.section)
	{
		case 0:
		{
			if ((indexPath.row < [self.announcements count]) && (indexPath.row < LIMIT))
			{
				msg = [self.announcements objectAtIndex:indexPath.row];
				msgList = self.announcements;
				type = @"Announcement";
			}
			else
			{
				// push on the announcements view
				AnnouncementsViewController *avc = [[AnnouncementsViewController alloc] initWithSite:self.site sessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
				[self.navigationController pushViewController:avc animated:YES];
				[avc release];
			}
			break;
		}
		case 1:
		{
			if ((indexPath.row < [self.privateMessages count]) && (indexPath.row < LIMIT))
			{
				msg = [self.privateMessages objectAtIndex:indexPath.row];
				msgList = self.privateMessages;
				type = @"Message";
			}
			else
			{
				// push on the messages view
				MessagesViewController *mvc = [[MessagesViewController alloc] initWithSite:self.site sessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
				[self.navigationController pushViewController:mvc animated:YES];
				[mvc release];
			}
			break;
		}
		case 2:
		{
			if ((indexPath.row < [self.topics count]) && (indexPath.row < LIMIT))
			{
				// push on the topics view
				Topic *topic = [self.topics objectAtIndex:indexPath.row];
				
				// go there
				TopicViewController *tvc= [[TopicViewController alloc] initWithTopic:topic forum:nil site:self.site sessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
				[self.navigationController pushViewController:tvc animated:YES];
				[tvc release];
			}
			else
			{
				// push on the discussions view
				DiscussionsViewController *dvc = [[DiscussionsViewController alloc] initWithSite:self.site sessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
				[self.navigationController pushViewController:dvc animated:YES];
				[dvc release];
			}
			break;
		}
		case 3:
		{
			// push on the chat view (no individual chat message detail views)
			ChatViewController *cvc = [[ChatViewController alloc] initWithSite:self.site sessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
			[self.navigationController pushViewController:cvc animated:YES];
			[cvc release];
			break;
		}
		default:
			break;
	}

	// go there
	if (msg != nil)
	{
		MessageViewController *mvc = [[MessageViewController alloc] initWithMessage:msg fromList:msgList type:type site:self.site sessionDelegate:self.sessionDelegate];	
		[self.navigationController pushViewController:mvc animated:YES];
		[mvc release];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	// 0 - recent announcements / announcements
	// 1 - new private messages / private messages
	// 2 - new discussion posts / discussions
	// 3 - recent chats
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
		{
			return @"Recent Announcements";
			break;
		}
		case 1:
		{
			return @"Private Messages";
			break;
		}
		case 2:
		{
			return @"Recent Topics";
			break;
		}
		case 3:
		{
			return @"Chat";
			break;
		}
		default:
			break;
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	switch (section)
	{
		case 0:
		{
			// limit to LIMIT, plus a "see all"
			if ([self.announcements count] > LIMIT)
			{
				return LIMIT + 1;
			}
			else
			{
				return [self.announcements count] + 1;
			}
			break;
		}
		case 1:
		{
			// limit to LIMIT, plus a "see all"
			if ([self.privateMessages count] > LIMIT)
			{
				return LIMIT + 1;
			}
			else
			{
				return [self.privateMessages count] + 1;
			}
			break;
		}
		case 2:
		{
			// limit to LIMIT, plus a "see all"
			if ([self.topics count] > LIMIT)
			{
				return LIMIT + 1;
			}
			else
			{
				return [self.topics count] + 1;
			}
			break;
		}
		case 3:
		{
			// limit to LIMIT, plus a "see all"
			if ([self.chats count] > LIMIT)
			{
				return LIMIT +1 ;
			}
			else
			{
				return [self.chats count] + 1;
			}
			break;
		}
		default:
			break;
	}
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// each section is different...
	switch (indexPath.section)
	{
		case 0:
		{
			// announcement - more
			// TODO: different cell type?  font?
			if ((indexPath.row == LIMIT) || (indexPath.row >= [self.announcements count]))
			{
				cell.textLabel.text = @"see all announcements";
				cell.detailTextLabel.text = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}

			// announcement detail
			else
			{
				Message *msg = [self.announcements objectAtIndex:indexPath.row];
				cell.textLabel.text = msg.subject;
				cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@ - %@)", msg.date, msg.from];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		}
		case 1:
		{
			// private messages - more
			// TODO: different cell type?  font?
			if ((indexPath.row == LIMIT) || (indexPath.row >= [self.privateMessages count]))
			{
				cell.textLabel.text = @"see all private messages";
				cell.detailTextLabel.text = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			// private messages detail
			else
			{
				Message *msg = [self.privateMessages objectAtIndex:indexPath.row];
				cell.textLabel.text = msg.subject;
				cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@ - %@)", msg.date, msg.from];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		}
		case 2:
		{
			// discussion posts - more
			// TODO: different cell type?  font?
			if ((indexPath.row == LIMIT) || (indexPath.row >= [self.topics count]))
			{
				cell.textLabel.text = @"see all discussions";
				cell.detailTextLabel.text = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			// discussion posts detail
			else
			{
				Topic *topic = [self.topics objectAtIndex:indexPath.row];
				cell.textLabel.text = topic.title;
				// TODO: post topic / category?
				cell.detailTextLabel.text = [NSString stringWithFormat:@"(by %@ - in %@)", topic.author, topic.forum];				
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		}
		case 3:
		{
			// chats - more
			// TODO: different cell type?  font?
			if ((indexPath.row == LIMIT) || (indexPath.row >= [self.chats count]))
			{
				cell.textLabel.text = @"see full chat";
				cell.detailTextLabel.text = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			// chats detail
			else
			{
				Message *msg = [self.chats objectAtIndex:indexPath.row];
				cell.textLabel.text = msg.subject;
				cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@ - %@)", msg.date, msg.from];
				cell.accessoryType = UITableViewCellSeparatorStyleNone;
			}
			break;
		}
			
		default:
			break;
	}
	
	return cell;
}

#pragma mark -
#pragma mark Actions

- (IBAction)logout:(id)sender
{
	// logout the session
	[self.sessionDelegate.session logout];
	
	// put the gateway up
	UINavigationController *nav = [[UINavigationController alloc] init];
	GatewayViewController *gvc = [[GatewayViewController alloc] initWithSessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
	[nav pushViewController:gvc animated:NO];
	[gvc release];
	[self.navDelegate setMainViewController: nav direction:-1];
	[nav release];
}

- (IBAction)sites:(id)sender
{
	// put the sites up
	UINavigationController *nav = [[UINavigationController alloc] init];
	SitesViewController *svc = [[SitesViewController alloc] initWithSessionDelegate:self.sessionDelegate navDelegate:self.navDelegate];
	[nav pushViewController:svc animated:NO];
	[svc release];
	[self.navDelegate setMainViewController: nav direction:0];
	[nav release];
}

@end
