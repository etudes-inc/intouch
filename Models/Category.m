/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Category.m $
 * $Id: Category.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "Category.h"
#import "Forum.h"

@interface Category()

@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray /* <Forum> */ *forums;
@property (nonatomic, assign) BOOL published;
@property (nonatomic, retain) NSDate *open;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSDate *allowUntil;
@property (nonatomic, assign) BOOL hideTillOpen;
@property (nonatomic, assign) BOOL lockOnDue;
@property (nonatomic, assign) BOOL graded;
@property (nonatomic, assign) int minPosts;
@property (nonatomic, assign) float points;
@property (nonatomic, assign) BOOL pastDueLocked;
@property (nonatomic, assign) BOOL notYetOpen;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, retain) NSString *blockedBy;

@end

@implementation Category

@synthesize categoryId, title, forums, published, open, due, allowUntil, hideTillOpen, lockOnDue, graded, minPosts, points, pastDueLocked, notYetOpen;
@synthesize blocked, blockedBy;

#pragma mark - lifecycle

+ (Category *) CategoryForDef:(NSDictionary *)def
{
	NSString *theCategoryId = [def objectForKey:@"categoryId"];
	NSString *theTitle = [def objectForKey:@"title"];
	NSNumber *theOpen = [def objectForKey:@"open"];
	NSNumber *theDue = [def objectForKey:@"due"];
	NSNumber *theAllowUntil = [def objectForKey:@"allowUntil"];
	NSNumber *theHideTillOpen = [def objectForKey:@"hideTillOpen"];
	NSNumber *theLockOnDue = [def objectForKey:@"lockOnDue"];
	NSNumber *thePublished = [def objectForKey:@"published"];
	NSNumber *theGraded = [def objectForKey:@"graded"];
	NSNumber *theMinPosts = [def objectForKey:@"minPosts"];
	NSNumber *thePoints = [def objectForKey:@"points"];
	NSNumber *thePastDueLocked = [def objectForKey:@"pastDueLocked"];
	NSNumber *theNotYetOpen = [def objectForKey:@"notYetOpen"];
	NSString *theBlockedBy = [def objectForKey:@"blocked"];

	NSDate *open = nil;
	NSDate *due = nil;
	NSDate *allowUntil = nil;
	if ([theOpen intValue] != 0) open = [NSDate dateWithTimeIntervalSince1970:[theOpen intValue]];
	if ([theDue intValue] != 0) due = [NSDate dateWithTimeIntervalSince1970:[theDue intValue]];
	if ([theAllowUntil intValue] != 0) allowUntil = [NSDate dateWithTimeIntervalSince1970:[theAllowUntil intValue]];

	Category *category = [[Category alloc] initWithId:theCategoryId title:theTitle published:[thePublished boolValue]
												 open:open due:due allowUntil:allowUntil
										 hideTillOpen:[theHideTillOpen boolValue]
											lockOnDue:[theLockOnDue boolValue] graded:[theGraded boolValue] minPosts:[theMinPosts intValue]
											   points:[thePoints floatValue] pastDueLocked:[thePastDueLocked boolValue] notYetOpen:[theNotYetOpen boolValue]
											  blocked:(theBlockedBy != nil) blockedBy:theBlockedBy];

	// forums in the category
	NSArray *defs = [def objectForKey:@"forums"];
	NSMutableArray *forums = [[NSMutableArray alloc] init];
	for (NSDictionary *def in defs)
	{
		Forum *forum = [Forum forumInCategory:category forDef:def];
		[forums addObject:forum];
	}
	category.forums = forums;
	[forums release];

	return [category autorelease];	
}

- (id) initWithId:(NSString *)theCategoryId title:(NSString *)theTitle published:(BOOL)thePublished open:(NSDate *)theOpen due:(NSDate *)theDue
	   allowUntil:(NSDate *)theAllowUntil hideTillOpen:(BOOL)theHideTillOpen lockOnDue:(BOOL)theLockOnDue graded:(BOOL)theGraded
		 minPosts:(int)theMinPosts points:(float)thePoints pastDueLocked:(BOOL)thePastDueLocked notYetOpen:(BOOL)theNotYetOpen
		  blocked:(BOOL)theBlocked blockedBy:(NSString *)theBlockedBy
{
	self = [super init];
    if (self)
	{
		self.categoryId = theCategoryId;
		self.title = theTitle;
		self.published = thePublished;
		self.open = theOpen;
		self.due = theDue;
		self.allowUntil = theAllowUntil;
		self.hideTillOpen = theHideTillOpen;
		self.lockOnDue = theLockOnDue;
		self.graded = theGraded;
		self.minPosts = theMinPosts;
		self.points = thePoints;
		self.pastDueLocked = thePastDueLocked;
		self.notYetOpen = theNotYetOpen;
		self.blocked = theBlocked;
		self.blockedBy = theBlockedBy;
	}
	
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Category *copy = [[[self class] alloc] init];

    if (copy)
    {
        copy.categoryId = self.categoryId;
        copy.title = self.title;
        copy.forums = self.forums;
        copy.published = self.published;
        copy.open = self.open;
        copy.due = self.due;
        copy.allowUntil = self.allowUntil;
        copy.hideTillOpen = self.hideTillOpen;
        copy.lockOnDue = self.lockOnDue;
        copy.graded = self.graded;
        copy.minPosts = self.minPosts;
        copy.points = self.points;
        copy.pastDueLocked = self.pastDueLocked;
        copy.notYetOpen = self.notYetOpen;
        copy.blocked = self.blocked;
        copy.blockedBy = self.blockedBy;
    }

    return copy;
}

- (void)dealloc
{
	[categoryId release];
	[title release];
	[forums release];
	[open release];
	[due release];
	[allowUntil release];
	[blockedBy release];
	
    [super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Category id:%@ title:%@", self.categoryId, self.title];
}

@end
