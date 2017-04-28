/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/PostCellView.m $
 * $Id: PostCellView.m 2481 2012-01-10 20:12:28Z ggolden $
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

#import "PostCellView.h"

@implementation PostCellView

@synthesize body;

+ (PostCellView *) postCellView
{
	PostCellView *cell = nil;
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PostCellView" owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[PostCellView class]])
		{
			cell = (PostCellView *) obj;
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
	body.delegate = nil;
	[body release];

    [super dealloc];
}

@end
