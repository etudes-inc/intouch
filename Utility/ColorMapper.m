/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/ColorMapper.m $
 * $Id: ColorMapper.m 2548 2012-01-24 20:05:05Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2012 Etudes, Inc.
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

#import "ColorMapper.h"
#import "EtudesColors.h"

@interface ColorMapper()

@property (nonatomic, retain) NSArray /* UIColor */ *colorChoices;
@property (nonatomic, retain) NSMutableDictionary /* user id string -> UIColor */ *userColors;
@property (nonatomic, assign) int next;

@end

@implementation ColorMapper

@synthesize colorChoices, userColors, next;

- (id)init
{
    self = [super init];
    if (self)
	{
		// where we store assignments
		NSMutableDictionary	*d = [[NSMutableDictionary alloc] init];
		self.userColors = d;
		[d release];

		// setup some colors
		// http://www.w3schools.com/html/html_colornames.asp
		self.colorChoices = [NSArray arrayWithObjects:
							 [UIColor colorFromRGBHexString:@"#FF0000"],		// red
							 [UIColor colorFromRGBHexString:@"#0000FF"],		// blue
							 [UIColor colorFromRGBHexString:@"#008000"],		// green
							 [UIColor colorFromRGBHexString:@"#FFA500"],		// orange
							 [UIColor colorFromRGBHexString:@"#B22222"],		// firebrick
							 [UIColor colorFromRGBHexString:@"#008080"],		// teal
							 [UIColor colorFromRGBHexString:@"#DAA520"],		// goldenrod
							 [UIColor colorFromRGBHexString:@"#006400"],		// darkgreen
							 [UIColor colorFromRGBHexString:@"#9400D3"],		// darkviolet
							 [UIColor colorFromRGBHexString:@"#778899"],		// lightslategray
							 [UIColor colorFromRGBHexString:@"#CD853F"],		// peru
							 [UIColor colorFromRGBHexString:@"#FF1493"],		// deeppink
							 [UIColor colorFromRGBHexString:@"#1E90FF"],		// dodgerblue
							 [UIColor colorFromRGBHexString:@"#32CD32"],		// limegreen
							 [UIColor colorFromRGBHexString:@"#BC8F8F"],		// rosybrown
							 [UIColor colorFromRGBHexString:@"#6495ED"],		// cornflowerblue
							 [UIColor colorFromRGBHexString:@"#40E0D0"],		// turquoise
							 [UIColor colorFromRGBHexString:@"#FF8C00"],		// darkorange
							 [UIColor colorFromRGBHexString:@"#8A2BE2"],		// blueviolet
							 [UIColor colorFromRGBHexString:@"#4169E1"],		// royalblue
							 [UIColor colorFromRGBHexString:@"#A52A2A"],		// brown
							 [UIColor colorFromRGBHexString:@"#FF00FF"],		// magenta
							 [UIColor colorFromRGBHexString:@"#8B4513"],		// saddlebrown
							 [UIColor colorFromRGBHexString:@"#800080"],		// purple
							 [UIColor colorFromRGBHexString:@"#FF7F50"],		// coral
							 [UIColor colorFromRGBHexString:@"#7B68EE"],		// mediumslateblue
							 [UIColor colorFromRGBHexString:@"#A0522D"],		// sienna
							 [UIColor colorFromRGBHexString:@"#48D1CC"],		// mediumturquoise
							 [UIColor colorFromRGBHexString:@"#FF69B4"],		// hotpink
							 [UIColor colorFromRGBHexString:@"#7CFC00"],		// lawngreen
							 [UIColor colorFromRGBHexString:@"#C71585"],		// mediumvioletred
							 [UIColor colorFromRGBHexString:@"#6A5ACD"],		// slateblue
							 [UIColor colorFromRGBHexString:@"#CD5C5C"],		// indianred
							 [UIColor colorFromRGBHexString:@"#708090"],		// slategray
							 [UIColor colorFromRGBHexString:@"#4B0082"],		// indigo
							 [UIColor colorFromRGBHexString:@"#008B8B"],		// darkcyan
							 [UIColor colorFromRGBHexString:@"#00FF7F"],		// springgreen
							 [UIColor colorFromRGBHexString:@"#B8860B"],		// darkgoldenrod
							 [UIColor colorFromRGBHexString:@"#4682B4"],		// steelblue
							 [UIColor colorFromRGBHexString:@"#A9A9A9"],		// darkgray
							 [UIColor colorFromRGBHexString:@"#DA70D6"],		// orchid
							 [UIColor colorFromRGBHexString:@"#E9967A"],		// darksalmon
							 [UIColor colorFromRGBHexString:@"#00FF00"],		// lime
							 [UIColor colorFromRGBHexString:@"#FFD700"],		// gold
							 [UIColor colorFromRGBHexString:@"#00CED1"],		// darkturquoise
							 [UIColor colorFromRGBHexString:@"#000080"],		// navy
							 [UIColor colorFromRGBHexString:@"#FF4500"],		// orangered
							 [UIColor colorFromRGBHexString:@"#BDB76B"],		// darkkhaki
							 [UIColor colorFromRGBHexString:@"#8B008B"],		// darkmagenta
							 [UIColor colorFromRGBHexString:@"#556B2F"],		// darkolivegreen
							 [UIColor colorFromRGBHexString:@"#FF6347"],		// tomato
							 [UIColor colorFromRGBHexString:@"#00FFFF"],		// aqua
							 [UIColor colorFromRGBHexString:@"#8B0000"],		// darkred
							 [UIColor colorFromRGBHexString:@"#6B8E23"],		// olivedrab
							 nil];
    }
    return self;
}

- (void)dealloc
{
	[colorChoices release];
	[userColors release];

    [super dealloc];
}

// return a color for this user - subsequent calls with the same user will return the same color
- (UIColor *) colorForUser:(NSString *)userId
{
	// see if we have an assignment
	UIColor *rv = [self.userColors objectForKey:userId];
	if (rv == nil)
	{
		// assign the next color
		rv = [self.colorChoices objectAtIndex:self.next];
		
		// remember
		[self.userColors setObject:rv forKey:userId];
		
		// advance next to a valid choice
		self.next = self.next + 1;
		if (self.next >= [self.colorChoices count]) self.next = 0;
	}
	
	return rv;
}

@end
