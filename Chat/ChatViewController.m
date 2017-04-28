/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Chat/ChatViewController.m $
 * $Id: ChatViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "ChatViewController.h"
#import "NavBarTitle.h"
#import	"PostCellView.h"
#import "ChatBodyCell.h"
#import "ChatSendViewController.h"

@interface ChatViewController()

@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UILabel *noneLabel;
@property (nonatomic, retain) NSArray /* <ETMessage> */ *messages;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) ColorMapper *colors;
@property (nonatomic, retain) ETMessage *selectedMessage;

@end

@implementation ChatViewController

@synthesize list, refresh, toolbar, updated, updatedDate, updatedTime,  noneLabel, messages, timer, colors, selectedMessage;

// The designated initializer.  
- (id) initWithSite:(Site *)st delegates:(id <Delegates>)d
{
    self = [super initAsNavWithSite:st delegates:d title:@"Chat"];
    if (self)
	{
		ColorMapper *c = [[ColorMapper alloc] init];
		self.colors = c;
		[c release];
		
		// give our logged in user the first color (matches myEtudes chat behavior)
		[self.colors colorForUser:[self.delegates.sessionDelegate session].internalUserId];
	}

    return self;
}

- (void) dealloc
{
	[list release];
	[refresh release];
	[toolbar release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[noneLabel release];
	[messages release];
	if (timer != nil) [timer invalidate];
	[timer release];
	[colors release];
	[selectedMessage release];

	[super dealloc];
}

- (BOOL) allowDelete:(ETMessage *)msg
{
	// if we want to allow instructors may delete any message (which we do not)
	// if ([self.site instructorPrivileges]) return YES;
	
	// if we want to allow users to delete their own messages (this is true for all Etudes sites)
	if ([msg.fromUserId isEqualToString:[self.delegates.sessionDelegate session].internalUserId]) return YES;
	
	return NO;
}

- (ChatBodyCell *) cellAtIndex:(NSInteger)index
{
	ETMessage *msg = [self.messages objectAtIndex:index];
	
	ChatBodyCell *cell = [ChatBodyCell chatBodyCellInTable:self.list];
	
	[cell setBody:msg.body];
	[cell setAuthor:msg.from color:[self.colors colorForUser:msg.fromUserId]];
	[cell setDate:msg.date];
	if ([self allowDelete:msg])
	{
		[cell setDeleteTouchTarget:self action:@selector(deleteMessage:)];
	}
	cell.message = msg;

	return cell;
}

- (void) loadInfoForced:(BOOL)forced
{
	[super loadInfo];

	// get the posts for the topic
	// the completion block - when the announcements are loaded
	completion_block_sd completion = ^(enum resultStatus status,  NSDictionary *results)
	{
		BOOL brandNew = (self.messages == nil);

		NSArray /* ETMessage */ *msgs = [results objectForKey:@"messages"];
		NSNumber *the_append = [results objectForKey:@"append"];
		BOOL append = [the_append boolValue];

		BOOL newPosts = ([msgs count] > 0);

		// if the last post was visible, we will scroll to the new last post
		BOOL autoScroll = NO;
		NSArray /* NSIndexPath */ *visibleRows = [self.list indexPathsForVisibleRows];
		if (visibleRows != nil)
		{
			NSIndexPath *lastIndex = [visibleRows lastObject];
			if (lastIndex.row == [self.messages count]-1)
			{
				autoScroll = YES;
			}
		}

		// save the messages - append if we already have some and get an append flag set
		if ((self.messages != nil) && append)
		{
			if ([msgs count] > 0)
			{
				NSMutableArray *newMessages = [NSMutableArray arrayWithArray:self.messages];
				[newMessages addObjectsFromArray:msgs];
				self.messages = newMessages;
			}
		}
		else
		{
			self.messages = msgs;
		}

		[self.busy stopAnimating];
		self.refresh.enabled = YES;
		
		NSDate *now = [NSDate date];
		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:now dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;

		// cause the table to refresh
		[self.list reloadData];
		
		// hide / show the "no items" label
		self.noneLabel.hidden = ([self.messages count] != 0);

		// scroll to the bottom
		if (([self.messages count] > 0) && ((newPosts && (autoScroll || brandNew)) || forced))
		{
			NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.messages count] -1 inSection:0];
			[self.list scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}

		// start a timer to refresh again soon (10 seconds)
		self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	};

	// clear the refresh fields
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";

	// stop our refresh timer
	[self.timer invalidate];
	self.timer = nil;

	// load up the chat messages
	[self.busy startAnimating];
	
	// if we have some messages, send in the last one's message id as last seen
	NSString * lastSeenMessageId = nil;
	if (self.messages != nil)
	{
		lastSeenMessageId = ((ETMessage *)[self.messages lastObject]).messageId;
	}

	[[self.delegates sessionDelegate ].session getChatForSite:self.site lastSeenMessageId:lastSeenMessageId completion:completion];	
}

// get the data into the view
- (void) refreshView
{
	[super refreshView];

	// cause the table to refresh
	[self.list reloadData];
	
	// hide / show the "no items" label
	self.noneLabel.hidden = ([self.messages count] != 0);
}

- (void) loadInfo
{
	[self loadInfoForced:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// stop our refresh timer
	[self.timer invalidate];
	self.timer = nil;	

	[super viewWillDisappear:animated];	
}

#pragma mark - Timer

- (void)timeout:(NSTimer*)theTimer
{
	[self loadInfo];
}

#pragma mark - Table view delegate

// match ChatBodyCell.xib
#define FONT systemFontOfSize
#define FONT_SIZE 14
#define HEIGHT 64
#define WIDTH 304

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIFont *font = [UIFont FONT:FONT_SIZE];
	
	ETMessage *msg = [self.messages objectAtIndex:indexPath.row];
	
	CGSize theSize = [msg.body sizeWithFont:font constrainedToSize:CGSizeMake(WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / font.lineHeight;
	CGFloat rv = HEIGHT + (font.lineHeight * (lines-1));
	
//	ChatBodyCell *cbc = [self cellAtIndex:indexPath.row];
//	if (cbc.frame.size.height != rv) NSLog(@"cbc mismatch path: %@   view height: %f   computed height: %f", indexPath, cbc.frame.size.height, rv);

	return rv;
}

#pragma mark - Table view data source

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.messages count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ChatBodyCell *cell = [self cellAtIndex:indexPath.row];
	return cell;
}

#pragma mark - Actions

// process a delete
- (void) processDelete:(ETMessage *)message
{
	// delete from Etudes
	completion_block_sd whenDeleted = ^(enum resultStatus status, NSDictionary *def)
	{
		if (status == success)
		{
			NSMutableArray *newMessages = [NSMutableArray arrayWithArray:self.messages];
			[newMessages removeObject:message];
			self.messages = newMessages;

			// refresh to show the deleted message
			[self refreshView];
		}
	};
	[[self.delegates sessionDelegate].session deleteChatForSite:self.site messageId:message.messageId completion:whenDeleted];		
}

// respond to the chat control
- (IBAction) chat:(id)control
{
	// on send
	completion_block_str completion = ^(NSString *body)
	{
		// NSLog(@"sending chat: body:%@", body);
		completion_block_s whenPosted = ^(enum resultStatus status)
		{
			// NSLog(@"post complete: status:%d", status);
			
			// refresh to show the new post TODO: only if successful?
			[self refresh:nil];
		};
		[[self.delegates sessionDelegate].session sendChatForSite:self.site body:body completion:whenPosted];		
	};

	// on cancel
	completion_block_str cancel = ^(NSString *body)
	{
		// start a timer to refresh again soon (10 seconds)
		self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	};
	
	// stop our refresh timer
	[self.timer invalidate];
	self.timer = nil;

	// create the send message view controller
	ChatSendViewController *csvc = [[ChatSendViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion onCancel:cancel];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:csvc animated:NO];
	[csvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// refresh
- (IBAction) refresh:(id)sender
{
	[self loadInfoForced:YES];
}

// delete the post (confirm)
- (IBAction) deleteMessage:(ETMessage *)msg
{
	// stop our refresh timer
	[self.timer invalidate];
	self.timer = nil;
	
	// setup the post for if the delete is confirmed
	self.selectedMessage = msg;
	
	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this message?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Delete" 
											   otherButtonTitles:nil];
	action.tag = 1;
	[action showFromToolbar:self.toolbar];
	[action release];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// if not our tag=1 sheet, super
	if (actionSheet.tag != 1)
	{
		[super actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
		return;
	}

	// index 0 is confirmation
	if (buttonIndex == 0)
	{
		[self processDelete:self.selectedMessage];
	}
	
	self.selectedMessage = nil;
	
	// start a timer to refresh again soon (10 seconds)
	self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
}

@end
