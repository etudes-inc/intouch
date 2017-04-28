/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/TopicCellView.m $
 * $Id: TopicCellView.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "TopicCellView.h"
#import "DateFormat.h"

@interface TopicCellView()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorLabel;
@property (nonatomic, retain) IBOutlet UILabel *datesLabel;
@property (nonatomic, retain) IBOutlet BadgeView *postsBadge;
@property (nonatomic, retain) IBOutlet UIImageView *unreadIcon;
@property (nonatomic, retain) IBOutlet UIImageView *stickyIcon;
@property (nonatomic, retain) IBOutlet UIImageView *announceIcon;
@property (nonatomic, retain) IBOutlet UIImageView *reuseIcon;
@property (nonatomic, retain) IBOutlet UIImageView *readOnlyIcon;
@property (nonatomic, retain) IBOutlet UIImageView *publishedHiddenIcon;
@property (nonatomic, retain) IBOutlet UIImageView *unpublishedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *blockedIcon;
@property (nonatomic, assign) CGRect nibTitleLabelFrame;
@property (nonatomic, assign) CGRect nibAuthorLabelFrame;
@property (nonatomic, assign) CGRect nibDatesLabelFrame;
@property (nonatomic, assign) CGRect nibStickyIconFrame;
@property (nonatomic, assign) CGRect nibAnnounceIconFrame;
@property (nonatomic, assign) CGRect nibReuseIconFrame;
@property (nonatomic, assign) CGRect nibReadOnlyIconFrame;
@property (nonatomic, assign) CGRect nibPublishedHiddenIconFrame;
@property (nonatomic, assign) CGRect nibUnpublishedIconFrame;
@property (nonatomic, assign) CGRect nibFrame;

@end

@implementation TopicCellView

@synthesize titleLabel, authorLabel, datesLabel, postsBadge, unreadIcon, stickyIcon, announceIcon;
@synthesize reuseIcon, readOnlyIcon, publishedHiddenIcon, unpublishedIcon, blockedIcon;
@synthesize nibTitleLabelFrame, nibAuthorLabelFrame, nibDatesLabelFrame, nibStickyIconFrame, nibAnnounceIconFrame;
@synthesize nibReuseIconFrame, nibReadOnlyIconFrame, nibPublishedHiddenIconFrame, nibUnpublishedIconFrame, nibFrame;

+ (TopicCellView *) topicCellViewInTable:(UITableView *)table
{
	static NSString *TopicCellViewId = @"TopicCellView";

	TopicCellView *cell = [table dequeueReusableCellWithIdentifier:TopicCellViewId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.frame = cell.nibFrame;
		cell.titleLabel.frame = cell.nibTitleLabelFrame;
		cell.titleLabel.numberOfLines = 1;
		cell.authorLabel.frame = cell.nibAuthorLabelFrame;
		cell.datesLabel.frame = cell.nibDatesLabelFrame;
		cell.stickyIcon.frame = cell.nibStickyIconFrame;
		cell.stickyIcon.hidden = YES;
		cell.announceIcon.frame = cell.nibAnnounceIconFrame;
		cell.announceIcon.hidden = YES;
		cell.reuseIcon.frame = cell.nibReuseIconFrame;
		cell.reuseIcon.hidden = YES;
		cell.readOnlyIcon.frame = cell.nibReadOnlyIconFrame;
		cell.readOnlyIcon.hidden = YES;
		cell.publishedHiddenIcon.frame = cell.nibPublishedHiddenIconFrame;
		cell.publishedHiddenIcon.hidden = YES;
		cell.unpublishedIcon.frame = cell.nibUnpublishedIconFrame;
		cell.unpublishedIcon.hidden = YES;
		cell.unreadIcon.hidden = YES;
		cell.blockedIcon.hidden = YES;
		[cell.postsBadge setFrame:CGRectMake(cell.postsBadge.frame.origin.x, (cell.frame.size.height / 2) - (cell.postsBadge.frame.size.height / 2),
											 cell.postsBadge.frame.size.width, cell.postsBadge.frame.size.height)];
		[cell.unreadIcon setFrame:CGRectMake(cell.unreadIcon.frame.origin.x, (cell.frame.size.height / 2) - (cell.unreadIcon.frame.size.height / 2),
											 cell.unreadIcon.frame.size.width, cell.unreadIcon.frame.size.height)];
		[cell.blockedIcon setFrame:CGRectMake(cell.blockedIcon.frame.origin.x, (cell.frame.size.height / 2) - (cell.blockedIcon.frame.size.height / 2),
											  cell.blockedIcon.frame.size.width, cell.blockedIcon.frame.size.height)];

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:TopicCellViewId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[TopicCellView class]])
		{
			cell = (TopicCellView *) obj;
			// record nib conditions
			cell.nibFrame = cell.frame;
			cell.nibTitleLabelFrame = cell.titleLabel.frame;
			cell.nibAuthorLabelFrame = cell.authorLabel.frame;
			cell.nibDatesLabelFrame = cell.datesLabel.frame;
			cell.nibStickyIconFrame = cell.stickyIcon.frame;
			cell.nibAnnounceIconFrame = cell.announceIcon.frame;
			cell.nibReuseIconFrame = cell.reuseIcon.frame;
			cell.nibReadOnlyIconFrame = cell.readOnlyIcon.frame;
			cell.nibPublishedHiddenIconFrame = cell.publishedHiddenIcon.frame;
			cell.nibUnpublishedIconFrame = cell.unpublishedIcon.frame;

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
	[titleLabel release];
	[authorLabel release];
	[datesLabel release];
	[postsBadge release];
	[unreadIcon release];
	[stickyIcon release];
	[announceIcon release];
	[reuseIcon release];
	[readOnlyIcon release];
	[publishedHiddenIcon release];
	[unpublishedIcon release];
	[blockedIcon release];

	[super dealloc];
}

// set the title
- (void) setTitle:(NSString *)title
{
	self.titleLabel.text = title;
	
	// how many lines will the title render in?
	CGSize theSize = [title sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.bounds.size.width, FLT_MAX)
						   lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.titleLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.titleLabel.numberOfLines = lines;
		
		// move the author, dates, icons down to make room
		[self.authorLabel setFrame:CGRectMake(self.authorLabel.frame.origin.x, self.authorLabel.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.authorLabel.frame.size.width, self.authorLabel.frame.size.height)];
		[self.datesLabel setFrame:CGRectMake(self.datesLabel.frame.origin.x, self.datesLabel.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											 self.datesLabel.frame.size.width, self.datesLabel.frame.size.height)];
		[self.stickyIcon setFrame:CGRectMake(self.stickyIcon.frame.origin.x, self.stickyIcon.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											 self.stickyIcon.frame.size.width, self.stickyIcon.frame.size.height)];
		[self.announceIcon setFrame:CGRectMake(self.announceIcon.frame.origin.x, self.announceIcon.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											   self.announceIcon.frame.size.width, self.announceIcon.frame.size.height)];
		[self.reuseIcon setFrame:CGRectMake(self.reuseIcon.frame.origin.x, self.reuseIcon.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											self.reuseIcon.frame.size.width, self.reuseIcon.frame.size.height)];
		[self.readOnlyIcon setFrame:CGRectMake(self.readOnlyIcon.frame.origin.x, self.readOnlyIcon.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											   self.readOnlyIcon.frame.size.width, self.readOnlyIcon.frame.size.height)];
		[self.publishedHiddenIcon setFrame:CGRectMake(self.publishedHiddenIcon.frame.origin.x, self.publishedHiddenIcon.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											   self.publishedHiddenIcon.frame.size.width, self.publishedHiddenIcon.frame.size.height)];
		[self.unpublishedIcon setFrame:CGRectMake(self.unpublishedIcon.frame.origin.x, self.unpublishedIcon.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
													  self.unpublishedIcon.frame.size.width, self.unpublishedIcon.frame.size.height)];
		
		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.titleLabel.font.lineHeight * (lines-1)))];
		
		// re-center the posts and unread
		[self.postsBadge setFrame:CGRectMake(self.postsBadge.frame.origin.x, (self.frame.size.height / 2) - (self.postsBadge.frame.size.height / 2),
											 self.postsBadge.frame.size.width, self.postsBadge.frame.size.height)];
		[self.unreadIcon setFrame:CGRectMake(self.unreadIcon.frame.origin.x, (self.frame.size.height / 2) - (self.unreadIcon.frame.size.height / 2),
											 self.unreadIcon.frame.size.width, self.unreadIcon.frame.size.height)];
		[self.blockedIcon setFrame:CGRectMake(self.blockedIcon.frame.origin.x, (self.frame.size.height / 2) - (self.blockedIcon.frame.size.height / 2),
											 self.blockedIcon.frame.size.width, self.blockedIcon.frame.size.height)];
	}
}

// set the author
- (void) setAuthor:(NSString *)author
{
	self.authorLabel.text = author;
}

// set the dates - make sure to set with nil if the dates are nil
- (void) setTopicDatesWithOpen:(NSDate *)openDate due:(NSDate *)dueDate
{
	if ((openDate != nil) && (dueDate != nil))
	{
		self.datesLabel.text = [NSString stringWithFormat:@"%@ - %@", [openDate stringInEtudesFormat], [dueDate stringInEtudesFormat]];
	}
	else if (openDate != nil)
	{
		self.datesLabel.text = [NSString stringWithFormat:@"Open %@", [openDate stringInEtudesFormat]];
	}
	else if (dueDate != nil)
	{
		self.datesLabel.text = [NSString stringWithFormat:@"Due %@", [dueDate stringInEtudesFormat]];
	}
	else
	{
		// hide it
		self.datesLabel.hidden = YES;
		
		// decrease our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height - self.datesLabel.frame.size.height)];
		
		// re-center the posts and unread
		[self.postsBadge setFrame:CGRectMake(self.postsBadge.frame.origin.x, (self.frame.size.height / 2) - (self.postsBadge.frame.size.height / 2),
											 self.postsBadge.frame.size.width, self.postsBadge.frame.size.height)];
		[self.unreadIcon setFrame:CGRectMake(self.unreadIcon.frame.origin.x, (self.frame.size.height / 2) - (self.unreadIcon.frame.size.height / 2),
											 self.unreadIcon.frame.size.width, self.unreadIcon.frame.size.height)];
		[self.blockedIcon setFrame:CGRectMake(self.blockedIcon.frame.origin.x, (self.frame.size.height / 2) - (self.blockedIcon.frame.size.height / 2),
											  self.blockedIcon.frame.size.width, self.blockedIcon.frame.size.height)];
	}
}

// set unread
- (void) setUnreadIndicator:(BOOL)unread
{
	self.unreadIcon.hidden = !unread;
}

// set the number of posts in the topic
- (void) setNumPosts:(int)numPosts
{
	NSString * txt = [NSString stringWithFormat:@"%i", numPosts];
	self.postsBadge.text = txt;
}

// based on the type and readOnly ..., select the proper type icon
- (void) setTopicType:(enum TopicType)type readOnly:(BOOL)readOnly publishedHidden:(BOOL)pubHidden unpublished:(BOOL)unpublished
{
	if (unpublished)
	{
		[self.unpublishedIcon setHidden:NO];
	}
	else if (pubHidden)
	{
		[self.publishedHiddenIcon setHidden:NO];
	}
	else if (readOnly)
	{
		[self.readOnlyIcon setHidden:NO];
	}
	else if (type == announceTopic)
	{
		[self.announceIcon setHidden:NO];
	}
	else if (type == stickyTopic)
	{
		[self.stickyIcon setHidden:NO];
	}
	else if (type == reuseTopic)
	{
		[self.reuseIcon setHidden:NO];
	}
}

- (void) setBlocked:(BOOL)blocked
{
	if (!blocked) return;

	self.blockedIcon.hidden = NO;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
