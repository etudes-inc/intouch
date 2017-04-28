/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/CourseMapItem.m $
 * $Id: CourseMapItem.m 2542 2012-01-21 23:26:49Z ggolden $
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

#import "CourseMapItem.h"
#import "DateFormat.h"
#import "CourseMap.h"
#import "FloatFormat.h"
#import "EtudesColors.h"

@interface CourseMapItem()

@property (nonatomic, assign) enum CourseMapItemAccessStatus accessStatus;
@property (nonatomic, retain) NSDate *allowUntil;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, assign) BOOL blocker;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) int countRequired;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSDate *finished;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, assign) BOOL incomplete;
@property (nonatomic, assign) enum CourseMapItemDisplayStatus itemDisplayStatus1;
@property (nonatomic, assign) enum CourseMapItemDisplayStatus itemDisplayStatus2;
@property (nonatomic, retain) NSString *mapId;
@property (nonatomic, assign) int mapPosition;
@property (nonatomic, assign) BOOL mastered;
@property (nonatomic, assign) BOOL masteryLevelQualified;
@property (nonatomic, assign) float masteryLevelScore;
@property (nonatomic, assign) BOOL multipleRequired;
@property (nonatomic, assign) BOOL notMasteredAlert;
@property (nonatomic, retain) NSDate *open;
@property (nonatomic, assign) enum CourseMapItemPerformStatus performStatus;
@property (nonatomic, assign) enum CourseMapItemProgressStatus progressStatus;
@property (nonatomic, assign) float points;
@property (nonatomic, retain) NSString *providerId;
@property (nonatomic, assign) BOOL requiresMastery;
@property (nonatomic, assign) float score;
@property (nonatomic, assign) enum CourseMapItemScoreStatus scoreStatus;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) enum CourseMapItemType type;
@property (nonatomic, retain) NSString *blockedById;

@end

@implementation CourseMapItem

@synthesize accessStatus, allowUntil, blocked, blocker, count, countRequired;
@synthesize due, finished, complete, incomplete, itemDisplayStatus1, itemDisplayStatus2, mapId, mapPosition;
@synthesize mastered, masteryLevelQualified, masteryLevelScore, multipleRequired;
@synthesize notMasteredAlert, open, performStatus, progressStatus, points, providerId, requiresMastery;
@synthesize score, scoreStatus, title, type, blockedById, typeAppCode;
@synthesize map;

#pragma mark - Lifecycle

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
					  title:(NSString *)theTitle type:(enum CourseMapItemType)theType
{
	
	self = [super init];
    if (self)
	{
		self.accessStatus = theAccessStatus;
		self.allowUntil = theAllowUntil;
		self.blocked = theBlocked;
		self.blockedById = theBlockedById;
		self.blocker = theBlocker;
		self.count = theCount;
		self.countRequired = theCountRequired;
		self.due = theDue;
		self.finished = theFinished;
		self.complete = theComplete;
		self.incomplete = theIncomplete;
		self.itemDisplayStatus1 = theItemDisplayStatus1;
		self.itemDisplayStatus2 = theItemDisplayStatus2;
		self.mapId	= theMapId;
		self.mapPosition = theMapPosition;
		self.mastered = theMastered;
		self.masteryLevelQualified = theMasteryLevelQualified;
		self.masteryLevelScore = theMasteryLevelScore;
		self.multipleRequired = theMultipleRequired;
		self.notMasteredAlert = theNotMasteredAlert;
		self.open = theOpen;
		self.performStatus = thePerformStatus;
		self.progressStatus = theProgressStatus;
		self.points = thePoints;
		self.providerId = theProviderId;
		self.requiresMastery = theRequiresMastery;
		self.score = theScore;
		self.scoreStatus = theScoreStatus;

		// lets make sure we have some title
		// if (((NSNull *)theTitle == [NSNull null]) || (theTitle == nil))
		if (([theTitle isKindOfClass:[NSNull class]]) || (theTitle == nil))
		{
			theTitle = @"";
		}
		self.title = theTitle;

		self.type = theType;
	}
	
    return self;
}

- (void) dealloc
{
	
	[allowUntil release];
	[due release];
	[finished release];
	[mapId release];
	[open release];
	[providerId release];
	[title release];

    [super dealloc];
}

+ (enum CourseMapItemDisplayStatus) cmDisplayStatus:(NSNumber *)num
{
	enum CourseMapItemDisplayStatus theDs = na_cmids;
	switch ([num intValue])
	{
		case 1:
			theDs = willOpenOn_cmids;
			break;
			
		case 2:
			theDs = finishedOn_cmids;
			break;
			
		case 3:
			theDs = firstDoThisPrereq_cmids;
			break;
			
		case 4:
			theDs = available_cmids;
			break;
			
		case 5:
			theDs = completeWithSections_cmids;
			break;
			
		case 6:
			theDs = completeWithPosts_cmids;
			break;
			
		case 7:
			theDs = completeWithScore_cmids;
			break;
			
		case 8:
			theDs = completeByDate_cmids;
			break;
			
		case 9:
			theDs = inProgress_cmids;
			break;
			
		case 10:
			theDs = inProgressWithSections_cmids;
			break;
			
		case 11:
			theDs = inProgressWithPosts_cmids;
			break;
			
		case 12:
			theDs = scoredBelowPoints_cmids;
			break;
			
		case 13:
			theDs = scoredBelowPointsUngraded_cmids;
			break;
			
		case 14:
			theDs = notGraded_cmids;
			break;
			
		case 15:
			theDs = scoredPointsMax_cmids;
			break;
			
		case 16:
			theDs = closedOn_cmids;
			break;

		case 17:
			theDs = progressWithSections_cmids;
			break;

		case 18:
			theDs = progressWithPosts_cmids;
			break;

		case 19:
			theDs = archived_cmids;
			break;

		case 20:
			theDs = invalid_cmids;
			break;

		case 21:
			theDs = unpublished_cmids;
			break;

		case 22:
			theDs = firstDoThisMasteryPrereq_cmids;
			break;

		case 23:
			theDs = firstDoThisMasteryUngradedPrereq_cmids;
			break;

		case 24:
			theDs = firstDoThisPostsPrereq_cmids;
			break;

		case 25:
			theDs = firstDoThisSectionsPrereq_cmids;
			break;

		case 26:
			theDs = noPostsRequired_cmids;
			break;

		case 27:
			theDs = submittedPosts_cmids;
			break;

		case 28:
			theDs = scoredPointsPartialMax_cmids;
			break;

		case 29:
			theDs = inProgressWithPostsReq_cmids;
			break;

		case 30:
			theDs = inProgressWithPostsNoMin_cmids;
			break;
	}

	return theDs;	
}

+ (CourseMapItem *) courseMapItemForDef:(NSDictionary *)def
{
	NSNumber *the_accessStatus = [def objectForKey:@"accessStatus"];
	enum CourseMapItemAccessStatus theAccessStatus = archived_accessStatus;
	switch ([the_accessStatus intValue])
	{
		case 1:
			theAccessStatus = invalid_accessStatus;
			break;

		case 2:
			theAccessStatus = unpublished_accessStatus;
			break;
			
		case 3:
			theAccessStatus = published_hidden_accessStatus;
			break;
			
		case 4:
			theAccessStatus = published_not_yet_open_accessStatus;
			break;
			
		case 5:
			theAccessStatus = published_accessStatus;
			break;
			
		case 6:
			theAccessStatus = published_closed_access_accessStatus;
			break;
			
		case 7:
			theAccessStatus = published_closed_accessStatus;
			break;
	}

	NSNumber *the_allowUntil = [def objectForKey:@"allowUntil"];
	NSDate *theAllowUntil = nil;
	if ([the_allowUntil intValue] != 0) theAllowUntil = [NSDate dateWithTimeIntervalSince1970:[the_allowUntil intValue]];

	NSNumber *the_blocked = [def objectForKey:@"blocked"];
	BOOL theBlocked = [the_blocked boolValue];

	NSString *theBlockedByMapId = [def objectForKey:@"blockedByMapId"];

	NSNumber *the_blocker = [def objectForKey:@"blocker"];
	BOOL theBlocker = [the_blocker boolValue];

	NSNumber *the_count = [def objectForKey:@"count"];
	int theCount = [the_count intValue];

	NSNumber *the_countRequired = [def objectForKey:@"countRequired"];
	int theCountRequired = [the_countRequired intValue];

	NSNumber *the_due = [def objectForKey:@"due"];
	NSDate *theDue = nil;
	if ([the_due intValue] != 0) theDue = [NSDate dateWithTimeIntervalSince1970:[the_due intValue]];

	NSNumber *the_finished = [def objectForKey:@"finished"];
	NSDate *theFinished = nil;
	if ([the_finished intValue] != 0) theFinished = [NSDate dateWithTimeIntervalSince1970:[the_finished intValue]];

	NSNumber *the_complete = [def objectForKey:@"complete"];
	BOOL theComplete = [the_complete boolValue];

	NSNumber *the_incomplete = [def objectForKey:@"incomplete"];
	BOOL theIncomplete = [the_incomplete boolValue];

	NSNumber *the_itemDisplayStatus1 = [def objectForKey:@"itemDisplayStatus1"];
	enum CourseMapItemDisplayStatus theDisplayStatus1 = [self cmDisplayStatus:the_itemDisplayStatus1];
	
	NSNumber *the_itemDisplayStatus2 = [def objectForKey:@"itemDisplayStatus2"];
	enum CourseMapItemDisplayStatus theDisplayStatus2 = [self cmDisplayStatus:the_itemDisplayStatus2];

	NSString *theMapId = [def objectForKey:@"mapId"];

	NSNumber *the_mapPosition = [def objectForKey:@"mapPosition"];
	int theMapPosition = [the_mapPosition intValue];

	NSNumber *the_mastered = [def objectForKey:@"mastered"];
	BOOL theMastered = [the_mastered boolValue];

	NSNumber *the_masteryLevelQualified = [def objectForKey:@"masteryLevelQualified"];
	BOOL theMasteryLevelQualified = [the_masteryLevelQualified boolValue];

	NSNumber *the_masteryLevelScore = [def objectForKey:@"masteryLevelScore"];
	float theMasteryLevelScore = [the_masteryLevelScore floatValue];

	NSNumber *the_multipleRequired = [def objectForKey:@"multipleRequired"];
	BOOL theMultipleRequired = [the_multipleRequired boolValue];

	NSNumber *the_notMasteredAlert = [def objectForKey:@"notMasteredAlert"];
	BOOL theNotMasteredAlert = [the_notMasteredAlert boolValue];

	NSNumber *the_open = [def objectForKey:@"open"];
	NSDate *theOpen = nil;
	if ([the_open intValue] != 0) theOpen = [NSDate dateWithTimeIntervalSince1970:[the_open intValue]];

	NSNumber *the_performStatus = [def objectForKey:@"performStatus"];
	enum CourseMapItemPerformStatus thePerformStatus = inProgress_PerformStatus;
	switch ([the_performStatus intValue])
	{
		case 1:
			thePerformStatus = other_PerformStatus;
			break;
	}

	NSNumber *the_progressStatus = [def objectForKey:@"progressStatus"];
	enum CourseMapItemProgressStatus theProgressStatus = na_ProgressStatus;
	switch ([the_progressStatus intValue])
	{
		case 1:
			theProgressStatus = belowMastery_ProgressStatus;
			break;
		case 2:
			theProgressStatus = belowCount_ProgressStatus;
			break;
		case 3:
			theProgressStatus = inProgress_ProgressStatus;
			break;
		case 4:
			theProgressStatus = complete_ProgressStatus;
			break;
		case 5:
			theProgressStatus = missed_ProgressStatus;
			break;
	}

	NSNumber *the_points = [def objectForKey:@"points"];
	float thePoints = [the_points floatValue];

	NSString *theProviderId = [def objectForKey:@"providerId"];

	NSNumber *the_requiresMastery = [def objectForKey:@"requiresMastery"];
	BOOL theRequiresMastery = [the_requiresMastery boolValue];

	NSNumber *the_score = [def objectForKey:@"score"];
	float theScore = [the_score floatValue];

	NSNumber *the_scoreStatus = [def objectForKey:@"scoreStatus"];
	enum CourseMapItemScoreStatus theScoreStatus = complete_ScoreStatus;
	switch ([the_scoreStatus intValue])
	{
		case 1:
			theScoreStatus = none_ScoreStatus;
			break;
			
		case 2:
			theScoreStatus = partial_ScoreStatus;
			break;
			
		case 3:
			theScoreStatus = pending_ScoreStatus;
			break;
			
		case 4:
			theScoreStatus = na_ScoreStatus;
			break;
			
		case 5:
			theScoreStatus = completePending_ScoreStatus;
			break;			
	}

	NSString *theTitle = [def objectForKey:@"title"];
	NSNumber *the_type = [def objectForKey:@"type"];
	enum CourseMapItemType theType = assignment_type;
	switch ([the_type intValue])
	{
		case 1:
			theType = forum_type;
			break;
			
		case 2:
			theType = header_type;
			break;
			
		case 3:
			theType = module_type;
			break;
			
		case 4:
			theType = survey_type;
			break;
			
		case 5:
			theType = syllabus_type;
			break;
			
		case 6:
			theType = test_type;
			break;
			
		case 7:
			theType = topic_type;
			break;

		case 8:
			theType = category_type;
			break;
	}
	
	CourseMapItem *item = [[CourseMapItem alloc] initWithAccessStatus:theAccessStatus allowUntil:theAllowUntil blocked:theBlocked
														  blockedById:theBlockedByMapId blocker:theBlocker count:theCount
														countRequired:theCountRequired due:theDue finished:theFinished
															 complete:theComplete incomplete:theIncomplete
												   itemDisplayStatus1:theDisplayStatus1
												   itemDisplayStatus2:theDisplayStatus2
																mapId:theMapId mapPosition:theMapPosition mastered:theMastered
												masteryLevelQualified:theMasteryLevelQualified masteryLevelScore:theMasteryLevelScore
													 multipleRequired:theMultipleRequired notMasteredAlert:theNotMasteredAlert
																 open:theOpen performStatus:thePerformStatus
													   progressStatus:theProgressStatus points:thePoints
														   providerId:theProviderId requiresMastery:theRequiresMastery
																score:theScore scoreStatus:theScoreStatus title:theTitle type:theType];
	
	return [item autorelease];
}

- (NSDate *) finalDate
{
	if (self.allowUntil != nil) return self.allowUntil;
	return self.due;
}

- (CourseMapItem *)blockedBy
{
	if (self.map == nil) return nil;
	if (self.blockedById == nil) return nil;

	CourseMapItem *rv = [(CourseMap *)self.map itemById:self.blockedById];
	return rv;
}

- (enum CourseMapItemTypeAppCode) typeAppCode
{
	enum CourseMapItemTypeAppCode rv = header_appCode;
	switch (self.type)
	{
		case test_type:
		case assignment_type:
		case survey_type:
			rv = mneme_appCode;
			break;
			
		case module_type:
			rv = melete_appCode;
			break;
			
		case header_type:
			rv = header_appCode;
			break;
			
		case forum_type:
		case topic_type:
		case category_type:
			rv = jforum_appCode;
			break;

		case syllabus_type:
			rv = syllabus_appCode;
			break;
	}
	return rv;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"Item id:%@ title:%@", self.providerId, self.title];
}

- (UIImage *) imageForType
{
	NSString *name = nil;
	NSString *ext = @"png";

	switch (self.type)
	{
		case assignment_type:
			name = @"assignment_type";
			break;
			
		case forum_type:
			name = @"jforum";
			break;

		case module_type:
			name = @"module";
			break;
			
		case survey_type:
			name = @"survey_type";
			break;
			
		case syllabus_type:
			name = @"script";
			break;
			
		case test_type:
			name = @"test_type";
			break;
			
		case topic_type:
			name = @"jforum";
			break;
			
		case category_type:
			name = @"jforum";
			break;
			
		default:
			break;
	}
	
	if (name == nil) return nil;

	UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
	return image;
}

// the text of the type
- (NSString *) textForType
{
	NSString *name = nil;
	
	switch (self.type)
	{
		case assignment_type:
			name = @"assignment";
			break;
			
		case forum_type:
			name = @"forum";
			break;
			
		case module_type:
			name = @"module";
			break;
			
		case survey_type:
			name = @"survey";
			break;
			
		case syllabus_type:
			name = @"syllabus";
			break;
			
		case test_type:
			name = @"test";
			break;
			
		case topic_type:
			name = @"topic";
			break;
			
		case category_type:
			name = @"category";
			break;
			
		default:
			break;
	}
	
	return name;
}

// the progress icon image
- (UIImage *) imageForProgress
{
	// match logic to the progress column in myEtudes's coursemape in list.xml
	NSString *name = nil;
	NSString *ext = @"png";
	
	// <compareDecision model="item.progressStatus" constant="complete" />
	if (self.progressStatus == complete_ProgressStatus)
	{
		name = @"finish";
		ext = @"gif";
	}

	// <compareDecision model="item.progressStatus" constant="missed" />
	else if (self.progressStatus == missed_ProgressStatus)
	{
		name = @"exclamation";
	}

	// this is not in myEtudes / coursemap - but here we add in two states from info: blocked and unavailable
	else if (self.blocked)
	{
		name = @"lock";
	}
	
	else if (self.accessStatus == invalid_accessStatus)
	{
		name = @"warning";
	}

	else if ((self.accessStatus == unpublished_accessStatus) || (self.accessStatus == published_not_yet_open_accessStatus) ||
			 (self.accessStatus == published_hidden_accessStatus) || (self.accessStatus == published_closed_accessStatus))
	{
		if (self.accessStatus == published_hidden_accessStatus)
		{
			name = @"invisible";
		}
		else
		{
			name = @"cancel";
			ext = @"gif";
		}
	}

	// <compareDecision model="item.progressStatus" constant="belowMastery" />
	else if (self.progressStatus == belowMastery_ProgressStatus)
	{
		name = @"not-mastered";
	}
	
	// <compareDecision model="item.progressStatus" constant="belowCount" />
	else if (self.progressStatus == belowCount_ProgressStatus)
	{
		name = @"status_away";
	}

	// <compareDecision model="item.progressStatus" constant="inProgress" />
	else if (self.progressStatus == inProgress_ProgressStatus)
	{
		name = @"status_away";
	}

	if (name == nil) return nil;

	UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
	return image;
}

// the count display text
- (NSString *) countText
{
	NSString *fmt = @"-";
	switch (self.type)
	{
		case assignment_type:
		case survey_type:
		case test_type:
			if (self.count == 1)
			{
				fmt = @"%d submission";
			}
			else if (self.count > 1)
			{
				fmt = @"%d submissions";
			}
			break;
			
		case forum_type:
		case topic_type:
		case category_type:
			if (self.count == 1)
			{
				fmt = @"%d post";
			}
			else if (self.count > 1)
			{
				fmt = @"%d posts";
			}
			break;
			
		case module_type:
			if (self.count == 1)
			{
				fmt = @"%d section";
			}
			else if (self.count > 1)
			{
				fmt = @"%d sections";
			}
			break;
			
		case syllabus_type:
			if (self.count > 0)
			{
				fmt = @"%d";
			}
			break;

		case header_type:
			break;
	}

	NSString * rv = [NSString stringWithFormat:fmt, self.count];
	return rv;
}

// the score display text
- (NSString *) scoreText
{	
	NSString *fmt = nil;
	switch (self.scoreStatus)
	{
		case complete_ScoreStatus:
		case completePending_ScoreStatus:
			fmt = @"%@";
			break;
			
		case none_ScoreStatus:
			fmt = @"-";
			break;

		case partial_ScoreStatus:
			fmt = @"%@ (partial)";
			break;

		case pending_ScoreStatus:
			fmt = @"ungraded";
			break;
			
		case na_ScoreStatus:
			fmt = @"n/a";
			break;
	}

	NSString * rv = [NSString stringWithFormat:fmt, [FloatFormat formatFloat:self.score]];
	return rv;
}

// the status text for this displayStatus
- (NSString *)statusTextForDisplayStatus:(enum CourseMapItemDisplayStatus) info
{
	// matches the alert text from myEtudes coursemap, in list.xml - with some help from AM's student.xml
	NSString *rv = nil;
	
	switch (info)
	{
		case na_cmids:
			break;
			
		case willOpenOn_cmids:
		{
			if (self.open == nil)
			{
				rv = @"Will open later";
			}
			else
			{
				rv = [NSString stringWithFormat:@"Will open %@", [self.open stringInEtudesFormat]];
			}
			break;
		}

		case finishedOn_cmids:
		{
			rv = [NSString stringWithFormat:@"Finished %@", [self.finished stringInEtudesFormat]];
			break;
		}

		case firstDoThisPrereq_cmids:
		{
			if (self.blockedBy.type == syllabus_type)
			{
				rv = @"First, Read and Accept the Syllabus";
			}
			else
			{
				rv = [NSString stringWithFormat: @"First, complete prerequisite %@: %@", [self.blockedBy textForType], self.blockedBy.title];
			}
			break;
		}

		case available_cmids:
		{
			rv = @"Available";
			break;
		}

		case completeWithSections_cmids:
		{
			rv = [NSString stringWithFormat: @"Complete by reading all %d sections", self.countRequired];
			break;
		}

		case completeWithPosts_cmids:
		{
			NSString *plural = @"s";
			if (self.countRequired == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Complete with at least %d post%@", self.countRequired, plural];
			break;
		}

		case completeWithScore_cmids:
		{
			NSString *plural = @"s";
			if (self.masteryLevelScore == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Complete with at least %@ point%@", [FloatFormat formatFloat:self.masteryLevelScore], plural];
			break;
		}	

		case completeByDate_cmids:
		{
			rv = [NSString stringWithFormat:@"Complete by %@", [self.due stringInEtudesFormat]];
			break;
		}

		case inProgress_cmids:
		{
			rv = @"In progress";
			break;
		}

		case inProgressWithSections_cmids:
		{
			NSString *plural = @"s";
			if (self.count == 1) plural = @"";
			rv = [NSString stringWithFormat: @"In progress with %d section%@ read", self.count, plural];
			break;
		}

		case inProgressWithPosts_cmids:
		{
			NSString *plural = @"s";
			if (self.count == 1) plural = @"";
			rv = [NSString stringWithFormat: @"In progress with %d post%@", self.count, plural];
			break;
		}

		case scoredBelowPoints_cmids:
		{
			NSString *plural = @"s";
			if (self.score == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Scored below mastery with %@ point%@", [FloatFormat formatFloat:self.score], plural];
			break;
		}

		case scoredBelowPointsUngraded_cmids:
		{
			NSString *plural = @"s";
			if (self.score == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Scored below mastery with %@ point%@ (some work has not been graded)",
				  [FloatFormat formatFloat:self.score], plural];
			break;
		}

		case notGraded_cmids:
		{
			rv = @"Not yet graded";
			break;
		}

		case scoredPointsMax_cmids:
		{
			NSString *plural = @"s";
			if (self.points == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Scored %@ out of %@ point%@", [FloatFormat formatFloat:self.score],
				  [FloatFormat formatFloat:self.points], plural];
			break;
		}

		case closedOn_cmids:
		{
			// don't show the as of date if it is missing or in the future
			if ((self.finalDate == nil) || ([(NSDate *)[NSDate date] compare:self.finalDate] == NSOrderedAscending))
			{
				rv = @"Closed";
			}
			else
			{
				rv = [NSString stringWithFormat:@"Closed as of %@", [self.finalDate stringInEtudesFormat]];
			}
			break;
		}

		case progressWithSections_cmids:
		{
			NSString *plural = @"s";
			if (self.countRequired == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Read %d of %d section%@", self.count, self.countRequired, plural];
			break;
		}

		case progressWithPosts_cmids:
		{
			if (self.countRequired == 0)
			{
				NSString *plural = @"s";
				if (self.count == 1) plural = @"";
				rv = [NSString stringWithFormat: @"Submitted %d post%@", self.count, plural];
			}
			else
			{
				NSString *plural = @"s";
				if (self.countRequired == 1) plural = @"";
				rv = [NSString stringWithFormat: @"Submitted %d of %d post%@", self.count, self.countRequired, plural];
			}
			break;
		}

		case archived_cmids:
		{
			rv = @"Archived";
			break;
		}

		case invalid_cmids:
		{
			rv = @"Invalid";
			break;
		}

		case unpublished_cmids:
		{
			rv = @"Unpublished";
			break;
		}

		case firstDoThisMasteryPrereq_cmids:
		{
			NSString *plural = @"s";
			if (self.blockedBy.masteryLevelScore == 1) plural = @"";
			rv = [NSString stringWithFormat:
				  @"First, score at least %@ point%@ on prerequisite %@: %@",
				  [FloatFormat formatFloat:self.blockedBy.masteryLevelScore], plural, [self.blockedBy textForType], self.blockedBy.title];
			break;
		}

		case firstDoThisMasteryUngradedPrereq_cmids:
		{
			NSString *plural = @"s";
			if (self.blockedBy.masteryLevelScore == 1) plural = @"";
			rv = [NSString stringWithFormat:
				  @"First, score at least %@ point%@ on prerequisite %@: %@ (some work has not been graded)",
				  [FloatFormat formatFloat:self.blockedBy.masteryLevelScore], plural, [self.blockedBy textForType], self.blockedBy.title];
			break;
		}

		case firstDoThisPostsPrereq_cmids:
		{
			NSString *plural = @"s";
			if (self.blockedBy.countRequired == 1) plural = @"";
			rv = [NSString stringWithFormat:
				  @"First, submit at least %d post%@ to prerequisite %@: %@",
				  self.blockedBy.countRequired, plural, [self.blockedBy textForType], self.blockedBy.title];
			break;
		}

		case firstDoThisSectionsPrereq_cmids:
		{
			NSString *plural = @"s";
			if (self.blockedBy.countRequired == 1) plural = @"";
			rv = [NSString stringWithFormat:
				  @"First, read all %d section%@ in prerequisite %@: %@",
				  self.blockedBy.countRequired, plural, [self.blockedBy textForType], self.blockedBy.title];
			break;
		}
			
		case noPostsRequired_cmids:
		{
			rv = @"No minimum number of posts required";
			break;
		}
			
		case submittedPosts_cmids:
		{
			NSString *plural = @"s";
			if (self.count == 1) plural = @"";
			rv = [NSString stringWithFormat:@"Submitted %d post%@", self.count, plural];
			break;
		}

		case scoredPointsPartialMax_cmids:
		{
			NSString *plural = @"s";
			if (self.points == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Scored %@ (partial) out of %@ point%@", [FloatFormat formatFloat:self.score],
				  [FloatFormat formatFloat:self.points], plural];
			break;
		}

		case inProgressWithPostsReq_cmids:
		{
			NSString *plural = @"s";
			if (self.count == 1) plural = @"";
			rv = [NSString stringWithFormat: @"In progress with %d post%@ (%d required)", self.count, plural, self.countRequired];
			break;
		}

		case inProgressWithPostsNoMin_cmids:
		{
			NSString *plural = @"s";
			if (self.count == 1) plural = @"";
			rv = [NSString stringWithFormat: @"Submitted %d post%@ (no minimum required)", self.count, plural];
			break;
		}
	}

	return rv;
}

// the status text
- (NSString *)statusText
{
	return [self statusTextForDisplayStatus:self.itemDisplayStatus1];
}

// the status text 2
- (NSString *)statusText2
{
	return [self statusTextForDisplayStatus:self.itemDisplayStatus2];
}

- (UIColor *)statusTextColorForDisplayStatus:(enum CourseMapItemDisplayStatus) info
{
	UIColor *rv = [UIColor darkGrayColor];
	switch (info)
	{
		case finishedOn_cmids:
		case inProgress_cmids:
		case inProgressWithSections_cmids:
		case inProgressWithPosts_cmids:
		case inProgressWithPostsReq_cmids:
		case inProgressWithPostsNoMin_cmids:
		case submittedPosts_cmids:
			rv = [UIColor colorEtudesGreen];
			break;

		case archived_cmids:
		case invalid_cmids:
		case unpublished_cmids:
		case closedOn_cmids:
			rv = [UIColor colorEtudesRed];
			break;
			
		case firstDoThisPrereq_cmids:
		case firstDoThisMasteryPrereq_cmids:
		case firstDoThisMasteryUngradedPrereq_cmids:
		case firstDoThisPostsPrereq_cmids:
		case firstDoThisSectionsPrereq_cmids:
		case scoredBelowPoints_cmids:
		case scoredBelowPointsUngraded_cmids:
			rv = [UIColor colorEtudesAlert];
			break;

		default:
			break;
	}
	
	return rv;
}

// the text color for the status text
- (UIColor *)statusTextColor
{
	return [self statusTextColorForDisplayStatus:self.itemDisplayStatus1];
}

// the text color for the status text 2
- (UIColor *)statusTextColor2
{
	return [self statusTextColorForDisplayStatus:self.itemDisplayStatus2];
}

// the numeric topic id for topic items
- (NSString *)topicId
{
	if (self.type != topic_type) return nil;
	// these say "TOPIC-nnn" - we just want the "nnn"
	return [self.providerId  substringFromIndex:6];
}

// the numeric forum id for forum items
- (NSString *)forumId
{
	if (self.type != forum_type) return nil;
	// these say "FORUM-nnn" - we just want the "nnn"
	return [self.providerId  substringFromIndex:6];
}

// the numeric category id for category items
- (NSString *)categoryId
{
	if (self.type != category_type) return nil;
	// these say "CAT-nnn" - we just want the "nnn"
	return [self.providerId  substringFromIndex:4];
}

// if we are in AM and dealing with a survey, we don't show activity
- (BOOL) hideActivityInAM:(BOOL)inAM
{
	// if not int AM, no hiding
	if (!inAM) return NO;
	
	// if item is not a survey, no hiding
	if (self.type != survey_type) return NO;
	
	// hide!
	return YES;
}

@end
