/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/CourseMapItem.h $
 * $Id: CourseMapItem.h 2557 2012-01-25 17:24:33Z ggolden $
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

enum CourseMapItemAccessStatus
{
	archived_accessStatus,
	invalid_accessStatus,
	unpublished_accessStatus,
	published_hidden_accessStatus,
	published_not_yet_open_accessStatus,
	published_accessStatus,
	published_closed_access_accessStatus,
	published_closed_accessStatus
};

enum CourseMapItemDisplayStatus
{
	na_cmids,
	willOpenOn_cmids,
	finishedOn_cmids,
	firstDoThisPrereq_cmids,
	available_cmids,
	completeWithSections_cmids,
	completeWithPosts_cmids,
	completeWithScore_cmids,
	completeByDate_cmids,
	inProgress_cmids,
	inProgressWithSections_cmids,
	inProgressWithPosts_cmids,
	scoredBelowPoints_cmids,
	scoredBelowPointsUngraded_cmids,
	notGraded_cmids,
	scoredPointsMax_cmids,
	closedOn_cmids,
	progressWithSections_cmids,
	progressWithPosts_cmids,
	archived_cmids,
	invalid_cmids,
	unpublished_cmids,
	firstDoThisMasteryPrereq_cmids,
	firstDoThisMasteryUngradedPrereq_cmids,
	firstDoThisPostsPrereq_cmids,
	firstDoThisSectionsPrereq_cmids,
	noPostsRequired_cmids,
	submittedPosts_cmids,
	scoredPointsPartialMax_cmids,
	inProgressWithPostsReq_cmids,
	inProgressWithPostsNoMin_cmids
};

enum CourseMapItemPerformStatus
{
	inProgress_PerformStatus,
	other_PerformStatus
};

enum CourseMapItemProgressStatus
{
	na_ProgressStatus,
	belowMastery_ProgressStatus,
	belowCount_ProgressStatus,
	inProgress_ProgressStatus,
	complete_ProgressStatus,
	missed_ProgressStatus
};

enum CourseMapItemScoreStatus
{
	complete_ScoreStatus,
	none_ScoreStatus,
	partial_ScoreStatus,
	pending_ScoreStatus,
	na_ScoreStatus,
	completePending_ScoreStatus
};

enum CourseMapItemTypeAppCode
{
	mneme_appCode,
	jforum_appCode,
	header_appCode,
	melete_appCode,
	syllabus_appCode
};

enum CourseMapItemType
{
	assignment_type /* (0, 0, true, true, false, "Assignment") */ ,
	forum_type /* (1, 1, true, false, false, "Forum") */ ,
	header_type /* (2, 2, false, false, false, "Header") */ ,
	module_type /* (3, 3, true, false, false, "Module") */ ,
	survey_type /* (4, 0, true, true, false, "Survey") */ ,
	syllabus_type /* (5, 4, false, false, true, "Read and Accept the Syllabus") */ ,
	test_type /* (6, 0, true, true, false, "Test") */ ,
	topic_type /* (7, 1, true, false, false, "Topic") */ ,
	category_type /* (8, 1, true, false, false, "Category") */
};

@interface CourseMapItem : NSObject
{
@protected
	enum CourseMapItemAccessStatus accessStatus;
	NSDate *allowUntil;
	BOOL blocked;
	BOOL blocker;
	int count;
	int countRequired;
	NSDate *due;
	NSDate *finished;
	BOOL complete;
	BOOL incomplete;
	enum CourseMapItemDisplayStatus itemDisplayStatus1;
	enum CourseMapItemDisplayStatus itemDisplayStatus2;
	NSString *mapId;
	int mapPosition;
	BOOL mastered;
	BOOL masteryQualified;
	float masteryLevelScore;
	BOOL multipleRequired;
	BOOL notMasteredAlert;
	NSDate *open;
	enum CourseMapItemPerformStatus performStatus;
	enum CourseMapItemProgressStatus progressStatus;
	float points;
	NSString *providerId;
	BOOL requiresMastery;
	float score;
	enum CourseMapItemScoreStatus scoreStatus;
	NSString *title;
	enum CourseMapItemType type;
	NSString *blockedById;
	id map;
}

@property (nonatomic, readonly, assign) enum CourseMapItemAccessStatus accessStatus;
@property (nonatomic, readonly, retain) NSDate *allowUntil;
@property (nonatomic, readonly, assign) BOOL blocked;
@property (nonatomic, readonly) CourseMapItem *blockedBy;
@property (nonatomic, readonly, assign) BOOL blocker;
@property (nonatomic, readonly, assign) int count;
@property (nonatomic, readonly, assign) int countRequired;
@property (nonatomic, readonly, retain) NSDate *due;
@property (nonatomic, readonly, retain) NSDate *finished;
@property (nonatomic, readonly, assign) BOOL complete;
@property (nonatomic, readonly, assign) BOOL incomplete;
@property (nonatomic, readonly, assign) enum CourseMapItemDisplayStatus itemDisplayStatus1;
@property (nonatomic, readonly, assign) enum CourseMapItemDisplayStatus itemDisplayStatus2;
@property (nonatomic, readonly, retain) NSString *mapId;
@property (nonatomic, readonly, assign) int mapPosition;
@property (nonatomic, readonly, assign) BOOL mastered;
@property (nonatomic, readonly, assign) BOOL masteryLevelQualified;
@property (nonatomic, readonly, assign) float masteryLevelScore;
@property (nonatomic, readonly, assign) BOOL multipleRequired;
@property (nonatomic, readonly, assign) BOOL notMasteredAlert;
@property (nonatomic, readonly, retain) NSDate *open;
@property (nonatomic, readonly, assign) enum CourseMapItemPerformStatus performStatus;
@property (nonatomic, readonly, assign) enum CourseMapItemProgressStatus progressStatus;
@property (nonatomic, readonly, assign) float points;
@property (nonatomic, readonly, retain) NSString *providerId;
@property (nonatomic, readonly, assign) BOOL requiresMastery;
@property (nonatomic, readonly, assign) float score;
@property (nonatomic, readonly, assign) enum CourseMapItemScoreStatus scoreStatus;
@property (nonatomic, readonly, retain) NSString *title;
@property (nonatomic, readonly, assign) enum CourseMapItemType type;
@property (nonatomic, readonly) NSDate *finalDate;
@property (nonatomic, readonly) enum CourseMapItemTypeAppCode typeAppCode;
@property (nonatomic, assign) id /* <CourseMap> */map;

// the numeric topic id for topic items
@property (readonly) NSString *topicId;

// the numeric forum id for forum items
@property (readonly) NSString *forumId;

// the numeric category id for category items
@property (readonly) NSString *categoryId;

+ (CourseMapItem *) courseMapItemForDef:(NSDictionary *)def;

- (id) initWithAccessStatus:(enum CourseMapItemAccessStatus) theAccessStatus allowUntil:(NSDate *)theAllowUntil
					blocked:(BOOL)theBlocked blockedById:(NSString *)theBlockedById blocker:(BOOL)theBlocker
					  count:(int)theCount countRequired:(int)theCountRequired due:(NSDate *)theDue
				   finished:(NSDate *)theFinished complete:(BOOL)theComplete incomplete:(BOOL)theIncomplete
		 itemDisplayStatus1:(enum CourseMapItemDisplayStatus)theItemDisplayStatus1
		 itemDisplayStatus2:(enum CourseMapItemDisplayStatus)theItemDisplayStatus2
					  mapId:(NSString *)theMapId mapPosition:(int)theMapPosition
				   mastered:(BOOL)theMastered masteryLevelQualified:(BOOL)theMasteryLevelQualified masteryLevelScore:(float)theMasteryLevelScore
		   multipleRequired:(BOOL)theMultipleRequired notMasteredAlert:(BOOL)theNotMasteredAlert open:(NSDate *)theOpen
			  performStatus:(enum CourseMapItemPerformStatus)thePerformStatus progressStatus:(enum CourseMapItemProgressStatus)theProgressStatus
					 points:(float)thePoints providerId:(NSString *)theProviderId
			requiresMastery:(BOOL)theRequiresMastery score:(float)theScore scoreStatus:(enum CourseMapItemScoreStatus)theScoreStatus
					  title:(NSString *)theTitle type:(enum CourseMapItemType)theType;

// the type icon image
- (UIImage *) imageForType;

// the text of the type
- (NSString *) textForType;

// the progress icon image
- (UIImage *) imageForProgress;

// the count display text
- (NSString *) countText;

// the score display text
- (NSString *) scoreText;

// the status text
- (NSString *) statusText;

// the status text 2 (may be nil)
- (NSString *)statusText2;

// the text color for the status text
- (UIColor *) statusTextColor;

// the text color for the status text 2
- (UIColor *) statusTextColor2;

// the status text for this displayStatus
- (NSString *)statusTextForDisplayStatus:(enum CourseMapItemDisplayStatus) info;

// the status text color for this displayStatus
- (UIColor *)statusTextColorForDisplayStatus:(enum CourseMapItemDisplayStatus) info;

// if we are in AM and dealing with a survey, we don't show activity
- (BOOL) hideActivityInAM:(BOOL)inAM;

@end
