/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/ForumCellView.m $
 * $Id: ForumCellView.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "ForumCellView.h"
#import "DateFormat.h"

@interface ForumCellView()

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *description;
@property (nonatomic, retain) IBOutlet UILabel *dates;
@property (nonatomic, retain) IBOutlet BadgeView *topics;
@property (nonatomic, retain) IBOutlet UIImageView *unread;
@property (nonatomic, retain) IBOutlet UIImageView *present;
@property (nonatomic, retain) IBOutlet UIImageView *publishedHiddenIcon;
@property (nonatomic, retain) IBOutlet UIImageView *unpublishedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *blockedIcon;
@property (nonatomic, retain) IBOutlet IBOutlet UIImageView *replyOnlyIcon;
@property (nonatomic, retain) IBOutlet IBOutlet UIImageView *readOnlyIcon;
@property (nonatomic, assign) CGRect nibFrame;
@property (nonatomic, assign) CGRect nibTitleFrame;
@property (nonatomic, assign) CGRect nibDescriptionFrame;
@property (nonatomic, assign) CGRect nibDatesFrame;
@property (nonatomic, assign) CGRect nibPublishedHiddenIconFrame;
@property (nonatomic, assign) CGRect nibUnpublishedIconFrame;
@property (nonatomic, assign) CGRect nibReplyOnlyIconFrame;
@property (nonatomic, assign) CGRect nibReadOnlyIconFrame;

@end

@implementation ForumCellView

@synthesize title, description, dates, topics, unread, present, publishedHiddenIcon, unpublishedIcon, blockedIcon, replyOnlyIcon, readOnlyIcon;
@synthesize nibFrame, nibTitleFrame, nibDescriptionFrame, nibDatesFrame;
@synthesize nibPublishedHiddenIconFrame, nibUnpublishedIconFrame, nibReplyOnlyIconFrame, nibReadOnlyIconFrame;

+ (ForumCellView *)forumCellViewInTable:(UITableView *)table
{
	static NSString *ForumCellViewId = @"ForumCellView";

	ForumCellView *cell = [table dequeueReusableCellWithIdentifier:ForumCellViewId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.frame = cell.nibFrame;
		cell.title.frame = cell.nibTitleFrame;
		cell.title.numberOfLines = 1;
		cell.description.frame = cell.nibDescriptionFrame;
		cell.description.numberOfLines = 1;
		cell.description.hidden = NO;
		cell.dates.frame = cell.nibDatesFrame;
		cell.dates.hidden = NO;
		cell.topics.hidden = YES;
		cell.unread.hidden = YES;
		cell.present.hidden = YES;
		cell.publishedHiddenIcon.frame = cell.nibPublishedHiddenIconFrame;
		cell.publishedHiddenIcon.hidden = YES;
		cell.unpublishedIcon.frame = cell.nibUnpublishedIconFrame;
		cell.unpublishedIcon.hidden = YES;
		cell.blockedIcon.hidden = YES;
		cell.replyOnlyIcon.frame = cell.nibReplyOnlyIconFrame;
		cell.replyOnlyIcon.hidden = YES;
		cell.readOnlyIcon.frame = cell.nibReadOnlyIconFrame;
		cell.readOnlyIcon.hidden = YES;
		[cell.topics setFrame:CGRectMake(cell.topics.frame.origin.x, (cell.frame.size.height / 2) - (cell.topics.frame.size.height / 2),
										 cell.topics.frame.size.width, cell.topics.frame.size.height)];
		[cell.unread setFrame:CGRectMake(cell.unread.frame.origin.x, (cell.frame.size.height / 2) - (cell.unread.frame.size.height / 2),
										 cell.unread.frame.size.width, cell.unread.frame.size.height)];
		[cell.present setFrame:CGRectMake(cell.present.frame.origin.x, (cell.frame.size.height / 2) - (cell.present.frame.size.height / 2),
										  cell.present.frame.size.width, cell.present.frame.size.height)];
		[cell.blockedIcon setFrame:CGRectMake(cell.blockedIcon.frame.origin.x, (cell.frame.size.height / 2) - (cell.blockedIcon.frame.size.height / 2),
											  cell.blockedIcon.frame.size.width, cell.blockedIcon.frame.size.height)];

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:ForumCellViewId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[ForumCellView class]])
		{
			cell = (ForumCellView *) obj;

			// record nib conditions
			cell.nibFrame = cell.frame;
			cell.nibTitleFrame = cell.title.frame;
			cell.nibDescriptionFrame = cell.description.frame;
			cell.nibDatesFrame = cell.dates.frame;
			cell.nibPublishedHiddenIconFrame = cell.publishedHiddenIcon.frame;
			cell.nibUnpublishedIconFrame = cell.unpublishedIcon.frame;
			cell.nibReplyOnlyIconFrame = cell.replyOnlyIcon.frame;
			cell.nibReadOnlyIconFrame = cell.readOnlyIcon.frame;

			break;
		}
	}

	// our accessory type
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
	[title release];
	[description release];
	[dates release];
	[topics release];
	[unread release];
	[present release];
	[publishedHiddenIcon release];
	[unpublishedIcon release];
	[blockedIcon release];
	[replyOnlyIcon release];
	[readOnlyIcon release];

    [super dealloc];
}

- (BOOL) noIconsShowing
{
	return (self.publishedHiddenIcon.hidden && self.unpublishedIcon.hidden && self.readOnlyIcon.hidden && self.replyOnlyIcon.hidden);
}

// set the title
- (void) setForumTitle:(NSString *)theTitle
{
	self.title.text = theTitle;

	// how many lines will the title render in?
	CGSize theSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:CGSizeMake(self.title.bounds.size.width, FLT_MAX)
									 lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.title.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.title setFrame:CGRectMake(self.title.frame.origin.x, self.title.frame.origin.y, self.title.frame.size.width, theSize.height)];

		// set the number of lines
		self.title.numberOfLines = lines;
		
		// move the description and dates ... down to make room
		[self.description setFrame:CGRectMake(self.description.frame.origin.x, self.description.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
											  self.description.frame.size.width, self.description.frame.size.height)];
		[self.dates setFrame:CGRectMake(self.dates.frame.origin.x, self.dates.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
										self.dates.frame.size.width, self.dates.frame.size.height)];
		[self.publishedHiddenIcon setFrame:CGRectMake(self.publishedHiddenIcon.frame.origin.x,
													  self.publishedHiddenIcon.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
													  self.publishedHiddenIcon.frame.size.width, self.publishedHiddenIcon.frame.size.height)];
		[self.unpublishedIcon setFrame:CGRectMake(self.unpublishedIcon.frame.origin.x,
													  self.unpublishedIcon.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
													  self.unpublishedIcon.frame.size.width, self.unpublishedIcon.frame.size.height)];
		[self.readOnlyIcon setFrame:CGRectMake(self.readOnlyIcon.frame.origin.x,
												  self.readOnlyIcon.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
												  self.readOnlyIcon.frame.size.width, self.readOnlyIcon.frame.size.height)];
		[self.replyOnlyIcon setFrame:CGRectMake(self.replyOnlyIcon.frame.origin.x,
												  self.replyOnlyIcon.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
												  self.replyOnlyIcon.frame.size.width, self.replyOnlyIcon.frame.size.height)];
		
		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.title.font.lineHeight * (lines-1)))];

		// re-center the topics and unread
		[self.topics setFrame:CGRectMake(self.topics.frame.origin.x, (self.frame.size.height / 2) - (self.topics.frame.size.height / 2),
										self.topics.frame.size.width, self.topics.frame.size.height)];
		[self.unread setFrame:CGRectMake(self.unread.frame.origin.x, (self.frame.size.height / 2) - (self.unread.frame.size.height / 2),
										 self.unread.frame.size.width, self.unread.frame.size.height)];
		[self.present setFrame:CGRectMake(self.present.frame.origin.x, (self.frame.size.height / 2) - (self.present.frame.size.height / 2),
										 self.present.frame.size.width, self.present.frame.size.height)];
		[self.blockedIcon setFrame:CGRectMake(self.blockedIcon.frame.origin.x, (self.frame.size.height / 2) - (self.blockedIcon.frame.size.height / 2),
										 self.blockedIcon.frame.size.width, self.blockedIcon.frame.size.height)];
	}
}

// set the description
- (void) setForumDescription:(NSString *)theDescription
{
	if (theDescription != nil)
	{
		// how many lines will the description render in?
		CGSize theSize = [theDescription sizeWithFont:self.description.font constrainedToSize:CGSizeMake(self.description.frame.size.width, FLT_MAX)
										lineBreakMode:NSLineBreakByWordWrapping];
		int lines = theSize.height / self.description.font.lineHeight;
		
		// the layout is set for one line - adjust if needed
		if (lines > 1)
		{
			// make the frame larger
			[self.description setFrame:CGRectMake(self.description.frame.origin.x, self.description.frame.origin.y,
												  self.description.frame.size.width, theSize.height)];
			
			// set the number of lines
			self.description.numberOfLines = lines;
			
			// move the dates ... down to make room
			[self.dates setFrame:CGRectMake(self.dates.frame.origin.x, self.dates.frame.origin.y + (self.description.font.lineHeight * (lines-1)),
											self.dates.frame.size.width, self.dates.frame.size.height)];
			[self.publishedHiddenIcon setFrame:CGRectMake(self.publishedHiddenIcon.frame.origin.x,
														  self.publishedHiddenIcon.frame.origin.y + (self.description.font.lineHeight * (lines-1)),
														  self.publishedHiddenIcon.frame.size.width, self.publishedHiddenIcon.frame.size.height)];
			[self.unpublishedIcon setFrame:CGRectMake(self.unpublishedIcon.frame.origin.x,
														  self.unpublishedIcon.frame.origin.y + (self.description.font.lineHeight * (lines-1)),
														  self.unpublishedIcon.frame.size.width, self.unpublishedIcon.frame.size.height)];
			[self.readOnlyIcon setFrame:CGRectMake(self.readOnlyIcon.frame.origin.x,
												   self.readOnlyIcon.frame.origin.y + (self.description.font.lineHeight * (lines-1)),
												   self.readOnlyIcon.frame.size.width, self.readOnlyIcon.frame.size.height)];
			[self.replyOnlyIcon setFrame:CGRectMake(self.replyOnlyIcon.frame.origin.x,
													self.replyOnlyIcon.frame.origin.y + (self.description.font.lineHeight * (lines-1)),
													self.replyOnlyIcon.frame.size.width, self.replyOnlyIcon.frame.size.height)];
			
			// increase our frame
			[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
									  self.frame.size.width, self.frame.size.height + (self.description.font.lineHeight * (lines-1)))];
			
			// re-center the topics and unread
			[self.topics setFrame:CGRectMake(self.topics.frame.origin.x, (self.frame.size.height / 2) - (self.topics.frame.size.height / 2),
											 self.topics.frame.size.width, self.topics.frame.size.height)];
			[self.unread setFrame:CGRectMake(self.unread.frame.origin.x, (self.frame.size.height / 2) - (self.unread.frame.size.height / 2),
											 self.unread.frame.size.width, self.unread.frame.size.height)];
			[self.present setFrame:CGRectMake(self.present.frame.origin.x, (self.frame.size.height / 2) - (self.present.frame.size.height / 2),
											 self.present.frame.size.width, self.present.frame.size.height)];
			[self.blockedIcon setFrame:CGRectMake(self.blockedIcon.frame.origin.x, (self.frame.size.height / 2) - (self.blockedIcon.frame.size.height / 2),
												  self.blockedIcon.frame.size.width, self.blockedIcon.frame.size.height)];
		}
		
		self.description.text = theDescription;
	}

	else
	{
		// hide description
		self.description.hidden = YES;
		
		// reduce frame size if we have no dates and no icons
		if (self.dates.hidden && [self noIconsShowing])
		{
			// decrease our frame
			[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
									  self.frame.size.width, self.frame.size.height - self.description.frame.size.height)];
			
			// re-center the topics and unread
			[self.topics setFrame:CGRectMake(self.topics.frame.origin.x, (self.frame.size.height / 2) - (self.topics.frame.size.height / 2),
											 self.topics.frame.size.width, self.topics.frame.size.height)];
			[self.unread setFrame:CGRectMake(self.unread.frame.origin.x, (self.frame.size.height / 2) - (self.unread.frame.size.height / 2),
											 self.unread.frame.size.width, self.unread.frame.size.height)];
			[self.present setFrame:CGRectMake(self.present.frame.origin.x, (self.frame.size.height / 2) - (self.present.frame.size.height / 2),
											  self.present.frame.size.width, self.present.frame.size.height)];
			[self.blockedIcon setFrame:CGRectMake(self.blockedIcon.frame.origin.x, (self.frame.size.height / 2) - (self.blockedIcon.frame.size.height / 2),
												  self.blockedIcon.frame.size.width, self.blockedIcon.frame.size.height)];
		}
	}
}

// set the dates - make sure to set with nil if the dates are nil
- (void) setForumDatesWithOpen:(NSDate *)openDate due:(NSDate *)dueDate
{
	if ((openDate != nil) && (dueDate != nil))
	{
		self.dates.text = [NSString stringWithFormat:@"%@ - %@", [openDate stringInEtudesFormat], [dueDate stringInEtudesFormat]];
	}
	else if (openDate != nil)
	{
		self.dates.text = [NSString stringWithFormat:@"Open %@", [openDate stringInEtudesFormat]];
	}
	else if (dueDate != nil)
	{
		self.dates.text = [NSString stringWithFormat:@"Due %@", [dueDate stringInEtudesFormat]];
	}
	else
	{
		// hide it
		self.dates.hidden = YES;
		
		// if we have no icon, decrease our frame
		if ([self noIconsShowing])
		{
			[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
									  self.frame.size.width, self.frame.size.height - self.dates.frame.size.height)];
			
			// re-center the topics and unread
			[self.topics setFrame:CGRectMake(self.topics.frame.origin.x, (self.frame.size.height / 2) - (self.topics.frame.size.height / 2),
											 self.topics.frame.size.width, self.topics.frame.size.height)];
			[self.unread setFrame:CGRectMake(self.unread.frame.origin.x, (self.frame.size.height / 2) - (self.unread.frame.size.height / 2),
											 self.unread.frame.size.width, self.unread.frame.size.height)];
			[self.present setFrame:CGRectMake(self.present.frame.origin.x, (self.frame.size.height / 2) - (self.present.frame.size.height / 2),
											  self.present.frame.size.width, self.present.frame.size.height)];
			[self.blockedIcon setFrame:CGRectMake(self.blockedIcon.frame.origin.x, (self.frame.size.height / 2) - (self.blockedIcon.frame.size.height / 2),
												  self.blockedIcon.frame.size.width, self.blockedIcon.frame.size.height)];
		}
	}
}

// set and reveal the num topics badge
- (void) setNumTopics:(int)numTopics
{
	self.topics.hidden = NO;
	NSString * txt = [NSString stringWithFormat:@"%i", numTopics];
	self.topics.text = txt;
}

// set unread
- (void) setUnreadIndicator:(BOOL)theUnRead
{
	self.unread.hidden = !theUnRead;
}

// set present
- (void) setPresentIndicator:(BOOL)thePresent
{
	self.present.hidden = !thePresent;
}

// set the published-hidden, unpublished, read-only and reply-only icons
- (void) setIconsUnPublished:(BOOL)unPublished pubHidden:(BOOL)pubHidden readOnly:(BOOL)readOnly replyOnly:(BOOL)replyOnly
{
	UIImageView *selectedImage = nil;
	if (unPublished)
	{
		selectedImage = self.unpublishedIcon;
	}
	else if (pubHidden)
	{
		selectedImage = self.publishedHiddenIcon;
	}
	else if (readOnly)
	{
		selectedImage = self.readOnlyIcon;
	}
	else if (replyOnly)
	{
		selectedImage = self.replyOnlyIcon;
	}
	
	if (selectedImage != nil)
	{
		selectedImage.hidden = NO;

		// shift the dates over
		[self.dates setFrame:CGRectMake((self.dates.frame.origin.x + self.publishedHiddenIcon.frame.size.width - 4),
										self.dates.frame.origin.y, self.dates.frame.size.width, self.dates.frame.size.height)];		
	}
}

// set blocked
- (void) setBlocked:(BOOL)blocked
{
	if (!blocked) return;
	
	self.blockedIcon.hidden = NO;

	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
