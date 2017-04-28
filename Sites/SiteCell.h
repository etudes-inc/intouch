/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Sites/SiteCell.h $
 * $Id: SiteCell.h 2634 2012-02-10 01:37:16Z ggolden $
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

@interface SiteCell : UITableViewCell
{
    IBOutlet UILabel *siteTitleLabel;
	IBOutlet UILabel *numOnlineLabel;
	IBOutlet UIImageView *onLineIcon;
	IBOutlet UILabel *numMissedLabel;
	IBOutlet UIImageView *missedIcon;
	IBOutlet UILabel *numMessagesLabel;
	IBOutlet UIImageView *messagesIcon;
	IBOutlet UILabel *numPostsLabel;
	IBOutlet UIImageView *postsIcon;
	CGRect nibFrame;
}

+ (SiteCell *) siteCellInTable:(UITableView *)table;

- (void) setSiteTitle:(NSString *)title;

// the number of users online now
- (void) setNumOnlineUsers:(int)count;

// the number of users not visited in the last period
- (void) setNumAlertUsers:(int)count;

// number of unread messages
- (void) setNumUnreadMessages:(int)count;

// if there are unread posts
- (void) setUnreadPosts:(BOOL)unread;

@end
