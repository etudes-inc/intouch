/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ActivityOverview.m $
 * $Id: ActivityOverview.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "ActivityOverview.h"
#import "ActivityItem.h"

@interface ActivityOverview()

@property (nonatomic, retain) NSArray /* <ActivityItem> */ *items;
@property (nonatomic, assign) int notVisitedAlertCount;

@property (nonatomic, retain) NSDictionary *sections;
@property (nonatomic, retain) NSArray *possibleSectionTitles;
@property (nonatomic, retain) NSArray *actualSectionTitles;
@property (nonatomic, retain) NSDictionary *titleToSectionNumber;

@end

@implementation ActivityOverview

@synthesize items, notVisitedAlertCount;
@synthesize sections, possibleSectionTitles, actualSectionTitles, titleToSectionNumber;

- (void) setupSections
{
	// the possibilities for section titles
	self.possibleSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",
								  @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"•", nil];
	
	NSMutableDictionary *theSections = [[NSMutableDictionary alloc] init];
	
	for (ActivityItem *item in self.items)
	{
		// use the first character, upper case - but if not found in the possibles, switch it to "•"
		NSString *section = [[item.name substringToIndex:1] uppercaseString];
		if ([section isEqualToString:@"Y"] || [section isEqualToString:@"Z"]) section = @"X";
		if (![self.possibleSectionTitles containsObject:section])
		{
			section = @"•";
		}
		
		NSMutableArray *membersInThisSection = [theSections objectForKey:section];
		
		// if a new section, create an entry in the dictionary
		if (membersInThisSection == nil)
		{
			membersInThisSection = [NSMutableArray arrayWithObject:item];
			[theSections setObject:membersInThisSection forKey:section];
		}
		
		// otherwise add to the array in the dictionary
		else
		{
			[membersInThisSection addObject:item];
		}		
	}

	self.sections = theSections;
	[theSections release];
	
	// find the actual section titles - those with members
	int sectionNum = -1;
	NSMutableArray *sectionsPopulated = [NSMutableArray array];
	NSMutableDictionary *sectionNumbers = [NSMutableDictionary dictionaryWithCapacity:[self.possibleSectionTitles count]];
	for (NSString *title in self.possibleSectionTitles)
	{
		if ([self.sections objectForKey:title] != nil)
		{
			[sectionsPopulated addObject:title];
			
			// since we actually have this section, advance the section number
			sectionNum++;
		}
		
		// this title maps to this section number
		[sectionNumbers setObject:[NSNumber numberWithInt:sectionNum] forKey:title];
	}
	self.actualSectionTitles = sectionsPopulated;
	self.titleToSectionNumber = sectionNumbers;
}

- (id) initWithItems:(NSArray *)theItems notVisitedAlertCount:(int)theNotVisitedAlertCount
{
	self = [super init];
	if (self)
	{
		self.items = theItems;
		[self setupSections];
		self.notVisitedAlertCount = theNotVisitedAlertCount;
	}
	
	return self;
}

+ (ActivityOverview *) activityOverviewForDef:(NSDictionary *)def
{
	// the early alert - not visited in period - count
	NSNumber *theNotVisitedAlertCount = [def objectForKey:@"notVisitedAlertCount"];
	
	// the array of items
	NSArray *itemDefs = [def objectForKey:@"items"];
	
	// build up an array of items
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[itemDefs count]];
	
	for (NSDictionary *itemDef in itemDefs)
	{
		ActivityItem *item = [ActivityItem activityItemForDef:itemDef];
		[items addObject:item];
	}
	
	ActivityOverview *overview = [[ActivityOverview alloc] initWithItems:items notVisitedAlertCount:[theNotVisitedAlertCount intValue]];
	[items release];
	return [overview autorelease];
}

- (void)dealloc
{
	[items release];
	[sections release];
	[possibleSectionTitles release];
	[actualSectionTitles release];
	[titleToSectionNumber release];

	[super dealloc];
}

// return the array (ActivityItem) of objects for this section
- (NSArray *) /* <ActivityItem> */ membersInSectionTitled:(NSString *)section
{
	NSArray * rv = [self.sections objectForKey:section];
	return rv;
}

// return the array (ActivityItem) of objects for this section #
- (NSArray *) /* <ActivityItem> */ membersInSectionNumbered:(NSUInteger)section
{
	NSString *sectionTitle = [self.actualSectionTitles objectAtIndex:section];
	NSArray * rv = [self.sections objectForKey:sectionTitle];
	return rv;
}

// return the # sections
- (NSUInteger)sectionCount
{
	return [self.sections count];
}

// return the section number for this title
- (NSInteger) sectionNumberForTitle:(NSString *)title
{
	NSNumber *numO = [self.titleToSectionNumber objectForKey:title];
	NSInteger num = [numO intValue];
	
	// a -1 means the title has no actual presence, nor are there any before it, so just use 0
	if (num == -1) num = 0;
	return num;
}

@end
