/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Modules/SectionCell.h $
 * $Id: SectionCell.h 2629 2012-02-09 16:52:14Z ggolden $
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

@interface SectionCell : UITableViewCell
{
@protected
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *viewedLabel1;
	IBOutlet UILabel *viewedLabel2;
	IBOutlet UIImageView *unreadImage;
	CGRect nibTitleLabelFrame;
	CGRect nibViewedLabel1Frame;
	CGRect nibViewedLabel2Frame;
	CGRect nibFrame;
}

+ (SectionCell *) sectionCellInTable:(UITableView *)table;

- (void) setTitle:(NSString *)title;

- (void) setViewed:(NSDate *)viewed;

@end
