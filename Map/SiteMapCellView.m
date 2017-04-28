/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapCellView.m $
 * $Id: SiteMapCellView.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SiteMapCellView.h"

@interface SiteMapCellView()

@property (nonatomic, retain) IBOutlet UIImageView *iconImage;
@property (nonatomic, retain) IBOutlet UIImageView *progressImage;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *status2Label;
@property (nonatomic, assign) CGRect nibTitleLabelFrame;
@property (nonatomic, assign) CGRect nibStatusLabelFrame;
@property (nonatomic, assign) CGRect nibStatus2LabelFrame;
@property (nonatomic, assign) CGRect nibFrame;

@end

@implementation SiteMapCellView

@synthesize iconImage, progressImage, titleLabel, statusLabel, status2Label;
@synthesize nibTitleLabelFrame, nibStatusLabelFrame, nibStatus2LabelFrame, nibFrame;

+ (SiteMapCellView *) siteMapCellViewInTable:(UITableView *)table
{
	static NSString *SiteMapCellViewId = @"SiteMapCellView";

	SiteMapCellView *cell = [table dequeueReusableCellWithIdentifier:SiteMapCellViewId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.frame = cell.nibFrame;
		cell.titleLabel.frame = cell.nibTitleLabelFrame;
		cell.titleLabel.numberOfLines = 1;
		cell.titleLabel.textColor = [UIColor blackColor];
		cell.statusLabel.frame = cell.nibStatusLabelFrame;
		cell.statusLabel.numberOfLines = 1;
		cell.status2Label.frame = cell.nibStatus2LabelFrame;
		cell.status2Label.numberOfLines = 1;
		cell.status2Label.hidden = NO;
		cell.iconImage.hidden = YES;
		cell.progressImage.hidden = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.progressImage setFrame:CGRectMake(cell.progressImage.frame.origin.x, (cell.frame.size.height / 2) - (cell.progressImage.frame.size.height / 2),
												cell.progressImage.frame.size.width, cell.progressImage.frame.size.height)];

		return cell;	
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:SiteMapCellViewId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[SiteMapCellView class]])
		{
			cell = (SiteMapCellView *) obj;
			
			// record nib conditions
			cell.nibFrame = cell.frame;
			cell.nibTitleLabelFrame = cell.titleLabel.frame;
			cell.nibStatusLabelFrame = cell.statusLabel.frame;
			cell.nibStatus2LabelFrame = cell.status2Label.frame;

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
	[iconImage release];
	[progressImage release];
	[titleLabel release];
	[statusLabel release];
	[status2Label release];

    [super dealloc];
}

- (void) setIcon:(UIImage *)image
{
	if (image != nil)
	{
		self.iconImage.image = image;
		self.iconImage.hidden = NO;
	}
}

- (void) setProgress:(UIImage *)image
{
	if (image != nil)
	{
		self.progressImage.image = image;
		self.progressImage.hidden = NO;
	}
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
		
		// move the status line down to make room
		[self.statusLabel setFrame:CGRectMake(self.statusLabel.frame.origin.x, self.statusLabel.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											 self.statusLabel.frame.size.width, self.statusLabel.frame.size.height)];
		
		// move the status2 line down to make room
		[self.status2Label setFrame:CGRectMake(self.status2Label.frame.origin.x, self.status2Label.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.status2Label.frame.size.width, self.status2Label.frame.size.height)];

		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.titleLabel.font.lineHeight * (lines-1)))];
		
		// re-center the progress
		[self.progressImage setFrame:CGRectMake(self.progressImage.frame.origin.x, (self.frame.size.height / 2) - (self.progressImage.frame.size.height / 2),
											 self.progressImage.frame.size.width, self.progressImage.frame.size.height)];
	}
}

- (void) setHidden
{
	self.titleLabel.textColor = [UIColor lightGrayColor];
}

- (void) setActive
{
	self.titleLabel.textColor = [UIColor blueColor];
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void) setStatus:(NSString *)status color:(UIColor *)color
{
	self.statusLabel.text = status;
	self.statusLabel.textColor = color;
		
	// how many lines will the title render in?
	CGSize theSize = [status sizeWithFont:self.statusLabel.font constrainedToSize:CGSizeMake(self.statusLabel.bounds.size.width, FLT_MAX)
						   lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.statusLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.statusLabel setFrame:CGRectMake(self.statusLabel.frame.origin.x, self.statusLabel.frame.origin.y, self.statusLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.statusLabel.numberOfLines = lines;
		
		// move the status2 line down to make room
		[self.status2Label setFrame:CGRectMake(self.status2Label.frame.origin.x, self.status2Label.frame.origin.y + (self.statusLabel.font.lineHeight * (lines-1)),
											   self.status2Label.frame.size.width, self.status2Label.frame.size.height)];

		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.statusLabel.font.lineHeight * (lines-1)))];
		
		// re-center the progress
		[self.progressImage setFrame:CGRectMake(self.progressImage.frame.origin.x, (self.frame.size.height / 2) - (self.progressImage.frame.size.height / 2),
												self.progressImage.frame.size.width, self.progressImage.frame.size.height)];
	}
}

- (void) setStatus2:(NSString *)status color:(UIColor *)color
{
	if (status == nil)
	{
		self.status2Label.hidden = YES;
		
		// decrease our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height - (self.status2Label.frame.size.height))];
	}
	else
	{
		self.status2Label.text = status;
		self.status2Label.textColor = color;
		
		// how many lines will the title render in?
		CGSize theSize = [status sizeWithFont:self.status2Label.font constrainedToSize:CGSizeMake(self.status2Label.bounds.size.width, FLT_MAX)
								lineBreakMode:NSLineBreakByWordWrapping];
		int lines = theSize.height / self.status2Label.font.lineHeight;
		
		// the layout is set for one line - adjust if needed
		if (lines > 1)
		{
			// make the frame larger
			[self.status2Label setFrame:CGRectMake(self.status2Label.frame.origin.x, self.status2Label.frame.origin.y, self.status2Label.frame.size.width, theSize.height)];
			
			// set the number of lines
			self.status2Label.numberOfLines = lines;
			
			// increase our frame
			[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
									  self.frame.size.width, self.frame.size.height + (self.status2Label.font.lineHeight * (lines-1)))];
		}
	}

	// re-center the progress
	[self.progressImage setFrame:CGRectMake(self.progressImage.frame.origin.x, (self.frame.size.height / 2) - (self.progressImage.frame.size.height / 2),
											self.progressImage.frame.size.width, self.progressImage.frame.size.height)];
}

@end
