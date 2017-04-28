/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/ColorMapper.h $
 * $Id: ColorMapper.h 2548 2012-01-24 20:05:05Z ggolden $
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

#import <Foundation/Foundation.h>

@interface ColorMapper : NSObject
{
@protected
	NSArray /* UIColor */ *colorChoices;
	NSMutableDictionary /* user id string -> UIColor */ *userColors;
	int next;
}

// initialize
- (id)init;

// return a color for this user - subsequent calls with the same user will return the same color
- (UIColor *) colorForUser:(NSString *)userId;

@end
