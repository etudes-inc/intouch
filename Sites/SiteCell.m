/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Sites/SiteCell.m $
 * $Id: SiteCell.m 2651 2012-02-14 00:31:22Z ggolden $
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

#import "SiteCell.h"
#import "EtudesColors.h"

@interface SiteCell()

@property (nonatomic, retain) IBOutlet UILabel *siteTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *numOnlineLabel;
@property (nonatomic, retain) IBOutlet UIImageView *onLineIcon;
@property (nonatomic, retain) IBOutlet UILabel *numMissedLabel;
@property (nonatomic, retain) IBOutlet UIImageView *missedIcon;
@property (nonatomic, retain) IBOutlet UILabel *numMessagesLabel;
@property (nonatomic, retain) IBOutlet UIImageView *messagesIcon;
@property (nonatomic, retain) IBOutlet UILabel *numPostsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *postsIcon;
@property (nonatomic, assign) CGRect nibFrame;

@end

@implementation SiteCell

@synthesize siteTitleLabel, numOnlineLabel, onLineIcon, numMissedLabel, missedIcon, numMessagesLabel, messagesIcon, numPostsLabel, postsIcon, nibFrame;

+ (SiteCell *) siteCellInTable:(UITableView *)table
{
	static NSString *TopicCellViewId = @"TopicCellView";
	
	SiteCell *cell = [table dequeueReusableCellWithIdentifier:TopicCellViewId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.numMissedLabel.hidden = NO;
		cell.missedIcon.hidden = NO;
		cell.numOnlineLabel.textColor = [UIColor blackColor];
		cell.numMissedLabel.textColor = [UIColor blackColor];
		cell.numMessagesLabel.textColor = [UIColor blackColor];
		cell.numPostsLabel.textColor = [UIColor blackColor];
		cell.frame = cell.nibFrame;
		
		return cell;	
	}
	
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed: @"SiteCell" owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[SiteCell class]])
		{
			cell = (SiteCell *) obj;
			
			// record nib conditions
			cell.nibFrame = cell.frame;

			break;
		}
	}
	
	return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
	[siteTitleLabel release];
	[numOnlineLabel release];
	[onLineIcon release];
	[numMissedLabel release];
	[missedIcon release];
	[numMessagesLabel release];
	[messagesIcon release];

    [super dealloc];
}

- (void) setSiteTitle:(NSString *)title
{
	self.siteTitleLabel.text = title;
}

// the number of users online now
- (void) setNumOnlineUsers:(int)count
{
	if (count == 0)
	{
		self.numOnlineLabel.text = @"No users are online.";
	}
	else if (count == 1)
	{
		self.numOnlineLabel.text = @"1 user is online.";
		self.numOnlineLabel.textColor = [UIColor colorEtudesAlert];
	}
	else
	{
		self.numOnlineLabel.text = [NSString stringWithFormat:@"%d users are online.", count];
		self.numOnlineLabel.textColor = [UIColor colorEtudesAlert];
	}
}

// the number of users not visited in the last period
- (void) setNumAlertUsers:(int) count
{
	if (count == 0)
	{
		// for 0, hide the fields
		self.numMissedLabel.hidden = YES;
		self.missedIcon.hidden = YES;
		
		// reduce our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height - self.numMissedLabel.frame.size.height)];
	}
	else if (count == 1)
	{
		self.numMissedLabel.text = @"1 student has not recently visited.";
		self.numMissedLabel.textColor = [UIColor colorEtudesAlert];
	}
	else
	{
		self.numMissedLabel.text = [NSString stringWithFormat:@"%d students have not recently visited.", count];
		self.numMissedLabel.textColor = [UIColor colorEtudesAlert];
	}
}

// number of unread messages
- (void) setNumUnreadMessages:(int) count
{
	if (count == 0)
	{
		self.numMessagesLabel.text = @"No new private messages.";
	}
	else if (count == 1)
	{
		self.numMessagesLabel.text = @"1 new private message.";
		self.numMessagesLabel.textColor = [UIColor colorEtudesAlert];
	}
	else
	{
		self.numMessagesLabel.text = [NSString stringWithFormat:@"%d new private messages.", count];
		self.numMessagesLabel.textColor = [UIColor colorEtudesAlert];
	}
}

// if there are unread posts
- (void) setUnreadPosts:(BOOL)unread
{
	if (unread)
	{
		self.numPostsLabel.text = @"There are new posts.";
		self.numPostsLabel.textColor = [UIColor colorEtudesAlert];
	}
	else
	{
		self.numPostsLabel.text = @"No new posts.";
	}
}

@end
