/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Messages/MessagesCellView.m $
 * $Id: MessagesCellView.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "MessagesCellView.h"
#import "DateFormat.h"

@interface MessagesCellView()

@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *fromLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unreadImage;
@property (nonatomic, retain) IBOutlet UIImageView *repliedImage;
@property (nonatomic, assign) CGRect nibSubjectLabelFrame;
@property (nonatomic, assign) CGRect nibFrame;
@property (nonatomic, assign) CGRect nibDateLabelFrame;
@property (nonatomic, assign) CGRect nibFromLabelFrame;

@end

@implementation MessagesCellView

@synthesize subjectLabel, dateLabel, fromLabel, unreadImage, repliedImage;
@synthesize nibSubjectLabelFrame, nibFrame, nibDateLabelFrame, nibFromLabelFrame;

+ (MessagesCellView *) messagesCellViewInTable:(UITableView *)table
{
	MessagesCellView *cell = [table dequeueReusableCellWithIdentifier:@"MessagesCellView"];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.unreadImage.hidden = YES;
		cell.repliedImage.hidden = YES;
		cell.subjectLabel.frame = cell.nibSubjectLabelFrame;
		cell.dateLabel.frame = cell.nibDateLabelFrame;
		cell.fromLabel.frame = cell.nibFromLabelFrame;
		cell.fromLabel.hidden = NO;
		cell.subjectLabel.numberOfLines = 1;
		cell.subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;

		cell.frame = cell.nibFrame;
		[cell.unreadImage setFrame:CGRectMake(cell.unreadImage.frame.origin.x, (cell.frame.size.height / 2) - (cell.unreadImage.frame.size.height / 2),
											  cell.unreadImage.frame.size.width, cell.unreadImage.frame.size.height)];
		[cell.repliedImage setFrame:CGRectMake(cell.repliedImage.frame.origin.x, (cell.frame.size.height / 2) - (cell.repliedImage.frame.size.height / 2),
											  cell.repliedImage.frame.size.width, cell.repliedImage.frame.size.height)];

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed: @"MessagesCellView" owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[MessagesCellView class]])
		{
			cell = (MessagesCellView *) obj;

			// record nib conditions
			cell.nibSubjectLabelFrame = cell.subjectLabel.frame;
			cell.nibDateLabelFrame = cell.dateLabel.frame;
			cell.nibFromLabelFrame = cell.fromLabel.frame;
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
	[subjectLabel release];
	[dateLabel release];
	[fromLabel release];
	[unreadImage release];
	[repliedImage release];

	[super dealloc];
}

- (void) setSubject:(NSString *)subject
{	
	// how many lines will the subject render in?
	CGSize theSize = [subject sizeWithFont:self.subjectLabel.font constrainedToSize:CGSizeMake(self.subjectLabel.bounds.size.width, FLT_MAX)
							 lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.subjectLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.subjectLabel setFrame:CGRectMake(self.subjectLabel.frame.origin.x, self.subjectLabel.frame.origin.y,
											   self.subjectLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.subjectLabel.numberOfLines = lines;
		
		// move the date and from down to make room
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x, self.dateLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
		
		
		[self.fromLabel setFrame:CGRectMake(self.fromLabel.frame.origin.x, self.fromLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											 self.fromLabel.frame.size.width, self.fromLabel.frame.size.height)];
		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.subjectLabel.font.lineHeight * (lines-1)))];
		
		// re-center the unread & replied
		[self.unreadImage setFrame:CGRectMake(self.unreadImage.frame.origin.x, (self.frame.size.height / 2) - (self.unreadImage.frame.size.height / 2),
											  self.unreadImage.frame.size.width, self.unreadImage.frame.size.height)];
		[self.repliedImage setFrame:CGRectMake(self.repliedImage.frame.origin.x, (self.frame.size.height / 2) - (self.repliedImage.frame.size.height / 2),
											   self.repliedImage.frame.size.width, self.repliedImage.frame.size.height)];
	}
	
	self.subjectLabel.text = subject;
}

- (void) setFrom:(NSString *)from
{
	self.fromLabel.text = from;
}

- (void) setDate:(NSDate *)date
{
	self.dateLabel.text = [date stringInAdaptiveShortFormat];
}

- (void) setPreviewText:(NSString *)text
{
	
}

- (void) setUnread:(BOOL)unread replied:(BOOL)replied
{
	if (unread)
	{
		self.unreadImage.hidden = NO;
	}
	else
	{
		if (replied)
		{
			self.repliedImage.hidden = NO;
		}
	}
}

#define DELETE_WIDTH 54

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	if (editing)
	{
		if (!self.fromLabel.hidden)
		{
			self.fromLabel.hidden = YES;
			[self.subjectLabel setFrame:CGRectMake(self.subjectLabel.frame.origin.x, self.subjectLabel.frame.origin.y,
												   self.subjectLabel.frame.size.width - DELETE_WIDTH, self.subjectLabel.frame.size.height)];
			self.subjectLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		}
	}
	else if (self.fromLabel.hidden)
	{
		self.fromLabel.hidden = NO;
		[self.subjectLabel setFrame:CGRectMake(self.subjectLabel.frame.origin.x, self.subjectLabel.frame.origin.y,
											   self.subjectLabel.frame.size.width + DELETE_WIDTH, self.subjectLabel.frame.size.height)];
		self.subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;
	}

	[super setEditing:editing animated:animated];
}

@end
