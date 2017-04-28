/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/DiscussionsViewController.m $
 * $Id: DiscussionsViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "DiscussionsViewController.h"
#import "Category.h"
#import "ForumViewController.h"
#import "ChatViewController.h"
#import "ForumCellView.h"
#import "CategoryHeaderView.h"

@interface DiscussionsViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSArray /* <Category> */ *categories;
@property (nonatomic, retain) NSString *chatName;
@property (nonatomic, assign) BOOL chatPresence;

@end

@implementation DiscussionsViewController

@synthesize list, refresh, updated, updatedDate, updatedTime, categoryId;
@synthesize categories, chatName, chatPresence;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super initWithSite:st delegates:d title:@"Forums"];
    if (self)
	{
		// further initialization

		// tab bar item
		UIImage *image = [UIImage imageNamed:@"Chats.png"];
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:self.title image:image tag:0];
		self.tabBarItem = item;
		[item release];
	}

    return self;
}

// Init as a nav view, not the top tab bar view, focused on a particular category
- (id)initAsNavWithSite:(Site *)st delegates:(id <Delegates>)d focusOnCategoryId:(NSString *)cid
{
    self = [super initAsNavWithSite:st delegates:d title:@"Forums"];
    if (self)
	{
		// further initialization
		self.categoryId = cid;
	}
	
    return self;
}

- (CategoryHeaderView *) headerViewForSection:(NSInteger)section
{
	CategoryHeaderView *header = nil;
	
	if (((section > 0) && (section-1 < [self.categories count])) || (self.categoryId != nil))
	{
		// if we are focused on a category, this is the only section
		NSInteger index = 0;
		if (self.categoryId == nil)
		{
			// otherwise, recents / chat are in position 0
			index = section-1;
		}
		
		// the category for this section
		Category *category = [self.categories objectAtIndex:index];
		
		header = [CategoryHeaderView categoryHeaderView];
		[header setCategoryTitle:category.title];
		[header setPublishedHidden:(category.published && category.hideTillOpen && category.notYetOpen)];
		[header setBlocked:category.blocked];
		[header setCategoryDatesWithOpen:category.open due:category.due];
	}
	
	// for recents or chat
	else if (section == 0)
	{
		header = [CategoryHeaderView categoryHeaderView];
		[header setCategoryTitle:nil];
		[header setCategoryDatesWithOpen:nil due:nil];
	}

	return header;
}

- (ForumCellView *) cellViewForIndexPath:(NSIndexPath *)indexPath
{
	ForumCellView *cell = nil;

	if (((indexPath.section > 0) && (indexPath.section-1 < [self.categories count])) || (self.categoryId != nil))
	{
		// if we are focused on a category, this is the only section
		NSInteger index = 0;
		if (self.categoryId == nil)
		{
			// otherwise, recents / chat are in position 0
			index = indexPath.section-1;
		}
		
		// the category for this section
		Category *category = [self.categories objectAtIndex:index];
		
		// the forum
		Forum *forum = [category.forums objectAtIndex:indexPath.row];
		
		cell = [ForumCellView forumCellViewInTable:self.list];
		[cell setForumTitle:forum.title];
		[cell setIconsUnPublished:(!forum.published) pubHidden:(forum.published && forum.hideTillOpen && forum.notYetOpen)
						 readOnly:((forum.type == readOnlyForum) || (forum.pastDueLocked)) replyOnly:(forum.type == replyOnlyForum)];
		[cell setNumTopics:forum.numTopics];
		[cell setUnreadIndicator:forum.unread];
		[cell setBlocked:forum.blocked];
		[cell setForumDatesWithOpen:forum.open due:forum.due];
		[cell setForumDescription:forum.forumDescription];
	}
	
	// for recents or chat
	else if (indexPath.section == 0)
	{
		// chat
		if ((self.chatName != nil) && (indexPath.row == 0))
		{
			cell = [ForumCellView forumCellViewInTable:self.list];
			[cell setForumTitle:[NSString stringWithFormat:@"Chat - %@", self.chatName]];
			[cell setPresentIndicator:self.chatPresence];
			[cell setBlocked:NO];
			[cell setForumDatesWithOpen:nil due:nil];
			[cell setForumDescription:nil];
		}
		
		// recent topics
		else
		{
			cell = [ForumCellView forumCellViewInTable:self.list];
			[cell setForumTitle:@"Recent Topics"];
			[cell setUnreadIndicator:NO];
			[cell setBlocked:NO];
			[cell setForumDatesWithOpen:nil due:nil];
			[cell setForumDescription:nil];
		}
	}

	return cell;
}

- (void) refreshView
{	
	// cause the table to refresh
	[self.list reloadData];
}

- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the forums are loaded
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// save the forums
		self.categories = [results objectForKey:@"categories"];

		// and chat info
		self.chatName = [results objectForKey:@"chatName"];
		NSNumber *the_chatPresence = [results objectForKey:@"chatPresence"];
		self.chatPresence = NO;
		if (the_chatPresence != nil)
		{
			self.chatPresence = [the_chatPresence boolValue];
		}

		[self.busy stopAnimating];
		self.refresh.enabled = YES;

		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		[self refreshView];
	};

	// clear the refresh fields
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";

	// get the forums
	[self.busy startAnimating];
	[[self.delegates sessionDelegate ].session getForumsForSite:self.site category:self.categoryId completion:completion];	
}

- (void)dealloc
{
	[list release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[categoryId release];
	[categories release];
	[chatName release];

	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (((indexPath.section > 0) && (indexPath.section-1 < [self.categories count])) || (self.categoryId != nil))
	{
		// if we are focused on a category, this is the only section
		NSInteger index = 0;
		if (self.categoryId == nil)
		{
			// otherwise, recents / chat are in position 0
			index = indexPath.section-1;
		}

		// the category for this section
		Category *category = [self.categories objectAtIndex:index];

		// the forum
		Forum *forum = [category.forums objectAtIndex:indexPath.row];

		// if the forum is blocked, don't go there
		if (forum.blocked) return;

		// go there
		ForumViewController *fvc= [[ForumViewController alloc] initWithForum:forum site:self.site delegates:self.delegates];
		[self.navigationController pushViewController:fvc animated:YES];
		[fvc release];
	}

	// for recents or chat
	else if (indexPath.section == 0)
	{
		// chat
		if ((self.chatName != nil) && (indexPath.row == 0))
		{
			// push on the chat view
			ChatViewController *cvc = [[ChatViewController alloc] initWithSite:self.site delegates:self.delegates];
			[self.navigationController pushViewController:cvc animated:YES];
			[cvc release];
		}
		
		// recent topics
		else
		{
			ForumViewController *fvc= [[ForumViewController alloc] initWithForum:nil site:self.site delegates:self.delegates];
			[self.navigationController pushViewController:fvc animated:YES];
			[fvc release];
		}
	}
}

// match the ForumCellView.xib
#define HEIGHT 77.0
#define TITLE_FONT boldSystemFontOfSize
#define TITLE_FONT_SIZE 17
#define TITLE_WIDTH 229
#define DESCRIPTION_FONT systemFontOfSize
#define DESCRIPTION_FONT_SIZE 14
#define DESCRIPTION_WIDTH 229
#define DESCRIPTION_HEIGHT 16
#define DATES_HEIGHT 22

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat adjust = 0;

	// for the forums
	if (((indexPath.section > 0) && (indexPath.section-1 < [self.categories count])) || (self.categoryId != nil))
	{
		// if we are focused on a category, this is the only section
		NSInteger index = 0;
		if (self.categoryId == nil)
		{
			// otherwise, recents / chat are in position 0
			index = indexPath.section-1;
		}
		
		// the category for this section
		Category *category = [self.categories objectAtIndex:index];
		
		// the forum
		Forum *forum = [category.forums objectAtIndex:indexPath.row];
		
		// title
		if (forum.title != nil)
		{
			UIFont *font = [UIFont TITLE_FONT:TITLE_FONT_SIZE];
			CGSize theSize = [forum.title sizeWithFont:font constrainedToSize:CGSizeMake(TITLE_WIDTH, FLT_MAX)
										 lineBreakMode:NSLineBreakByWordWrapping];
			int lines = theSize.height / font.lineHeight;
			adjust += (font.lineHeight * (lines-1));
		}
		
		// are we showing any icons
		BOOL hasIcon = (!forum.published) || (forum.published && forum.hideTillOpen && forum.notYetOpen) ||
						((forum.type == readOnlyForum) || (forum.pastDueLocked)) || (forum.type == replyOnlyForum);
		
		// are we showing any dates
		BOOL hasDate = (forum.open != nil) || (forum.due != nil);
		
		// description
		if (forum.forumDescription != nil)
		{
			UIFont * font = [UIFont DESCRIPTION_FONT:DESCRIPTION_FONT_SIZE];
			CGSize theSize = [forum.forumDescription sizeWithFont:font constrainedToSize:CGSizeMake(DESCRIPTION_WIDTH, FLT_MAX)
											   lineBreakMode:NSLineBreakByWordWrapping];
			int lines = theSize.height / font.lineHeight;
			
			adjust += (font.lineHeight * (lines-1));
		}
		else
		{
			// if no description and no dates and no icons, reduce by description
			if (!hasIcon && !hasDate)
			{
				adjust -= DESCRIPTION_HEIGHT;
			}
		}
		
		// if no date and no icon, reduce by the dates height
		if (!hasIcon && !hasDate)
		{
			adjust -= DATES_HEIGHT;
		}
	}
	
	// for chat and recent
	else
	{
		// chat - title may be multi line
		if ((self.chatName != nil) && (indexPath.row == 0))
		{
			NSString *title = [NSString stringWithFormat:@"Chat - %@", self.chatName];
			UIFont *font = [UIFont TITLE_FONT:TITLE_FONT_SIZE];
			CGSize theSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(TITLE_WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
			int lines = theSize.height / font.lineHeight;
			adjust += (font.lineHeight * (lines-1));
		}
		
		// no dates or description or icons
		adjust -= DESCRIPTION_HEIGHT;
		adjust -= DATES_HEIGHT;
	}
	
	CGFloat rv = HEIGHT + adjust;
	
//	ForumCellView *fcv = [self cellViewForIndexPath:indexPath];
//	if (fcv.frame.size.height != rv) NSLog(@"fcv mismatch path: %@   view height: %f   computed height: %f", indexPath, fcv.frame.size.height, rv);

	return rv;
}

// match the CategoryHeaderView.xib
#define CHV_HEIGHT 60
#define CHV_TITLE_FONT boldSystemFontOfSize
#define CHV_TITLE_FONT_SIZE 17
#define CHV_TITLE_WIDTH 274
#define CHV_DATES_HEIGHT 20

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat adjust = 0;
	
	// for forum categories
	if (((section > 0) && (section-1 < [self.categories count])) || (self.categoryId != nil))
	{
		// if we are focused on a category, this is the only section
		NSInteger index = 0;
		if (self.categoryId == nil)
		{
			// otherwise, recents / chat are in position 0
			index = section-1;
		}
		
		// the category for this section
		Category *category = [self.categories objectAtIndex:index];
		
		// title
		UIFont *font = [UIFont CHV_TITLE_FONT:CHV_TITLE_FONT_SIZE];
		CGSize theSize = [category.title sizeWithFont:font constrainedToSize:CGSizeMake(CHV_TITLE_WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
		int lines = theSize.height / font.lineHeight;
		adjust += (font.lineHeight * (lines-1));

		// are we showing any icons
		BOOL hasIcon = ((category.published && category.hideTillOpen && category.notYetOpen) || category.blocked);
		
		// are we showing any dates
		BOOL hasDate = (category.open != nil) || (category.due != nil);
		
		// if no date and no icon, reduce by the dates height
		if (!hasIcon && !hasDate)
		{
			adjust -= CHV_DATES_HEIGHT;
		}
	}
	
	// for chat and recent
	else
	{
		adjust -= CHV_DATES_HEIGHT;
	}
	
	CGFloat rv = CHV_HEIGHT + adjust;
	
//	CategoryHeaderView *chv = [self headerViewForSection:section];
//	if (chv.frame.size.height != rv) NSLog(@"chv mismatch section: %d   view height: %f   computed height: %f", section, chv.frame.size.height, rv);

	return rv;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [self headerViewForSection:section];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// a section for each category, and one more for chat/recent topics, unless we are focused on a specific category
	unsigned long count = [self.categories count];
	if (self.categoryId == nil) count++;

	return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (((section > 0) && (section-1 < [self.categories count])) || (self.categoryId != nil))
	{
		// if we are focused on a category, this is the only section
		NSInteger index = 0;
		if (self.categoryId == nil)
		{
			// otherwise, recents / chat are in position 0
			index = section-1;
		}

		// the category for this section
		Category *category = [self.categories objectAtIndex:index];
		
		return [category.forums count];
	}
	else
	{
		// recents / chat category entries
		return (self.chatName == nil) ? 1 : 2;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellViewForIndexPath:indexPath];
}

#pragma mark - Actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

@end
