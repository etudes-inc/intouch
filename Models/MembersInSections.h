/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/MembersInSections.h $
 * $Id: MembersInSections.h 2594 2012-01-31 17:37:21Z ggolden $
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

#import <Foundation/Foundation.h>
#import "Member.h"

@interface MembersInSections : NSObject
{
@protected
	NSDictionary /* keyed by a letter (i.e. "A"), value is NSArray of Member */ *sections;
	NSArray /* NSString */ *possibleSectionTitles;
	NSArray /* NSString */ *actualSectionTitles;
	NSDictionary /* NSString -> NSNumber */ *titleToSectionNumber;
	NSArray /* <Member> */ *members;
	NSArray /* <Member> */ *allMembers;
}

// alloc and init auto-released based on this array of Member objects
+ (MembersInSections *) membersInSectionsWithMembers:(NSArray *)members;

- (id) initWithMembers:(NSArray *)members;

// return the array (Member) of Member objects for this section title
- (NSArray *) /* <Member> */ membersInSectionTitled:(NSString *)section;

// return the array (Member) of Member objects for this section #
- (NSArray *) /* <Member> */ membersInSectionNumbered:(NSUInteger)section;

// return the section number for this title
- (NSInteger) sectionNumberForTitle:(NSString *)title;

// return the # sections
- (NSUInteger) count;

// return this member
- (Member *) memberWithId:(NSString *)memberId;

@property (nonatomic, readonly, retain) NSArray *possibleSectionTitles;
@property (nonatomic, readonly, retain) NSArray *actualSectionTitles;
@property (nonatomic, readonly, retain) NSArray /* <Member> */ *members;

@end
