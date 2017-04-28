/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Announcements/NewsCell.h $
 * $Id: NewsCell.h 2658 2012-02-15 19:47:51Z ggolden $
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


@interface NewsCell : UITableViewCell
{
    IBOutlet UILabel *subjectLabel;
    IBOutlet UILabel *dateLabel;
	IBOutlet UIImageView *unreadImage;
	IBOutlet UIImageView *draftImage;
	IBOutlet UIImageView *invisibleImage;
	CGRect nibSubjectLabelFrame;
	CGRect nibDateLabelFrame;
	CGRect nibDraftImageFrame;
	CGRect nibInvisibleImageFrame;
	CGRect nibFrame;
	UIColor *nibSubjectLabelTextColor;
	UIColor *nibDateLabelTextColor;
	BOOL prepedForDelete;
}

+ (NewsCell *) newsCellInTable:(UITableView *)table;

- (void) setSubject:(NSString *)subject;

- (void) setDate:(NSDate *)date draft:(BOOL)draft released:(BOOL)released releaseDate:(NSDate *)releaseDate;

- (void) setUnread:(BOOL)unread;

@end
