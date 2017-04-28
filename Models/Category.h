/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Category.h $
 * $Id: Category.h 11714 2015-09-24 22:36:20Z ggolden $
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


@interface Category : NSObject <NSCopying>
{
	NSString *categoryId;
	NSString *title;
	NSArray /* <Forum> */ *forums;
	BOOL published;
	NSDate *open;
	NSDate *due;
	NSDate *allowUntil;
	BOOL hideTillOpen;
	BOOL lockOnDue;
	BOOL graded;
	int minPosts;
	float points;
	BOOL pastDueLocked;
	BOOL notYetOpen;
	BOOL blocked;
	NSString *blockedBy;
}

+ (Category *) CategoryForDef:(NSDictionary *)def;

@property (nonatomic, readonly, retain) NSString *categoryId;
@property (nonatomic, readonly, retain) NSString *title;
@property (nonatomic, readonly, retain) NSArray /* <Forum> */ *forums;
@property (nonatomic, readonly, assign) BOOL published;
@property (nonatomic, readonly, retain) NSDate *open;
@property (nonatomic, readonly, retain) NSDate *due;
@property (nonatomic, readonly, retain) NSDate *allowUntil;
@property (nonatomic, readonly, assign) BOOL hideTillOpen;
@property (nonatomic, readonly, assign) BOOL lockOnDue;
@property (nonatomic, readonly, assign) BOOL graded;
@property (nonatomic, readonly, assign) int minPosts;
@property (nonatomic, readonly, assign) float points;
@property (nonatomic, readonly, assign) BOOL pastDueLocked;
@property (nonatomic, readonly, assign) BOOL notYetOpen;
@property (nonatomic, readonly, assign) BOOL blocked;
@property (nonatomic, readonly, retain) NSString *blockedBy;

- (id) initWithId:(NSString *)theCategoryId title:(NSString *)theTitle published:(BOOL)thePublished open:(NSDate *)theOpen due:(NSDate *)theDue
	   allowUntil:(NSDate *)theAllowUntil hideTillOpen:(BOOL)theHideTillOpen lockOnDue:(BOOL)theLockOnDue graded:(BOOL)theGraded
		 minPosts:(int)theMinPosts points:(float)thePoints pastDueLocked:(BOOL)thePastDueLocked
	   notYetOpen:(BOOL)theNotYetOpen blocked:(BOOL)theBlocked blockedBy:(NSString *)theBlockedBy;

@end
