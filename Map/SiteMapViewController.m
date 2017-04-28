/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapViewController.m $
 * $Id: SiteMapViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SiteMapViewController.h"
#import "CourseMapItem.h"
#import "SiteMapCellView.h"
#import "SiteMapHeaderCellView.h"
#import "SiteMapDetailViewController.h"
#import "EtudesColors.h"
#import "SiteViewController.h"
#import "MemberViewController.h"
#import "SyllabusViewController.h"
#import "TopicViewController.h"
#import "ForumViewController.h"
#import "DiscussionsViewController.h"
#import "ModuleViewController.h"
#import "AssessmentViewController.h"

@interface SiteMapViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) CourseMap *map;
@property (nonatomic, retain) ActivityItem *aItem;
@property (nonatomic, retain) NSArray *aItems;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, assign) BOOL showIdView;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *avatarLoading;
@property (nonatomic, retain) IBOutlet UIImageView *statusIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *sectionLabel;
@property (nonatomic, retain) IBOutlet UILabel *iidLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *filteredControl;
@property (nonatomic, retain) IBOutlet UIView *idView;
@property (nonatomic, retain) IBOutlet UILabel *noneLabel;

@end

@implementation SiteMapViewController

@synthesize list, map, aItem, aItems, refresh, updated, updatedDate, updatedTime, toolbar, showIdView;
@synthesize avatarImage, avatarLoading, statusIcon, nameLabel, sectionLabel, iidLabel, filteredControl, idView, noneLabel;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super initWithSite:st delegates:d title:@"Map"];
    if (self)
	{
		// further initialization
		self.showIdView = NO;
		self.aItem = nil;
		self.aItems = nil;

		// setup a tab bar item
		UIImage *image = [UIImage imageNamed:@"Checkmark.png"];
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:self.title image:image tag:0];
		self.tabBarItem = item;
		[item release];
    }
	
    return self;
}

// Init with an ActivityMeter item
- (id)initWithSite:(Site *)theSite delegates:(id <Delegates>)theDelegates item:(ActivityItem *)theItem fromList:(NSArray *)theList
{
    self = [super initAsNavWithSite:theSite delegates:theDelegates title:@"Map"];
    if (self)
	{
		// further initialization
		self.showIdView = YES;

		self.aItem = theItem;
		self.aItems = theList;
		
		// get the Updated time from the ActivityItem load
		// we don't do any auto-refresh - just use the activity items list that was loaded
		self.autoReloadThreshold = 0;

		// next and prev
		NSUInteger pos = [self.aItems indexOfObject:self.aItem];
		
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
		if (pos < [self.aItems count]-1)
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

- (void)dealloc
{
	[list release];
	[map release];
	[aItem release];
	[aItems release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[toolbar release];
	[avatarImage release];
	[avatarLoading release];
	[statusIcon release];
	[nameLabel release];
	[sectionLabel release];
	[iidLabel release];
	[idView release];
	[filteredControl release];
	[noneLabel release];

    [super dealloc];
}

- (void) setupStatus:(enum ParticipantStatus)status
{
	// match logic to the progress column in myEtudes's coursemap in list.xml
	NSString *name = nil;
	NSString *ext = @"png";
	
	switch (status)
	{
		case enrolled_participantStatus:
			name = @"user_enrolled";
			self.nameLabel.textColor = [UIColor blueColor];
			break;
			
		case dropped_participantStatus:
			name = @"user_dropped";
			self.nameLabel.textColor = [UIColor colorEtudesRed];
			break;
			
		case blocked_participantStatus:
			name = @"user_blocked";
			self.nameLabel.textColor = [UIColor colorEtudesRed];
			break;
		
		case hat_participantStatus:
			name = @"user_suit";
			self.nameLabel.textColor = [UIColor colorEtudesRed];
			break;
	}
	
	UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
	self.statusIcon.image = image;
}

- (void) setupSection:(NSString *)section
{
	if (section != nil)
	{
		self.sectionLabel.hidden = NO;
		self.sectionLabel.text = [NSString stringWithFormat:@"section %@", self.aItem.section];
	}
	else
	{
		self.sectionLabel.hidden = YES;
	}
}

- (void) setupIid:(NSString *)iid
{
	if (iid != nil)
	{
		self.iidLabel.hidden = NO;
		self.iidLabel.text = iid;
	}
	else
	{
		self.iidLabel.hidden = YES;
	}
}

- (void) loadAvatar:(NSString *)theAvatar
{
	completion_block_i completion = ^(UIImage * image)
	{
		[self.avatarLoading stopAnimating];
		if (image != nil)
		{
			self.avatarImage.image = image;
		}
	};
	
	if (theAvatar != nil)
	{
		[self.avatarLoading startAnimating];
		[[self.delegates sessionDelegate].session loadAvatarImage:theAvatar completion:completion];
	}
	else
	{
		UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"non-avatar" ofType:@"jpg"]];
		self.avatarImage.image = image;
	}
}

- (SiteMapHeaderCellView *) headerCellForItem:(CourseMapItem *)item
{
	if (item.type != header_type) return nil;
	
	SiteMapHeaderCellView *cell = [SiteMapHeaderCellView siteMapHeaderCellViewInTable:self.list];
	
	[cell setTitle:item.title];

	return cell;
}

- (SiteMapCellView *) itemCellForItem:(CourseMapItem *)item
{
	if (item.type == header_type) return nil;

	SiteMapCellView *cell = [SiteMapCellView siteMapCellViewInTable:self.list];

	[cell setTitle:item.title];
	[cell setIcon:[item imageForType]];
	if ([item hideActivityInAM:(self.aItem != nil)])
	{
		// no progress icon
		[cell setProgress:nil];
		
		// either allow closed, invalid or unpublished - everything else shows as available
		enum CourseMapItemDisplayStatus status = available_cmids;
		if ((item.itemDisplayStatus1 == closedOn_cmids) || (item.itemDisplayStatus2 == closedOn_cmids))
		{
			status = closedOn_cmids;
		}
		else if ((item.itemDisplayStatus1 == unpublished_cmids) || (item.itemDisplayStatus2 == unpublished_cmids))
		{
			status = unpublished_cmids;
		}
		else if ((item.itemDisplayStatus1 == invalid_cmids) || (item.itemDisplayStatus2 == invalid_cmids))
		{
			status = invalid_cmids;
		}
		else if ((item.itemDisplayStatus1 == archived_cmids) || (item.itemDisplayStatus2 == archived_cmids))
		{
			status = archived_cmids;
		}
		
		[cell setStatus:[item statusTextForDisplayStatus:status] color:[item statusTextColorForDisplayStatus:status]];
		[cell setStatus2:nil color:nil];				
	}
	else
	{
		[cell setProgress:[item imageForProgress]];
		[cell setStatus:[item statusText] color:[item statusTextColor]];
		[cell setStatus2:[item statusText2] color:[item statusTextColor2]];
	}
	
	if ((item.accessStatus == invalid_accessStatus) || (item.accessStatus == archived_accessStatus)
		|| (item.accessStatus == unpublished_accessStatus) || (item.accessStatus == published_hidden_accessStatus))
	{
		[cell setHidden];
	}
	
	// for syllabus items that the user has access too, and if we are not in AM, make it active
	else if ((item.type == syllabus_type) && (!item.blocked) && (item.accessStatus == published_accessStatus) && (self.aItem == nil))
	{
		[cell setActive];
	}
	
	else if ((item.type == topic_type) && (!item.blocked) &&
			 ((item.accessStatus == published_accessStatus) || (item.accessStatus == published_closed_access_accessStatus) || (item.accessStatus == published_closed_accessStatus)) &&
			 (self.aItem == nil))
	{
		[cell setActive];
	}
	
	else if ((item.type == forum_type) && (!item.blocked) &&
			 ((item.accessStatus == published_accessStatus) || (item.accessStatus == published_closed_access_accessStatus) || (item.accessStatus == published_closed_accessStatus)) &&
			 (self.aItem == nil))
	{
		[cell setActive];
	}
	
	else if ((item.type == category_type) && (!item.blocked) &&
			 ((item.accessStatus == published_accessStatus) || (item.accessStatus == published_closed_access_accessStatus) || (item.accessStatus == published_closed_accessStatus)) &&
			 (self.aItem == nil))
	{
		[cell setActive];
	}
	
	else if ((item.type == module_type) && (!item.blocked) &&
			 ((item.accessStatus == published_accessStatus) || (item.accessStatus == published_closed_access_accessStatus)) &&
			 (self.aItem == nil))
	{
		[cell setActive];
	}
	
	else if (((item.type == assignment_type) || (item.type == survey_type) || (item.type == test_type))
			 && (!item.blocked) 
			 && ((item.accessStatus == published_accessStatus) || (item.accessStatus == published_closed_access_accessStatus) || (item.accessStatus == published_closed_accessStatus))
			 && (self.aItem == nil))
	{
		[cell setActive];
	}

	return cell;
}

- (UITableViewCell *) cellForIndex:(NSIndexPath *)indexPath
{
	CourseMapItem *item = [self.map.filteredItems objectAtIndex:indexPath.row];
	if (item.type == header_type)
	{ 
		return [self headerCellForItem:item];
	}
	else
	{
		return [self itemCellForItem:item];
	}
}

- (void) refreshView
{
	// cause the table to refresh
	[self.list reloadData];

	// load the id view if needed
	if (self.showIdView)
	{
		self.nameLabel.text = self.aItem.name;
		[self setupStatus:self.aItem.status];
		[self setupSection:self.aItem.section];
		[self setupIid:self.aItem.userIid];
		[self loadAvatar:self.aItem.avatar];
	}
	
	// show the no items label if needed
	self.noneLabel.hidden = ([self.map.filteredItems count] != 0);
}

// called on viewDidLoad to load up data
- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the map is loaded
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		[self.busy stopAnimating];
		self.refresh.enabled = YES;
		
		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		// save the map
		self.map = [results objectForKey:@"courseMap"];

		// is filtered selected?
		BOOL isFiltered = (self.filteredControl.selectedSegmentIndex == 0);
		[self.map setFiltered:isFiltered];

		// update the display
		[self refreshView];
	};

	// clear the refresh fields
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";

	// load the map
	[self.busy startAnimating];
	[[self.delegates sessionDelegate].session getCourseMapForSite:self.site forUserId:self.aItem.userId completion:completion];
}

// set the action for touching the avatar or name
- (void) setAvatarTouchTarget:(id)target action:(SEL)action
{
	UIGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self.avatarImage addGestureRecognizer:avatarTap];
	[avatarTap release];

	avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self.nameLabel addGestureRecognizer:avatarTap];
	[avatarTap release];
}

- (void) adjustView
{
	[super adjustView];

	// enable the id view if needed
	if (self.showIdView)
	{		
		// push the list down to reveal the id section
		[self.list setFrame:CGRectMake(self.list.frame.origin.x, self.list.frame.origin.y + self.idView.frame.size.height,
									   self.list.frame.size.width, self.list.frame.size.height - self.idView.frame.size.height)];
		[self.noneLabel setFrame:CGRectMake(self.noneLabel.frame.origin.x, self.noneLabel.frame.origin.y + self.idView.frame.size.height,
									   self.noneLabel.frame.size.width, self.noneLabel.frame.size.height)];
		self.idView.hidden = NO;	
	}
	
	[self setAvatarTouchTarget:self action:@selector(avatarWasTapped:)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
}

#pragma mark - Table view delegate

// match SiteMapCellView.xib
#define HEIGHT 81
#define TITLE_FONT boldSystemFontOfSize
#define TITLE_FONT_SIZE 17
#define TITLE_WIDTH 228
#define STATUS_FONT systemFontOfSize
#define STATUS_FONT_SIZE 14
#define STATUS_WIDTH 243
#define STATUS_HEIGHT 22

- (CGFloat)tableView:(UITableView *)tableView heightForItem:(CourseMapItem *)item
{
	CGFloat adjust = 0;

	// title
	UIFont *font = [UIFont TITLE_FONT:TITLE_FONT_SIZE];
	CGSize theSize = [item.title sizeWithFont:font constrainedToSize:CGSizeMake(TITLE_WIDTH, FLT_MAX)
								lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / font.lineHeight;
	adjust += (font.lineHeight * (lines-1));
	
	// status 1 & 2
	NSString *status1 = nil;
	NSString *status2 = nil;
	
	if ([item hideActivityInAM:(self.aItem != nil)])
	{
		// either allow closed, invalid or unpublished - everything else shows as available
		enum CourseMapItemDisplayStatus status = available_cmids;
		if ((item.itemDisplayStatus1 == closedOn_cmids) || (item.itemDisplayStatus2 == closedOn_cmids))
		{
			status = closedOn_cmids;
		}
		else if ((item.itemDisplayStatus1 == unpublished_cmids) || (item.itemDisplayStatus2 == unpublished_cmids))
		{
			status = unpublished_cmids;
		}
		else if ((item.itemDisplayStatus1 == invalid_cmids) || (item.itemDisplayStatus2 == invalid_cmids))
		{
			status = invalid_cmids;
		}
		else if ((item.itemDisplayStatus1 == archived_cmids) || (item.itemDisplayStatus2 == archived_cmids))
		{
			status = archived_cmids;
		}
		
		status1 = [item statusTextForDisplayStatus:status];
	}
	else
	{
		status1 = [item statusText];
		status2 = [item statusText2];
	}
	
	if (status1 != nil)
	{
		UIFont *font = [UIFont STATUS_FONT:STATUS_FONT_SIZE];
		CGSize theSize = [status1 sizeWithFont:font constrainedToSize:CGSizeMake(STATUS_WIDTH, FLT_MAX)
								 lineBreakMode:NSLineBreakByWordWrapping];
		int lines = theSize.height / font.lineHeight;
		adjust += (font.lineHeight * (lines-1));
	}
	
	if (status2 != nil)
	{
		UIFont *font = [UIFont STATUS_FONT:STATUS_FONT_SIZE];
		CGSize theSize = [status2 sizeWithFont:font constrainedToSize:CGSizeMake(STATUS_WIDTH, FLT_MAX)
								 lineBreakMode:NSLineBreakByWordWrapping];
		int lines = theSize.height / font.lineHeight;
		adjust += (font.lineHeight * (lines-1));
	}
	else
	{
		adjust -= STATUS_HEIGHT;
	}
	
	CGFloat rv = HEIGHT + adjust;
	
//	SiteMapCellView *smcv = [self itemCellForItem:item];
//	if (smcv.frame.size.height != rv) NSLog(@"smcv mismatch: view height: %f   computed height: %f", smcv.frame.size.height, rv);
	
	return rv;
}

// match SiteMapHeaderCellView.xib
#define HEADER_HEIGHT 37
#define HEADER_TITLE_FONT italicSystemFontOfSize
#define HEADER_TITLE_FONT_SIZE 17
#define HEADER_TITLE_WIDTH 268

- (CGFloat)tableView:(UITableView *)tableView heightForHeader:(CourseMapItem *)item
{
	CGFloat adjust = 0;
	
	// title
	UIFont *font = [UIFont HEADER_TITLE_FONT:HEADER_TITLE_FONT_SIZE];
	CGSize theSize = [item.title sizeWithFont:font constrainedToSize:CGSizeMake(HEADER_TITLE_WIDTH, FLT_MAX)
								lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / font.lineHeight;
	adjust += (font.lineHeight * (lines-1));

	CGFloat rv = HEADER_HEIGHT + adjust;
	
//	SiteMapHeaderCellView *smhcv = [self headerCellForItem:item];
//	if (smhcv.frame.size.height != rv) NSLog(@"smhcv mismatch: view height: %f   computed height: %f", smhcv.frame.size.height, rv);
	
	return rv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CourseMapItem *item = [self.map.filteredItems objectAtIndex:indexPath.row];
	if (item.type == header_type)
	{
		return [self tableView:tableView heightForHeader:item];
	}
	else
	{
		return [self tableView:tableView heightForItem:item];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CourseMapItem *cmi = [self.map.filteredItems objectAtIndex:indexPath.row];

	BOOL drillingDown = YES;

	// for an available syllabus item, not from AM
	if ((cmi.type == syllabus_type) && (!cmi.blocked) && (cmi.accessStatus == published_accessStatus) && (self.aItem == nil))
	{
		SyllabusViewController *svc = [[SyllabusViewController alloc] initWitSite:self.site delegates:self.delegates accepted:cmi.complete];
		[self.navigationController pushViewController:svc animated:YES];
		[svc release];
	}

	// for a forum topic
	else if ((cmi.type == topic_type) && (!cmi.blocked) &&
			 ((cmi.accessStatus == published_accessStatus) || (cmi.accessStatus == published_closed_access_accessStatus) || (cmi.accessStatus == published_closed_accessStatus)) &&
			 (self.aItem == nil))
	{
		TopicViewController *tvc = [[TopicViewController alloc] initWithTopicId:cmi.topicId site:self.site delegates:self.delegates loader:nil];		
		[self.navigationController pushViewController:tvc animated:YES];
		[tvc release];
	}
	
	// for a forum forum
	else if ((cmi.type == forum_type) && (!cmi.blocked) &&
			 ((cmi.accessStatus == published_accessStatus) || (cmi.accessStatus == published_closed_access_accessStatus) || (cmi.accessStatus == published_closed_accessStatus)) &&
			 (self.aItem == nil))
	{
		ForumViewController *fvc = [[ForumViewController alloc] initWithForumId:cmi.forumId site:self.site delegates:self.delegates];		
		[self.navigationController pushViewController:fvc animated:YES];
		[fvc release];
	}

	// for a forum category
	else if ((cmi.type == category_type) && (!cmi.blocked) &&
			 ((cmi.accessStatus == published_accessStatus) || (cmi.accessStatus == published_closed_access_accessStatus) || (cmi.accessStatus == published_closed_accessStatus)) &&
			 (self.aItem == nil))
	{
		DiscussionsViewController *dvc = [[DiscussionsViewController alloc] initAsNavWithSite:self.site delegates:self.delegates focusOnCategoryId:cmi.categoryId];		
		[self.navigationController pushViewController:dvc animated:YES];
		[dvc release];
	}

	// for a module
	else if ((cmi.type == module_type) && (!cmi.blocked) &&
			 ((cmi.accessStatus == published_accessStatus) || (cmi.accessStatus == published_closed_access_accessStatus)) &&
			 (self.aItem == nil))
	{
		ModuleViewController *mvc = [[ModuleViewController alloc] initWitSite:self.site delegates:self.delegates moduleId:cmi.providerId];		
		[self.navigationController pushViewController:mvc animated:YES];
		[mvc release];
	}
	
	// for AT&S
	else if (((cmi.type == survey_type) || (cmi.type == assignment_type) || (cmi.type == test_type))
			 && (!cmi.blocked)
			 && ((cmi.accessStatus == published_accessStatus) || (cmi.accessStatus == published_closed_access_accessStatus) || (cmi.accessStatus == published_closed_accessStatus))
			 && (self.aItem == nil))
	{
		AssessmentViewController *avc = [[AssessmentViewController alloc] initWitSite:self.site
																			delegates:self.delegates assessmentId:cmi.providerId
																	  assessmentTitle:cmi.title assessmentType:cmi.type];
		[self.navigationController pushViewController:avc animated:YES];
		[avc release];
	}

	// if there is something else, we are not going anywere
	else
	{
		drillingDown = NO;
	}
	
	// if we are going to an item, visiting the item has a good chance of causing our map to be outdated, so we will force a reload when we get back
	if (drillingDown)
	{
		self.lastReload = nil;
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	CourseMapItem *cmi = [self.map.filteredItems objectAtIndex:indexPath.row];
	
	if (cmi.type == header_type) return;

	// create the detail view controller
	SiteMapDetailViewController *smdvc = [[SiteMapDetailViewController alloc]
										  initWithSite:self.site delegates:self.delegates courseMapItem:cmi
										  fromList:self.map.nonHeaderItems inAM:(self.aItem != nil)];

	// go there
	[self.navigationController pushViewController:smdvc animated:YES];
	[smdvc release];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.map.filteredItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self cellForIndex:indexPath];
	return cell;
}

#pragma mark - actions

// refresh
- (IBAction) refresh:(id)sender
{
	[self loadInfo];
}

// respond to the filtered control
- (IBAction) studentAll:(id)control
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *) control;
	NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
	// 0 - student, 1 - all
	
	if (selectedSegment == 0)
	{
		[self.map setFiltered:YES];
	}
	else
	{
		[self.map setFiltered:NO];
	}

	// update the display
	[self refreshView];
}

// respond to the next/prev control
- (IBAction) nextPrev:(id)control
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *) control;
	NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
	
	// which message position
	NSUInteger pos = [self.aItems indexOfObject:self.aItem];
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
		if (pos < [self.aItems count]-1)
		{
			pos++;
		}
	}
	
	// reset with the new item
	self.aItem = [self.aItems objectAtIndex:pos];

	// update the display
	[self loadInfo];

	// reset enabled for the controls
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	if (pos > 0)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	}
	if (pos < [self.aItems count] -1)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}

// respond to a tap on the avatar
- (IBAction) avatarWasTapped:(UIGestureRecognizer *)sender 
{
	MemberViewController *mvc = [[MemberViewController alloc] initWithMemberId:aItem.userId site:self.site delegates:self.delegates];
	[self.navigationController pushViewController:mvc animated:YES];
	[mvc release];
}

@end
