/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/AnnouncementsViewController.m $
 * $Id: AnnouncementsViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "AnnouncementsViewController.h"
#import "ETMessage.h"
#import "NewsMessageViewController.h"
#import "DateFormat.h"
#import "NewsCell.h"
#import "ETMessage.h"
#import "NewsComposeViewController.h"

@interface AnnouncementsViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIToolbar	*toolbar;
@property (nonatomic, retain) UIBarButtonItem *compose;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) NSArray *announcements;
@property (nonatomic, retain) UILabel *noneLabel;
@property (nonatomic, retain) ETMessage *msgToDelete;

@end

@implementation AnnouncementsViewController

@synthesize list, toolbar, compose, refresh, updated, updatedDate, updatedTime, noneLabel, msgToDelete;
@synthesize announcements;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super initWithSite:st delegates:d title:@"News"];
    if (self)
	{
		// further initialization

		// tab bar item
		UIImage *image = [UIImage imageNamed:@"newspaper.png"];
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:self.title image:image tag:0];
		self.tabBarItem = item;
		[item release];
	}
	
    return self;
}

- (void)dealloc
{
	[list release];
	[toolbar release];
	[compose release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[announcements release];
	[noneLabel release];
	[msgToDelete release];

    [super dealloc];
}

- (void) adjustView
{
	// hide the compose button if the user does not have permission
	if (!self.site.allowNewAnnouncement)
	{
		NSArray *newItems = [NSArray arrayWithObjects:[self.toolbar.items objectAtIndex:0], nil];
		[self.toolbar setItems:newItems];
	}
}

- (NewsCell *) newsCellAtIndex:(NSInteger)index
{
	ETMessage *msg = [self.announcements objectAtIndex:index];

	NewsCell *cell = [NewsCell newsCellInTable:self.list];

	[cell setSubject:msg.subject];
	[cell setDate:msg.date draft:msg.draft released:msg.released releaseDate:msg.releaseDate];
	[cell setUnread:msg.unread];
	
	return cell;
}

- (void) refreshView
{
	// cause the table to refresh
	[self.list reloadData];
	
	// hide / show the "no news" label
	self.noneLabel.hidden = ([self.announcements count] != 0);
}

- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the announcements are loaded
	completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
	{
		// save the forums
		self.announcements = results;

		[self.busy stopAnimating];
		self.refresh.enabled = YES;

		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		[self refreshView];
	};
	
	// load up the sites (get one more than then limit so we know if there are more or not)
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";
	[self.busy startAnimating];
	[[self.delegates sessionDelegate ].session getAnnouncementsForSite:self.site limit:0 completion:completion];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
}

- (void) processDelete:(ETMessage *)msg
{
	// delete from Etudes
	completion_block_sd whenDeleted = ^(enum resultStatus status, NSDictionary *def)
	{
		if (status == success)
		{
			NSNumber *editLockAlert = [def objectForKey:@"editLockAlert"];
			if ([editLockAlert boolValue])
			{
				UIAlertView *alert = [[UIAlertView alloc]
									  initWithTitle: @"Alert"
									  message: @"This item is currently being edited.  Your delete was not accepted."
									  delegate: self
									  cancelButtonTitle: @"OK"
									  otherButtonTitles: nil];
				[alert show];
				[alert release];
			}
			
			else
			{
				NSMutableArray *newAnnouncements = [NSMutableArray arrayWithArray:self.announcements];
				[newAnnouncements removeObject:msg];
				self.announcements = newAnnouncements;
				
				// refresh to show the deleted message
				[self refreshView];
			}
		}
	};
	[[self.delegates sessionDelegate].session deleteNewsForSite:self.site messageId:msg.messageId completion:whenDeleted];		
}

#pragma mark - Table view delegate

// assume system font 17, and initial height of 55, label width of 260 - match the NewsCell.xib
#define FONT boldSystemFontOfSize
#define FONT_SIZE 17
#define HEIGHT 55
#define WIDTH 260

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIFont *font = [UIFont FONT:FONT_SIZE];

	ETMessage *msg = [self.announcements objectAtIndex:indexPath.row];

	CGSize theSize = [msg.subject sizeWithFont:font constrainedToSize:CGSizeMake(WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / font.lineHeight;
	return HEIGHT + (font.lineHeight * (lines-1));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// on delete
	completion_block_m onDelete = ^(ETMessage *msg)
	{
		[self processDelete:msg];
	};
	
	// the announcement
	ETMessage *msg = [self.announcements objectAtIndex:indexPath.row];
	
	// go there
	NewsMessageViewController *mvc = [[NewsMessageViewController alloc] initWithMessage:msg fromList:self.announcements
																				   site:self.site
																			  delegates:self.delegates
																			   onDelete:onDelete];	
	[self.navigationController pushViewController:mvc animated:YES];
	[mvc release];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.announcements count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NewsCell *cell = [self newsCellAtIndex:indexPath.row];
	return cell;
}

// reply to a delete from the table
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// the announcement to delete if confirmed
	self.msgToDelete = [self.announcements objectAtIndex:indexPath.row];
	
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this item?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Delete" 
											   otherButtonTitles:nil];
	// set the action sheet's tag to a 1 to distinguish it from the login confirm
	action.tag = 1;

	// Note: for some reason, showInView:self.view  results in a sheet with a disabled cancel button!
	[action showFromBarButtonItem:self.refresh animated:YES];				   
	[action release];
}

// only allow editing if self.site.allowNewAnnouncement
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.site.allowNewAnnouncement) return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

#pragma mark - Actions

// compose a new announcement
- (IBAction)compose:(id)sender
{
	// on send - body is plain text
	completion_block_ssbb completion = ^(NSString *subject, NSString *body, BOOL draft, BOOL priority)
	{
		// NSLog(@"sending news item: subject:%@ body:%@", subject, body);
		completion_block_s whenPosted = ^(enum resultStatus status)
		{
			// NSLog(@"post complete: status:%d", status);
			
			// refresh to show the new post TODO: only if successful?
			[self refresh:nil];
		};
		[[self.delegates sessionDelegate].session sendNewNewsForSite:self.site
															 subject:subject body:body draft:draft priority:priority completion:whenPosted plainText:YES];		
	};

	// create the new compose view controller
	NewsComposeViewController *ncvc = [[NewsComposeViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:ncvc animated:NO];
	[ncvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// if not our tag=1 sheet, super
	if (actionSheet.tag != 1)
	{
		[super actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
		 return;
	}

	// index 0 is the logout confirmation
	if (buttonIndex == 0)
	{
		[self processDelete:self.msgToDelete];
	}
	
	self.msgToDelete = nil;
}

@end
