/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/ForumCellView.h $
 * $Id: ForumCellView.h 2622 2012-02-07 21:46:20Z ggolden $
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
#import "Forum.h"

@interface ForumCellView : UITableViewCell
{
@protected
    IBOutlet UILabel *title;
	IBOutlet UILabel *description;
	IBOutlet UILabel *dates;
	IBOutlet BadgeView *topics;
	IBOutlet UIImageView *unread;
	IBOutlet UIImageView *present;
	IBOutlet UIImageView *publishedHiddenIcon;
	IBOutlet UIImageView *unpublishedIcon;
	IBOutlet UIImageView *blockedIcon;
	IBOutlet UIImageView *replyOnlyIcon;
	IBOutlet UIImageView *readOnlyIcon;
	CGRect nibFrame;
	CGRect nibTitleFrame;
	CGRect nibDescriptionFrame;
	CGRect nibDatesFrame;
	CGRect nibPublishedHiddenIconFrame;
	CGRect nibUnpublishedIconFrame;
	CGRect nibReplyOnlyIconFrame;
	CGRect nibReadOnlyIconFrame;
}

+ (ForumCellView *)forumCellViewInTable:(UITableView *)table;

// set the title
- (void) setForumTitle:(NSString *)title;

// set the description
- (void) setForumDescription:(NSString *)description;

// set the dates - make sure to set with nil if the dates are nil
- (void) setForumDatesWithOpen:(NSDate *)openDate due:(NSDate *)dueDate;

// set and reveal the num topics badge
- (void) setNumTopics:(int)numTopics;

// set unread
- (void) setUnreadIndicator:(BOOL)unread;

// set present (for chat)
- (void) setPresentIndicator:(BOOL)present;

// set the published-hidden, unpublished, read-only and reply-only icons
- (void) setIconsUnPublished:(BOOL)unPublished pubHidden:(BOOL)pubHidden readOnly:(BOOL)readOnly replyOnly:(BOOL)replyOnly;

// set blocked
- (void) setBlocked:(BOOL)blocked;

@end
