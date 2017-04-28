/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/EtudesColors.m $
 * $Id: EtudesColors.m 2548 2012-01-24 20:05:05Z ggolden $
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

#import "EtudesColors.h"

@implementation UIColor (EtudesColors)

+ (UIColor *) colorEtudesRed
{
	return [UIColor colorWithRed:0.75 green:0 blue:0 alpha:1];
}

+ (UIColor *) colorEtudesGreen
{
	return [UIColor colorWithRed:0 green:0.3 blue:0 alpha:1];
}

+ (UIColor *) colorEtudesAlert
{
	return [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
}

+ (UIColor *) colorEtudesInfoBoxBackground
{
	// #FFFFCC
	return [UIColor colorWithRed:1 green:1 blue:0.796875 alpha:1];
}

+ (UIColor *) colorFromRGBHexString:(NSString *)hex
{
	// #DAA520 - r g b
	
	NSString *r = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(1, 2)]];
	NSScanner *rs = [NSScanner scannerWithString:r];
	unsigned int ri;
	[rs scanHexInt: &ri];
	
	NSString *g = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(3, 2)]];
	NSScanner *gs = [NSScanner scannerWithString:g];
	unsigned int gi;
	[gs scanHexInt: &gi];
	
	NSString *b = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(5, 2)]];
	NSScanner *bs = [NSScanner scannerWithString:b];
	unsigned int bi;
	[bs scanHexInt: &bi];
	
	float rf = (float)ri;
	float gf = (float)gi;
	float bf = (float)bi;
	
	UIColor *rv = [UIColor colorWithRed:(rf / 255.0) green:(gf / 255.0) blue:(bf / 255.0) alpha:1.0];
	return rv;
}

@end
