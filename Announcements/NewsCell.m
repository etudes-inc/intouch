/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/NewsCell.m $
 * $Id: NewsCell.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "NewsCell.h"
#import "DateFormat.h"

@interface NewsCell()

@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unreadImage;
@property (nonatomic, retain) IBOutlet UIImageView *draftImage;
@property (nonatomic, retain) IBOutlet UIImageView *invisibleImage;
@property (nonatomic, assign) CGRect nibSubjectLabelFrame;
@property (nonatomic, assign) CGRect nibDateLabelFrame;
@property (nonatomic, assign) CGRect nibDraftImageFrame;
@property (nonatomic, assign) CGRect nibInvisibleImageFrame;
@property (nonatomic, assign) CGRect nibFrame;
@property (nonatomic, retain) UIColor *nibSubjectLabelTextColor;
@property (nonatomic, retain) UIColor *nibDateLabelTextColor;
@property (nonatomic, assign) BOOL prepedForDelete;

@end

@implementation NewsCell

@synthesize subjectLabel, dateLabel, unreadImage, draftImage, invisibleImage;
@synthesize nibSubjectLabelFrame, nibDateLabelFrame, nibDraftImageFrame, nibInvisibleImageFrame, nibFrame;
@synthesize nibSubjectLabelTextColor, nibDateLabelTextColor, prepedForDelete;

+ (NewsCell *) newsCellInTable:(UITableView *)table
{
	NewsCell *cell = [table dequeueReusableCellWithIdentifier:@"NewsCell"];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.unreadImage.hidden = YES;
		cell.draftImage.hidden = YES;
		cell.invisibleImage.hidden = YES;
		cell.subjectLabel.frame = cell.nibSubjectLabelFrame;
		cell.dateLabel.frame = cell.nibDateLabelFrame;
		cell.draftImage.frame = cell.nibDraftImageFrame;
		cell.invisibleImage.frame = cell.nibInvisibleImageFrame;
		cell.subjectLabel.numberOfLines = 1;
		cell.subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;
		cell.subjectLabel.textColor = cell.nibSubjectLabelTextColor;
		cell.dateLabel.textColor = cell.nibDateLabelTextColor;
		cell.frame = cell.nibFrame;
		[cell.unreadImage setFrame:CGRectMake(cell.unreadImage.frame.origin.x, (cell.frame.size.height / 2) - (cell.unreadImage.frame.size.height / 2),
											  cell.unreadImage.frame.size.width, cell.unreadImage.frame.size.height)];
		cell.prepedForDelete = NO;

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed: @"NewsCell" owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[NewsCell class]])
		{
			cell = (NewsCell *) obj;
			
			// record nib conditions
			cell.nibSubjectLabelFrame = cell.subjectLabel.frame;
			cell.nibDateLabelFrame = cell.dateLabel.frame;
			cell.nibDraftImageFrame = cell.draftImage.frame;
			cell.nibInvisibleImageFrame = cell.invisibleImage.frame;
			cell.nibSubjectLabelTextColor = cell.subjectLabel.textColor;
			cell.nibDateLabelTextColor = cell.dateLabel.textColor;
			cell.nibFrame = cell.frame;
			cell.prepedForDelete = NO;

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
	[unreadImage release];
	[draftImage release];
	[invisibleImage release];
	[nibSubjectLabelTextColor release];
	[nibDateLabelTextColor release];

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
		
		// move the date and icons down to make room
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x, self.dateLabel.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
										self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];

		[self.invisibleImage setFrame:CGRectMake(self.invisibleImage.frame.origin.x, self.invisibleImage.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.invisibleImage.frame.size.width, self.invisibleImage.frame.size.height)];

		[self.draftImage setFrame:CGRectMake(self.draftImage.frame.origin.x, self.draftImage.frame.origin.y + (self.subjectLabel.font.lineHeight * (lines-1)),
											self.draftImage.frame.size.width, self.draftImage.frame.size.height)];

		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.subjectLabel.font.lineHeight * (lines-1)))];
		
		// re-center the unread
		[self.unreadImage setFrame:CGRectMake(self.unreadImage.frame.origin.x, (self.frame.size.height / 2) - (self.unreadImage.frame.size.height / 2),
											 self.unreadImage.frame.size.width, self.unreadImage.frame.size.height)];
	}
	
	self.subjectLabel.text = subject;
}

- (void) setDate:(NSDate *)date draft:(BOOL)draft released:(BOOL)released releaseDate:(NSDate *)releaseDate
{
	if (draft)
	{
		self.dateLabel.text = [date stringInAdaptiveShortFormat];
		self.draftImage.hidden = NO;
		self.dateLabel.textColor = [UIColor lightGrayColor];
		self.subjectLabel.textColor = [UIColor lightGrayColor];
		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x + self.draftImage.frame.size.width, self.dateLabel.frame.origin.y,
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
	}
	else if (released)
	{
		// use the later of the date (modified) and the releaseDate
		NSDate *later = [date laterDate:releaseDate];
		self.dateLabel.text = [later stringInAdaptiveShortFormat];
	}
	else
	{
		self.dateLabel.text = [releaseDate stringInAdaptiveShortFormat];
		self.dateLabel.textColor = [UIColor lightGrayColor];
		self.subjectLabel.textColor = [UIColor lightGrayColor];
		self.invisibleImage.hidden = NO;

		[self.dateLabel setFrame:CGRectMake(self.dateLabel.frame.origin.x + self.invisibleImage.frame.size.width, self.dateLabel.frame.origin.y,
											self.dateLabel.frame.size.width, self.dateLabel.frame.size.height)];
	}
}

- (void) setUnread:(BOOL)unread
{
	self.unreadImage.hidden = !unread;
}

#define DELETE_WIDTH 54

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	if (editing)
	{
		if (!self.prepedForDelete)
		{
			self.prepedForDelete = YES;
			[self.subjectLabel setFrame:CGRectMake(self.subjectLabel.frame.origin.x, self.subjectLabel.frame.origin.y,
												   self.subjectLabel.frame.size.width - DELETE_WIDTH, self.subjectLabel.frame.size.height)];
			self.subjectLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		}
	}
	else if (self.prepedForDelete)
	{
		self.prepedForDelete = NO;
		[self.subjectLabel setFrame:CGRectMake(self.subjectLabel.frame.origin.x, self.subjectLabel.frame.origin.y,
											   self.subjectLabel.frame.size.width + DELETE_WIDTH, self.subjectLabel.frame.size.height)];
		self.subjectLabel.lineBreakMode = NSLineBreakByWordWrapping;
	}
	
	[super setEditing:editing animated:animated];
}

@end
