/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/NavBarTitle.m $
 * $Id: NavBarTitle.m 11714 2015-09-24 22:36:20Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011 Etudes, Inc.
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

#import "NavBarTitle.h"

@implementation NavBarTitle

- (id)initWithSiteTitle:(NSString *)siteTitle title:(NSString *)title
{
	// frame to fit in the navigation bar of the iPhone in the title area
	CGRect frame;
	frame.origin.x = 0;
	frame.origin.y = 0;
	frame.size.width = 160;
	frame.size.height = 44;

    self = [super initWithFrame:frame];
    if (self)
	{
		// the site title goes into the top area, in the smaller region
		frame.size.height = 18;
		UILabel *siteTitleLabel = [[UILabel alloc] initWithFrame:frame];
		siteTitleLabel.text = siteTitle;
		siteTitleLabel.textColor = [UIColor blackColor];
		siteTitleLabel.backgroundColor=[UIColor clearColor];
		siteTitleLabel.textAlignment = NSTextAlignmentCenter;
		siteTitleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		siteTitleLabel.adjustsFontSizeToFitWidth = YES;
		[self addSubview:siteTitleLabel];
		[siteTitleLabel release];
		
		// the title goes into the bottom area, the larger region
		frame.size.height = 26;
		frame.origin.y = 18;
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.text = title;
		label.textColor = [UIColor whiteColor];
		label.backgroundColor=[UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont boldSystemFontOfSize:18.0];
		label.adjustsFontSizeToFitWidth = YES;
		label.minimumScaleFactor = 12.0 / [UIFont labelFontSize];
		[self addSubview:label];
		[label release];
    }
    return self;
}

- (void) setTitle:(NSString *)title
{
	((UILabel *)[self.subviews objectAtIndex:1]).text = title;
}

- (void)dealloc
{
    [super dealloc];
}

@end
