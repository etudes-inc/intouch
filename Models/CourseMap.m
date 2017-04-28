/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/CourseMap.m $
 * $Id: CourseMap.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "CourseMap.h"
#import "CourseMapItem.h"

@interface CourseMap()

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSArray *filteredItems;
@property (nonatomic, retain) NSArray *nonHeaderItems;
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, assign) BOOL isFiltered;

@end

@implementation CourseMap

@synthesize items, filteredItems, nonHeaderItems, headers, sections, isFiltered;

#pragma mark - lifecycle

- (void) initBySection
{
	NSMutableArray *theHeaders = [[NSMutableArray alloc] init];
	NSMutableArray *theSections = [[NSMutableArray alloc] init];

	NSMutableArray *itemsInSection = nil;
	
	// if there is not a header at the start, start with a header    
	CourseMapItem *first = nil;
    if ([self.filteredItems count] > 0)
    {
        first = [self.filteredItems objectAtIndex:0];
    }
	if ((first == nil) || (first.type != header_type))
	{
		[theHeaders addObject:@""];
		itemsInSection = [[NSMutableArray alloc] init];
		[theSections addObject:itemsInSection];
	}

	for (CourseMapItem *item in self.filteredItems)
	{
		// if a header
		if (item.type == header_type)
		{
			[theHeaders addObject:item.title];
			[itemsInSection release];
			itemsInSection = [[NSMutableArray alloc] init];
			[theSections addObject:itemsInSection];
		}
		else
		{
			[itemsInSection addObject:item];
		}
		
		// put in this map
		item.map = self;
	}

	[itemsInSection release];

	self.headers = theHeaders;
	self.sections = theSections;
	[theHeaders release];
	[theSections release];
}

- (void) initNonHeaderItems
{
	NSMutableArray *newNonHeaderItems = [[NSMutableArray alloc] init];
	for (CourseMapItem *item in self.filteredItems)
	{
		if (item.type != header_type)
		{
			[newNonHeaderItems addObject:item];
		}
	}
	
	self.nonHeaderItems = newNonHeaderItems;
	[newNonHeaderItems release];
}

- (void) filter
{
	NSMutableArray *newFilteredItems = [[NSMutableArray alloc] init];
	for (CourseMapItem *item in self.items)
	{
		if (!self.isFiltered)
		{
			[newFilteredItems addObject:item];
		}
		else if (item.type == header_type)
		{
			[newFilteredItems addObject:item];
		}
		else if (!((item.accessStatus == invalid_accessStatus) || (item.accessStatus == archived_accessStatus)
				   || (item.accessStatus == unpublished_accessStatus) || (item.accessStatus == published_hidden_accessStatus)))
		{
			[newFilteredItems addObject:item];
		}
	}
	
	self.filteredItems = newFilteredItems;
	[newFilteredItems release];
}

- (id) initWithItems:(NSArray *)theItems
{
	self = [super init];
	if (self)
	{
		self.items = theItems;
		self.isFiltered = YES;
		[self filter];

		[self initBySection];
		[self initNonHeaderItems];
	}

	return self;
}

- (void) setFiltered:(BOOL)filtered
{
	if (self.isFiltered != filtered)
	{
		self.isFiltered = filtered;
		[self filter];

		[self initBySection];
		[self initNonHeaderItems];		
	}
}

- (void)dealloc
{
	[items release];
	[filteredItems release];
	[nonHeaderItems release];
	[headers release];
	[sections release];

	[super dealloc];
}

+ (CourseMap *) courseMapForDef:(NSDictionary *)def
{
	// the array of items
	NSArray *itemDefs = [def objectForKey:@"items"];

	// build up an array of items
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[itemDefs count]];

	for (NSDictionary *itemDef in itemDefs)
	{
		CourseMapItem *item = [CourseMapItem courseMapItemForDef:itemDef];
		[items addObject:item];
	}

	CourseMap *map = [[CourseMap alloc] initWithItems:items];
	[items release];
	return [map autorelease];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"CourseMap #items:%lu", (unsigned long)[self.items count]];
}

- (CourseMapItem *) itemById:(NSString *)mapId
{
	for (CourseMapItem *rv in self.items)
	{
		if ([rv.mapId isEqualToString:mapId]) return rv;
	}
	
	return nil;
}

#pragma mark - by section

- (CourseMapItem *) item:(int)itemIndex forSection:(int)sectionIndex
{
	NSArray *section = [self.sections objectAtIndex:sectionIndex];
	CourseMapItem *item = [section objectAtIndex:itemIndex];
	
	return item;
}

- (NSUInteger) numSections
{
	return [self.sections count];
}

- (NSUInteger) numItemsInSection:(int)sectionIndex
{
	NSArray *section = [self.sections objectAtIndex:sectionIndex];
	return [section count];
}

- (NSString *) headerForSection:(int)sectionIndex
{
	return [headers objectAtIndex:sectionIndex];
}

@end
