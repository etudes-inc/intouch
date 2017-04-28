/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/CategoryHeaderView.m $
 * $Id: CategoryHeaderView.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "CategoryHeaderView.h"
#import "DateFormat.h"

@interface CategoryHeaderView()

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *dates;
@property (nonatomic, retain) IBOutlet UIImageView *publishedHiddenIcon;
@property (nonatomic, retain) IBOutlet UIImageView *blockedIcon;

@end

@implementation CategoryHeaderView

@synthesize title, dates, publishedHiddenIcon, blockedIcon;

+ (CategoryHeaderView *) categoryHeaderView
{
	static NSString *CategoryHeaderViewId = @"CategoryHeaderView";
	
	CategoryHeaderView *cell = nil;
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:CategoryHeaderViewId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[CategoryHeaderView class]])
		{
			cell = (CategoryHeaderView *) obj;
			break;
		}
	}
	return cell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
	[title release];
	[dates release];
	[publishedHiddenIcon release];
	[blockedIcon release];

    [super dealloc];
}

- (void) setCategoryTitle:(NSString *)theTitle
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

		// move the dates ... down to make room
		[self.dates setFrame:CGRectMake(self.dates.frame.origin.x, self.dates.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
									self.dates.frame.size.width, self.dates.frame.size.height)];
		[self.publishedHiddenIcon setFrame:CGRectMake(self.publishedHiddenIcon.frame.origin.x,
												  self.publishedHiddenIcon.frame.origin.y + (self.title.font.lineHeight * (lines-1)),
												  self.publishedHiddenIcon.frame.size.width, self.publishedHiddenIcon.frame.size.height)];

		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.title.font.lineHeight * (lines-1)))];
	}
}

// set published / hidden
- (void) setPublishedHidden:(BOOL)pubHidden
{
	if (!pubHidden) return;
	
	self.publishedHiddenIcon.hidden = NO;
	
	// shift the date over
	[self.dates setFrame:CGRectMake(self.dates.frame.origin.x + self.publishedHiddenIcon.frame.size.width,
									self.dates.frame.origin.y, self.dates.frame.size.width, self.dates.frame.size.height)];
}

// set blocked
- (void) setBlocked:(BOOL)blocked
{
	if (!blocked) return;
	
	self.blockedIcon.hidden = NO;
	
	// shift the date over
	[self.dates setFrame:CGRectMake(self.dates.frame.origin.x + self.blockedIcon.frame.size.width,
									self.dates.frame.origin.y, self.dates.frame.size.width, self.dates.frame.size.height)];
}

- (void) setCategoryDatesWithOpen:(NSDate *)openDate due:(NSDate *)dueDate
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
		// hide the dates label
		self.dates.hidden = YES;
		
		// reduce the frame unless we are showing the publishedHidden or blocked icons
		if (self.publishedHiddenIcon.hidden && self.blockedIcon.hidden)
		{
			// be less high by self.dates.frame.size.height
			[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
									  self.frame.size.width, self.frame.size.height - self.dates.frame.size.height)];
		}
	}
}

@end
