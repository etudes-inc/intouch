/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Section.m $
 * $Id: Section.m 2401 2011-12-22 00:24:59Z ggolden $
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

#import "Section.h"

@implementation Section

@synthesize title, sectionId, viewed;

+ (Section *) sectionForDef:(NSDictionary *)def
{
	Section *section = [[Section alloc] init];
	
	// title
	NSString *title = [def objectForKey:@"title"];
	section.title = title;
	
	// id
	NSString *sectionId = [def objectForKey:@"sectionId"];
	section.sectionId = sectionId;

	// viewed
	NSNumber *viewed = [def objectForKey:@"viewed"];
	if ([viewed intValue] != 0) section.viewed = [NSDate dateWithTimeIntervalSince1970:[viewed intValue]];

	return [section autorelease];
}

- (void) dealloc
{
	[title release];
	[sectionId release];
	[viewed	release];

    [super dealloc];
}

@end
