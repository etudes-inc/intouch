/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ActivityOverview.h $
 * $Id: ActivityOverview.h 2594 2012-01-31 17:37:21Z ggolden $
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

@interface ActivityOverview : NSObject
{
@protected
	NSArray /* <ActivityItem> */ *items;
	int notVisitedAlertCount;

	NSDictionary /* keyed by a letter (i.e. "A"), value is NSArray of ActivityItem */ *sections;
	NSArray /* NSString */ *possibleSectionTitles;
	NSArray /* NSString */ *actualSectionTitles;
	NSDictionary /* NSString -> NSNumber */ *titleToSectionNumber;
}

+ (ActivityOverview *) activityOverviewForDef:(NSDictionary *)def;

@property (nonatomic, readonly, retain) NSArray *items;
@property (nonatomic, readonly, assign) int notVisitedAlertCount;

@property (nonatomic, readonly, retain) NSArray *possibleSectionTitles;
@property (nonatomic, readonly, retain) NSArray *actualSectionTitles;

// return the array (ActivityItem) of objects for this section title
- (NSArray *) /* <ActivityItem> */ membersInSectionTitled:(NSString *)section;

// return the array (ActivityItem) of objects for this section #
- (NSArray *) /* <ActivityItem> */ membersInSectionNumbered:(NSUInteger)section;

// return the section number for this title
- (NSInteger) sectionNumberForTitle:(NSString *)title;

// return the # sections
- (NSUInteger) sectionCount;

@end
