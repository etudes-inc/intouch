/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/FloatFormat.m $
 * $Id: FloatFormat.m 2116 2011-10-23 05:10:07Z ggolden $
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

#import "FloatFormat.h"

@implementation FloatFormat

// format to 2 places, no training zeros
+ (NSString *) formatFloat:(float)value
{
	// 2 decimal places
	NSString *fmt = [NSString stringWithFormat:@"%.2f", value];
	
	if ([fmt hasSuffix:@".00"])
	{
		return [fmt substringToIndex:[fmt length]-3];
	}
	
	if ([fmt hasSuffix:@"0"])
	{
		return [fmt substringToIndex:[fmt length]-1];
	}

	return fmt;
}

@end
