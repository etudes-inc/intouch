/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/BadgeView.m $
 * $Id: BadgeView.m 2056 2011-10-06 19:22:01Z ggolden $
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

#import "BadgeView.h"

@interface BadgeView()

@end

@implementation BadgeView

@synthesize text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setText:(NSString *)newText
{
	if (newText != text)
	{
		[text release];
		text = [newText retain];
		
		// we need re-display
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect
{
	// Note: when using this view in a nib, make it 28w x 15h (pixels) for this font size and handling 3 digits
	UIFont *font = [UIFont boldSystemFontOfSize: 12];
	
    // how big is the text?
	CGSize textSize = [self.text sizeWithFont:font];
	
	// and one digit?
	CGSize digitSize = [@"0" sizeWithFont:font];
	
	// pad with one character width
	textSize.width += digitSize.width;
	
	// drawing area - shifted left in our space - based on the textSize
	CGRect bounds = CGRectMake((self.bounds.size.width - textSize.width), 0.0, textSize.width, textSize.height);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
	
	// make a gray round rect
	[[UIColor grayColor] setFill];
	CGFloat minX = CGRectGetMinX(bounds);
	CGFloat maxX = CGRectGetMaxX(bounds);
	CGFloat minY = CGRectGetMinY(bounds);
	CGFloat maxY = CGRectGetMaxY(bounds);
	CGFloat radius = 5.0;
	CGContextMoveToPoint(context, minX + radius, minY);
	CGContextAddArcToPoint(context, maxX, minY, maxX, minY + radius, radius);
	CGContextAddArcToPoint(context, maxX, maxY, maxX - radius, maxY, radius);
	CGContextAddArcToPoint(context, minX, maxY, minX, maxY - radius, radius);
	CGContextAddArcToPoint(context, minX, minY, minX + radius, minY, radius);
	
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	// make the text white - centered
	[[UIColor whiteColor] setFill];
	bounds.origin.x += digitSize.width / 2.0;
	[self.text drawInRect:bounds withFont:font];
}

- (void)dealloc
{
    [super dealloc];
}

@end
