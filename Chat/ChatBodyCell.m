/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Chat/ChatBodyCell.m $
 * $Id: ChatBodyCell.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "ChatBodyCell.h"
#import "DateFormat.h"

@interface ChatBodyCell()

@property (nonatomic, retain) IBOutlet UILabel *bodyLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *deleteIcon;
@property (nonatomic, assign) CGRect nibFrame;
@property (nonatomic, assign) CGRect nibBodyLabelFrame;
@property (nonatomic, assign) id deleteTarget;
@property (nonatomic, assign) SEL deleteSelector;

@end

@implementation ChatBodyCell

@synthesize bodyLabel, authorLabel, dateLabel, deleteIcon, nibFrame, nibBodyLabelFrame, message, deleteTarget, deleteSelector;

+ (ChatBodyCell *) chatBodyCellInTable:(UITableView *)table
{
	static NSString *ChatBodyCellId = @"ChatBodyCell";

	ChatBodyCell *cell = [table dequeueReusableCellWithIdentifier:ChatBodyCellId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.bodyLabel.frame = cell.nibBodyLabelFrame;
		cell.bodyLabel.numberOfLines = 1;
		cell.frame = cell.nibFrame;
		cell.deleteIcon.hidden = YES;

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:ChatBodyCellId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[ChatBodyCell class]])
		{
			cell = (ChatBodyCell *) obj;

			// record nib conditions
			cell.nibBodyLabelFrame = cell.bodyLabel.frame;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[bodyLabel release];
	[authorLabel release];
	[dateLabel release];
	[deleteIcon release];
	[message release];

    [super dealloc];
}

- (void) setBody:(NSString *)body
{
	// how many lines will the title render in?
	CGSize theSize = [body sizeWithFont:self.bodyLabel.font constrainedToSize:CGSizeMake(self.bodyLabel.bounds.size.width, FLT_MAX)
						   lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.bodyLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.bodyLabel setFrame:CGRectMake(self.bodyLabel.frame.origin.x, self.bodyLabel.frame.origin.y, self.bodyLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.bodyLabel.numberOfLines = lines;
		
		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.bodyLabel.font.lineHeight * (lines-1)))];
	}

	self.bodyLabel.text = body;
}

// set the author
- (void) setAuthor:(NSString *)author color:(UIColor *)color
{
	self.authorLabel.text = author;
	self.authorLabel.textColor = color;
}

// set the date
- (void) setDate:(NSDate *)date
{
	self.dateLabel.text = [date stringInAdaptiveShortFormat];
}

// set the action for and enable delete
- (void) setDeleteTouchTarget:(id)target action:(SEL)action
{
	if (target != nil)
	{
		self.deleteIcon.hidden = NO;
		self.deleteTarget = target;
		self.deleteSelector = action;

		UIGestureRecognizer *replyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteMessage:)];
		[self.deleteIcon addGestureRecognizer:replyTap];
		[replyTap release];
	}
}

// delete the post (confirm)
- (IBAction) deleteMessage:(UIGestureRecognizer *)sender
{
	[self.deleteTarget performSelector:self.deleteSelector withObject:self.message];
}

@end
