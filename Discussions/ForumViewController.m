/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/ForumViewController.m $
 * $Id: ForumViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "ForumViewController.h"
#import "NavBarTitle.h"
#import "Topic.h"
#import "TopicCellView.h"
#import "PostViewController.h"

@interface ForumViewController()

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UIToolbar	*toolbar;
@property (nonatomic, retain) Forum *forum;
@property (nonatomic, retain) NSString *forumId;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) UILabel *noneLabel;
@property (nonatomic, retain) NSArray /* <Topic> */ *topics;
@property (nonatomic, retain) NSString *forumTitle;
@property (nonatomic, retain) NSDate *lastReload;
@property (nonatomic, assign) NSTimeInterval autoReloadThreshold;
@property (nonatomic, retain) NSArray *fullToolbarItems;

@end

@implementation ForumViewController

@synthesize site, delegates;
@synthesize list, refresh, updated, updatedDate, updatedTime;
@synthesize toolbar, forum, forumId, busy, noneLabel, topics, forumTitle;
@synthesize lastReload, autoReloadThreshold;
@synthesize fullToolbarItems;

// The designated initializer.  
- (id)initWithForum:(Forum *)theForum site:(Site *)st delegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.autoReloadThreshold = 60;
		self.lastReload = nil;

		self.forum = theForum;
		if (theForum != nil)
		{
			self.forumTitle = theForum.title;
			self.topics = self.forum.topics;
			if (self.forum.topics != nil)
			{
				self.lastReload = self.forum.topicsLoaded;
			}
		}
		else
		{
			self.forumTitle = @"Recent Topics";
		}
		self.delegates = d;
		
		self.site = st;
		self.title = @"Topics";

		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
	}
	
    return self;
}

// Init with just the topic id to load  
- (id)initWithForumId:(NSString *)theForumId site:(Site *)st delegates:(id <Delegates>)d
{
    self = [super init];
    if (self)
	{
		self.autoReloadThreshold = 60;
		self.lastReload = nil;
		
		self.forumId = theForumId;
		
		// will to set the self.forumTitle and self.topics when we read the forum
		self.delegates = d;
		
		self.site = st;
		self.title = @"Topics";
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
	}
	
    return self;
}

- (TopicCellView *) cellViewForIndexPath:(NSIndexPath *)indexPath
{
	// the topic for this row
	Topic *t = [self.topics objectAtIndex:indexPath.row];

	TopicCellView *cell = [TopicCellView topicCellViewInTable:self.list];
	[cell setTitle:t.title];
	[cell setAuthor:t.author];
	[cell setTopicDatesWithOpen:t.open due:t.due];
	[cell setNumPosts:t.numPosts];
	[cell setUnreadIndicator:t.unread];
	[cell setBlocked:t.blocked];
	[cell setTopicType:t.type readOnly:(t.readOnly || t.pastDueLocked || t.forumReadOnly)
	   publishedHidden:(t.notYetOpen && t.hideTillOpen && t.published) unpublished:(!t.published)];

	return cell;
}

- (void) refreshView
{
	// cause the table to refresh
	[self.list reloadData];
	
	self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
	self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
	self.updated.hidden = NO;
	self.updatedDate.hidden = NO;
	self.updatedTime.hidden = NO;

	// hide the compose button if the user does not have permission to add a topic to the forum (or if we are doing recent topics)
	// forum type must be regularForum: replyOnlyForum and readOnlyForum cannot have new topics, nor can past due-locked ones.
	// Instructors, of course, can do anything
	[self.toolbar setItems:self.fullToolbarItems];
	if (!self.site.instructorPrivileges)
	{
		if ((self.forum == nil) || (self.forum.type != regularForum) || (self.forum.pastDueLocked))
		{
			NSArray *newItems = [NSArray arrayWithObjects:[self.toolbar.items objectAtIndex:0], nil];
			[self.toolbar setItems:newItems];
		}
	}
	
	// hide / show the "no topics" label
	self.noneLabel.hidden = ([self.topics count] != 0);

	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:YES];
	[self.list flashScrollIndicators];
}

- (void) loadInfo
{
	self.lastReload = [NSDate date];
	
	// for a specific forum
	if ((self.forum != nil) || (self.forumId != nil))
	{
		completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
		{
			Forum *updatedForum = [results objectForKey:@"forum"];
			
			// update our forum, if we have one
			if (self.forum != nil)
			{
				[self.forum setToMatch:updatedForum];
			}
			else
			{
				self.forum = updatedForum;
				self.forumTitle = self.forum.title;
			}

			// save the topics
			self.forum.topics = [results objectForKey:@"topics"];
			self.topics = self.forum.topics;

			[self.busy stopAnimating];
			self.refresh.enabled = YES;
			
			// get the data into the view
			[self refreshView];
		};

		NSString *theId = self.forumId;
		if (self.forum != nil) theId = self.forum.forumId;

		self.refresh.enabled = NO;
		self.updated.hidden = YES;
		self.updatedDate.hidden = YES;
		self.updatedTime.hidden = YES;
		self.updatedDate.text = @"";
		self.updatedTime.text = @"";
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getTopicsForForumId:theId site:self.site completion:completion];
	}

	// otherwise we are doing recents
	else
	{
		completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
		{
			// save the topics
			self.topics = results;
			
			[self.busy stopAnimating];
			self.refresh.enabled = YES;
			
			// get the data into the view
			[self refreshView];
		};

		self.refresh.enabled = NO;
		self.updated.hidden = YES;
		self.updatedDate.hidden = YES;
		self.updatedTime.hidden = YES;
		self.updatedDate.text = @"";
		self.updatedTime.text = @"";
		[self.busy startAnimating];
		[[self.delegates sessionDelegate].session getRecentTopicsForSite:self.site completion:completion];
	}
}

- (void) loadIfNeeded
{
	BOOL willReload = NO;

	// load if we have not loaded yet
	if (self.lastReload == nil) willReload = YES;
	
	// load if we have a threshold and are past it since last reload
	if ((self.autoReloadThreshold > 0) && (self.lastReload != nil) && (([self.lastReload timeIntervalSinceNow] * -1) > self.autoReloadThreshold))
		willReload = YES;
	
	// if we have no data
	if (self.topics == nil) willReload = YES;

	// reload if needed
	if (willReload)
	{
		[self loadInfo];
	}
	
	// if we have our data, just get it on the screen
	else
	{
		[self refreshView];
	}
}

- (void)dealloc
{
	[site release];
	[list release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[toolbar release];
	[forum release];
	[forumId release];
	[busy release];
	[noneLabel release];
	[topics release];
	[forumTitle release];
	[lastReload release];
	[fullToolbarItems release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIActivityIndicatorView *bsy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.busy = bsy;
	[bsy release];
	self.busy.center = CGPointMake(self.view.center.x, self.view.center.y - (2 * self.view.frame.origin.y));	
	[self.busy setColor:[UIColor darkGrayColor]];
	[self.busy stopAnimating];
	[self.view addSubview:self.busy];

    // Do any additional setup after loading the view from its nib.
	self.fullToolbarItems = self.toolbar.items;
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self loadIfNeeded];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// the topic for this row
	Topic *topic = [self.topics objectAtIndex:indexPath.row];

	// if blocked, don't go there
	if (topic.blocked) return;

	// go there
	TopicViewController *tvc= [[TopicViewController alloc] initWithTopic:topic site:self.site delegates:self.delegates loader:self];
	[self.navigationController pushViewController:tvc animated:YES];
	[tvc release];
}

// match the TopicCellView.xib
#define HEIGHT 73
#define TITLE_FONT boldSystemFontOfSize
#define TITLE_FONT_SIZE 14
#define TITLE_WIDTH 246
#define DATES_HEIGHT 15

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat adjust = 0;
	
	// the topic for this row
	Topic *topic = [self.topics objectAtIndex:indexPath.row];
	
	// title
	UIFont *font = [UIFont TITLE_FONT:TITLE_FONT_SIZE];
	CGSize theSize = [topic.title sizeWithFont:font constrainedToSize:CGSizeMake(TITLE_WIDTH, FLT_MAX)
								 lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / font.lineHeight;
	adjust += (font.lineHeight * (lines-1));
	
	// are we showing any dates
	BOOL hasDate = (topic.open != nil) || (topic.due != nil);
	
	// if no dates, reduce by the dates height
	if (!hasDate)
	{
		adjust -= DATES_HEIGHT;
	}
	
	CGFloat rv = HEIGHT + adjust;
	
//	TopicCellView *tcv = [self cellViewForIndexPath:indexPath];
//	if (tcv.frame.size.height != rv) NSLog(@"tcv mismatch path: %@   view height: %f   computed height: %f", indexPath, tcv.frame.size.height, rv);
	
	return rv;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.topics count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.forumTitle;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TopicCellView *cell = [self cellViewForIndexPath:indexPath];
	return cell;
}

#pragma mark - Actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

// add a new topic to the forum
- (IBAction)addTopic:(id)sender
{
	// on send - the body is in plain text
	completion_block_ss completion = ^(NSString *subject, NSString *body)
	{
		//NSLog(@"sending topic: subject:%@ body:%@", subject, body);
		completion_block_s whenPosted = ^(enum resultStatus status)
		{
			//NSLog(@"topic post complete: status:%d", status);
			
			// refresh to show the new post TODO: only if successful?
			[self refresh:nil];
		};
		[[self.delegates sessionDelegate].session sendTopicToForum:self.forum site:self.site subject:subject body:body completion:whenPosted plainText:YES];		
	};

	// create the send post view controller
	PostViewController *pvc = [[PostViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:pvc animated:NO];
	[pvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

#pragma mark - DataLoader

- (void) reloadDataWhenPossible
{
	// this will force a reload
	lastReload = nil;
}

@end
