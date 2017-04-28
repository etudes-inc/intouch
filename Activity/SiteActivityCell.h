/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Activity/SiteActivityCell.h $
 * $Id: SiteActivityCell.h 2624 2012-02-07 23:28:15Z ggolden $
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

#import <UIKit/UIKit.h>
#import "ActivityItem.h"

@interface SiteActivityCell : UITableViewCell
{
@protected
	IBOutlet UILabel *nameLabel;
	IBOutlet UIImageView *statusIcon;
	IBOutlet UILabel *lastVisitLabel;
	IBOutlet UIImageView *syllabusAcceptedIcon;
	IBOutlet UIImageView *meleteCountIcon;
	IBOutlet UIImageView *mnemeCountIcon;
	IBOutlet UIImageView *jforumCountIcon;
	IBOutlet UIImageView *visitCountIcon;
	IBOutlet UILabel *syllabusAcceptedLabel;
	IBOutlet UILabel *meleteCountLabel;
	IBOutlet UILabel *mnemeCountLabel;
	IBOutlet UILabel *jforumCountLabel;
	IBOutlet UILabel *visitCountLabel;
}

+ (SiteActivityCell *) siteActivityCellInTable:(UITableView *)table;

- (void) setName:(NSString *)name;

- (void) setStatus:(enum ParticipantStatus)status;

- (void) setLastVisit:(NSDate *)lastVisit notVisitedAlert:(BOOL)notVisitedAlert;

- (void) setSyllabusAccepted:(NSDate *)when;

- (void) setMeleteCount:(int)count;

- (void) setMnemeCount:(int)count;

- (void) setJforumCount:(int)count;

- (void) setVisitCount:(int)count;

@end
