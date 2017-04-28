/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapHeaderCellView.m $
 * $Id: SiteMapHeaderCellView.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SiteMapHeaderCellView.h"

@interface SiteMapHeaderCellView()

@property (nonatomic, retain) IBOutlet UIImageView *iconImage;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *bkgView;
@property (nonatomic, assign) CGRect nibTitleLabelFrame;
@property (nonatomic, assign) CGRect nibFrame;

@end

@implementation SiteMapHeaderCellView

@synthesize iconImage, titleLabel, bkgView, nibTitleLabelFrame, nibFrame;

+ (SiteMapHeaderCellView *) siteMapHeaderCellViewInTable:(UITableView *)table
{
	static NSString *SiteMapHeaderCellViewId = @"SiteMapHeaderCellView";
	
	SiteMapHeaderCellView *cell = [table dequeueReusableCellWithIdentifier:SiteMapHeaderCellViewId];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.frame = cell.nibFrame;
		cell.bkgView.frame = cell.nibFrame;
		cell.titleLabel.frame = cell.nibTitleLabelFrame;
		cell.titleLabel.numberOfLines = 1;
		[cell.iconImage setFrame:CGRectMake(cell.iconImage.frame.origin.x, (cell.frame.size.height / 2) - (cell.iconImage.frame.size.height / 2),
											cell.iconImage.frame.size.width, cell.iconImage.frame.size.height)];
		
		return cell;	
	}
	
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:SiteMapHeaderCellViewId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[SiteMapHeaderCellView class]])
		{
			cell = (SiteMapHeaderCellView *) obj;
			
			// record nib conditions
			cell.nibFrame = cell.frame;
			cell.nibTitleLabelFrame = cell.titleLabel.frame;
			
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
	[titleLabel release];
	[bkgView release];

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

		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.titleLabel.font.lineHeight * (lines-1)))];
		self.bkgView.frame = self.frame;

		// re-center the icon
		[self.iconImage setFrame:CGRectMake(self.iconImage.frame.origin.x, (self.frame.size.height / 2) - (self.iconImage.frame.size.height / 2),
											 self.iconImage.frame.size.width, self.iconImage.frame.size.height)];
	}
}

@end
