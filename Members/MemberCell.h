/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/MemberCell.h $
 * $Id: MemberCell.h 2614 2012-02-04 03:07:33Z ggolden $
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
#import "Member.h"

@interface MemberCell : UITableViewCell
{
   	IBOutlet UILabel *nameLabel;
	IBOutlet UIImageView *statusIcon;
	IBOutlet UIImageView *sitePresenceIcon;
	IBOutlet UIImageView *chatPresenceIcon;
	CGRect nibNameLabelFrame;
	CGRect nibStatusIconFrame;
}

+ (MemberCell *) memberCellInTable:(UITableView *)table;

- (void) setName:(NSString *)name;

- (void) setStatus:(enum ParticipantStatus)status;

- (void) setPresenceSite:(BOOL)sitePresence chat:(BOOL)chatPresence;

@end
