/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/CourseMap.h $
 * $Id: CourseMap.h 11714 2015-09-24 22:36:20Z ggolden $
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

#import <Foundation/Foundation.h>
#import "CourseMapItem.h"

@interface CourseMap : NSObject
{
@protected
	NSArray /* <CourseMapItem> */ *items;
	NSArray /* <CourseMapItem> */ *filteredItems;
	NSArray /* <CourseMapItem> */ *nonHeaderItems;
	NSArray /* <NSString> */ *headers;
	NSArray /* NSArray<CourseMapItem> */ *sections;
	BOOL isFiltered;
}

+ (CourseMap *) courseMapForDef:(NSDictionary *)def;

@property (nonatomic, readonly, retain) NSArray *items;
@property (nonatomic, readonly, retain) NSArray *filteredItems;
@property (nonatomic, readonly, retain) NSArray *nonHeaderItems;

- (CourseMapItem *) item:(int)item forSection:(int)section;

- (CourseMapItem *) itemById:(NSString *)mapId;

- (NSString *) headerForSection:(int)section;
- (NSUInteger) numSections;
- (NSUInteger) numItemsInSection:(int)section;

// set as filtered, showing all items, or not, showing just student-visible items
- (void) setFiltered:(BOOL) filtered;

@end
