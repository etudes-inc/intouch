/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Messages/MessagesViewController.m $
 * $Id: MessagesViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "MessagesViewController.h"
#import "MessageViewController.h"
#import "MessagesCellView.h"
#import "SendMessageViewController.h"
#import "DateFormat.h"

@interface MessagesViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UILabel *noneLabel;
@property (nonatomic, retain) NSArray /* <ETMessage> */ *messages;
@property (nonatomic, retain) ETMessage *msgToDelete;

@end

@implementation MessagesViewController

@synthesize list, refresh, updated, updatedDate, updatedTime, noneLabel, messages, msgToDelete;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super initWithSite:st delegates:d title:@"Messages"];
    if (self)
	{
		// further initialization

		// tab bar item
		UIImage *image = [UIImage imageNamed:@"mailopened.png"];
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:self.title image:image tag:0];
		self.tabBarItem = item;
		[item release];		
	}
	
    return self;
}

- (void)dealloc
{
	[list release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[noneLabel release];
	[messages release];
	[msgToDelete release];

    [super dealloc];
}

- (MessagesCellView *) cellAtIndex:(NSInteger)index
{
	ETMessage *msg = [self.messages objectAtIndex:index];

	MessagesCellView *cell = [MessagesCellView messagesCellViewInTable:self.list];

	[cell setSubject:msg.subject];
	[cell setFrom:msg.from];
	[cell setDate:msg.date];
	// TODO: [cell setPreviewText:msg.body];
	[cell setUnread:msg.unread replied:msg.replied];

	return cell;
}

- (void) refreshView
{
	// cause the table to refresh
	[self.list reloadData];
	
	// hide or show the "no messages" label
	self.noneLabel.hidden = ([self.messages count] != 0);
}

- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the announcements are loaded
	completion_block_sa completion = ^(enum resultStatus status, NSArray *results)
	{
		// save the forums
		self.messages = results;

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
	[[self.delegates sessionDelegate].session getPrivateMessagesForSite:self.site limit:0 completion:completion];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:animated];
	[self.list flashScrollIndicators];
}

// process a delete
- (void) processDelete:(ETMessage *)msg
{
	// delete from Etudes
	completion_block_sd whenDeleted = ^(enum resultStatus status, NSDictionary *def)
	{
		if (status == success)
		{
			NSMutableArray *newMessages = [NSMutableArray arrayWithArray:self.messages];
			[newMessages removeObject:msg];
			self.messages = newMessages;
			
			// refresh to show the deleted message
			[self refreshView];
		}
	};
	[[self.delegates sessionDelegate].session deleteMessageForSite:self.site messageId:msg.messageId completion:whenDeleted];		
}

#pragma mark - Table view delegate

// match the MessagesCellView.xib
#define FONT systemFontOfSize
#define FONT_SIZE 14
#define HEIGHT 50
#define WIDTH 274

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIFont *font = [UIFont FONT:FONT_SIZE];
	
	ETMessage *msg = [self.messages objectAtIndex:indexPath.row];
	
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
	ETMessage *msg = [self.messages objectAtIndex:indexPath.row];
	
	// go there
	MessageViewController *mvc = [[MessageViewController alloc] initWithMessage:msg
																	   fromList:self.messages
																		   site:self.site
																	  delegates:self.delegates
																	   onDelete:onDelete];
	[self.navigationController pushViewController:mvc animated:YES];
	[mvc release];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.messages count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MessagesCellView *cell = [self cellAtIndex:indexPath.row];
	return cell;
}

// reply to a delete from the table
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// the announcement to delete if confirmed
	self.msgToDelete = [self.messages objectAtIndex:indexPath.row];
	
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this message?" 
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

#pragma mark - Actions

// compose a new message
- (IBAction)compose:(id)sender
{
	// on send - the body is plain text
	completion_block_SendMessageViewController completion = ^(NSArray *to, NSString *replyToMessageId, NSString *subject, NSString *body)
	{
		// NSLog(@"sending PM: to:%@ subject:%@ body:%@", to, subject, body);
		completion_block_s whenSent = ^(enum resultStatus status)
		{
			// NSLog(@"PM send complete: status:%d", status);
		};

		[[self.delegates sessionDelegate].session sendPrivateMessageTo:to site:self.site subject:subject body:body completion:whenSent plainText:YES];		
	};

	// create the send message view controller
	SendMessageViewController *smvc = [[SendMessageViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion];

	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:smvc animated:NO];
	[smvc release];
	
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
