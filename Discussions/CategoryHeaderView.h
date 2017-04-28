/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/CategoryHeaderView.h $
 * $Id: CategoryHeaderView.h 2618 2012-02-07 00:13:04Z ggolden $
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


@interface CategoryHeaderView : UIView
{
@protected
    IBOutlet UILabel *title;
	IBOutlet UILabel *dates;
	IBOutlet UIImageView *publishedHiddenIcon;
	IBOutlet UIImageView *blockedIcon;
}

+ (CategoryHeaderView *) categoryHeaderView;

// set the title
- (void) setCategoryTitle:(NSString *)title;

// set published / hidden
- (void) setPublishedHidden:(BOOL)pubHidden;

// set blocked
- (void) setBlocked:(BOOL)blocked;

// set the dates - make sure to set with nil if the dates are nil
// Note:  call last, after setting publishedHidden and blocked
- (void) setCategoryDatesWithOpen:(NSDate *)openDate due:(NSDate *)dueDate;

@end
