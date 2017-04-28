/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Modules/SectionCell.m $
 * $Id: SectionCell.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SectionCell.h"
#import "DateFormat.h"
#import "EtudesColors.h"

@interface SectionCell()

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *viewedLabel1;
@property (nonatomic, retain) IBOutlet UILabel *viewedLabel2;
@property (nonatomic, retain) IBOutlet UIImageView *unreadImage;
@property (nonatomic, assign) CGRect nibTitleLabelFrame;
@property (nonatomic, assign) CGRect nibViewedLabel1Frame;
@property (nonatomic, assign) CGRect nibViewedLabel2Frame;
@property (nonatomic, assign) CGRect nibFrame;

@end

@implementation SectionCell

@synthesize titleLabel, viewedLabel1, viewedLabel2, unreadImage;
@synthesize nibTitleLabelFrame, nibViewedLabel1Frame, nibViewedLabel2Frame, nibFrame;

+ (SectionCell *) sectionCellInTable:(UITableView *)table
{
	static NSString *SectionCellId = @"SectionCell";

	SectionCell *cell = [table dequeueReusableCellWithIdentifier:SectionCellId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.titleLabel.frame = cell.nibTitleLabelFrame;
		cell.titleLabel.numberOfLines = 1;
		cell.viewedLabel1.frame = cell.nibViewedLabel1Frame;
		cell.viewedLabel1.hidden = YES;
		cell.viewedLabel2.frame = cell.nibViewedLabel2Frame;
		cell.viewedLabel2.hidden = YES;
		cell.frame = cell.nibFrame;
		[cell.unreadImage setFrame:CGRectMake(cell.unreadImage.frame.origin.x, (cell.frame.size.height / 2) - (cell.unreadImage.frame.size.height / 2),
											  cell.unreadImage.frame.size.width, cell.unreadImage.frame.size.height)];
		cell.unreadImage.hidden = YES;

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:SectionCellId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[SectionCell class]])
		{
			cell = (SectionCell *) obj;
			
			// record nib conditions
			cell.nibFrame = cell.frame;
			cell.nibTitleLabelFrame = cell.titleLabel.frame;
			cell.nibViewedLabel1Frame = cell.viewedLabel1.frame;
			cell.nibViewedLabel2Frame = cell.viewedLabel2.frame;

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
	[titleLabel release];
	[viewedLabel1 release];
	[viewedLabel2 release];
	[unreadImage release];

    [super dealloc];
}

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
		
		// move the viewed line down to make room
		[self.viewedLabel1 setFrame:CGRectMake(self.viewedLabel1.frame.origin.x, self.viewedLabel1.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.viewedLabel1.frame.size.width, self.viewedLabel1.frame.size.height)];
		[self.viewedLabel2 setFrame:CGRectMake(self.viewedLabel2.frame.origin.x, self.viewedLabel2.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.viewedLabel2.frame.size.width, self.viewedLabel2.frame.size.height)];
		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.titleLabel.font.lineHeight * (lines-1)))];
		
		// re-center the unread
		[self.unreadImage setFrame:CGRectMake(self.unreadImage.frame.origin.x, (self.frame.size.height / 2) - (self.unreadImage.frame.size.height / 2),
												self.unreadImage.frame.size.width, self.unreadImage.frame.size.height)];
	}
}

- (void) setViewed:(NSDate *)viewed
{
	if (viewed == nil)
	{
		self.unreadImage.hidden = NO;
		
		// shrink to remove the viewed labels
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height - (self.viewedLabel1.frame.size.height))];
		// re-center the unread
		[self.unreadImage setFrame:CGRectMake(self.unreadImage.frame.origin.x, (self.frame.size.height / 2) - (self.unreadImage.frame.size.height / 2),
											  self.unreadImage.frame.size.width, self.unreadImage.frame.size.height)];
	}
	else
	{
		self.viewedLabel2.text = [viewed stringInEtudesFormat];
		self.viewedLabel2.textColor = [UIColor colorEtudesGreen];
		self.viewedLabel1.hidden = NO;
		self.viewedLabel2.hidden = NO;
	}
}

@end
