/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/TopicCellView.h $
 * $Id: TopicCellView.h 2619 2012-02-07 02:09:39Z ggolden $
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
#import "BadgeView.h"
#import "Topic.h"

@interface TopicCellView : UITableViewCell
{
@protected
    IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *datesLabel;
	IBOutlet BadgeView *postsBadge;
	IBOutlet UIImageView *unreadIcon;
	IBOutlet UIImageView *stickyIcon;
	IBOutlet UIImageView *announceIcon;
	IBOutlet UIImageView *reuseIcon;
	IBOutlet UIImageView *readOnlyIcon;
	IBOutlet UIImageView *publishedHiddenIcon;
	IBOutlet UIImageView *unpublishedIcon;
	IBOutlet UIImageView *blockedIcon;
    CGRect nibTitleLabelFrame;
	CGRect nibAuthorLabel;
	CGRect nibDatesLabel;
	CGRect nibStickyIcon;
	CGRect nibAnnounceIcon;
	CGRect nibReuseIcon;
	CGRect nibReadOnlyIcon;
	CGRect nibPublishedHiddenIcon;
	CGRect nibUnpublishedIcon;
	CGRect nibFrame;
}

// create a new cell
+ (TopicCellView *) topicCellViewInTable:(UITableView *)table;

// set the title
- (void) setTitle:(NSString *)title;

// set the author
- (void) setAuthor:(NSString *)author;

// set the dates - make sure to set with nil if the dates are nil
- (void) setTopicDatesWithOpen:(NSDate *)openDate due:(NSDate *)dueDate;

// set unread
- (void) setUnreadIndicator:(BOOL)unread;

// set the number of posts in the topic
- (void) setNumPosts:(int)numPosts;

// based on the type and readOnly ..., select the proper type icon
- (void) setTopicType:(enum TopicType)type readOnly:(BOOL)readOnly publishedHidden:(BOOL)pubHidden unpublished:(BOOL)unpublished;

// set blocked
- (void) setBlocked:(BOOL)blocked;

@end
