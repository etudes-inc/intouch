/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/MembersInSections.m $
 * $Id: MembersInSections.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "MembersInSections.h"

@interface MembersInSections()

@property (nonatomic, retain) NSDictionary *sections;
@property (nonatomic, retain) NSArray *possibleSectionTitles;
@property (nonatomic, retain) NSArray *actualSectionTitles;
@property (nonatomic, retain) NSDictionary *titleToSectionNumber;
@property (nonatomic, retain) NSArray /* <Member> */ *members;
@property (nonatomic, retain) NSArray /* <Member> */ *allMembers;

@end

@implementation MembersInSections

@synthesize sections, possibleSectionTitles, actualSectionTitles, titleToSectionNumber, members, allMembers;

// alloc and init auto-released based on this array of Member objects
+ (MembersInSections *) membersInSectionsWithMembers:(NSArray *)members;
{
	MembersInSections *rv = [[MembersInSections alloc] initWithMembers:members];
	return [rv autorelease];
}

- (id) initWithMembers:(NSArray *)mbrs
{
	self = [super init];
	if (self)
	{
		// the possibilities for section titles
		self.possibleSectionTitles = [NSArray arrayWithObjects:@"*", @"•", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",
									  @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", nil];

		// record the unfiltered list for member finding
		self.allMembers = mbrs;

		// filter away blocked and dropped students for the lists
		NSMutableArray *filtered = [[NSMutableArray alloc] init];
		for (Member *mbr in self.allMembers)
		{
			if (mbr.active)
			{
				[filtered addObject:mbr];
			}
		}

		self.members = filtered;
		[filtered release];

		NSMutableDictionary *theSections = [[NSMutableDictionary alloc] init];
		
		for (Member *mbr in self.members)
		{
			// use the first character, upper case - but if not found in the possibles, switch it to "X"
			NSString *section = [[mbr.displayName substringToIndex:1] uppercaseString];
			if ([section isEqualToString:@"Y"] || [section isEqualToString:@"Z"]) section = @"X";
			if (![self.possibleSectionTitles containsObject:section])
			{
				section = @"X";
			}

			NSMutableArray *membersInThisSection = [theSections objectForKey:section];
			
			// if a new section, create an entry in the dictionary
			if (membersInThisSection == nil)
			{
				membersInThisSection = [NSMutableArray arrayWithObject:mbr];
				[theSections setObject:membersInThisSection forKey:section];
			}
			
			// otherwise add to the array in the dictionary
			else
			{
				[membersInThisSection addObject:mbr];
			}
			
			// if a 'hat', add again to the special section
			if (mbr.status == hat_participantStatus)
			{
				NSMutableArray *membersInSpecialSection = [theSections objectForKey:@"•"];
				
				// if a new section, create an entry in the dictionary
				if (membersInSpecialSection == nil)
				{
					membersInSpecialSection = [NSMutableArray arrayWithObject:mbr];
					[theSections setObject:membersInSpecialSection forKey:@"•"];
				}
				
				// otherwise add to the array in the dictionary
				else
				{
					[membersInSpecialSection addObject:mbr];
				}
			}

			// if this is the logged in user, add to that special section
			if (mbr.isLoginUser)
			{
				NSMutableArray *membersInSpecialSection = [theSections objectForKey:@"*"];
				
				// if a new section, create an entry in the dictionary
				if (membersInSpecialSection == nil)
				{
					membersInSpecialSection = [NSMutableArray arrayWithObject:mbr];
					[theSections setObject:membersInSpecialSection forKey:@"*"];
				}
				
				// otherwise add to the array in the dictionary
				else
				{
					[membersInSpecialSection addObject:mbr];
				}
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
	
	return self;
}

-  (void) dealloc
{
	[sections release];
	[possibleSectionTitles release];
	[actualSectionTitles release];
	[titleToSectionNumber release];
	[members release];
	[allMembers release];

	[super dealloc];
}

// return the array (Member) of objects for this section
- (NSArray *) /* <Member> */ membersInSectionTitled:(NSString *)section
{
	NSArray * rv = [self.sections objectForKey:section];
	return rv;
}

// return the array (Member) of objects for this section #
- (NSArray *) /* <Member> */ membersInSectionNumbered:(NSUInteger)section
{
	NSString *sectionTitle = [self.actualSectionTitles objectAtIndex:section];
	NSArray * rv = [self.sections objectForKey:sectionTitle];
	return rv;
}

// return the # entries
- (NSUInteger)count
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

// return this member
- (Member *) memberWithId:(NSString *)memberId
{
	for (Member *mbr in self.allMembers)
	{
		if ([mbr.userId isEqualToString:memberId])
		{
			return mbr;
		}
	}

	return nil;
}

@end
