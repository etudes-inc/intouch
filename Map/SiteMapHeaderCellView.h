/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapHeaderCellView.h $
 * $Id: SiteMapHeaderCellView.h 2622 2012-02-07 21:46:20Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2012 Etudes, Inc.
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

@interface SiteMapHeaderCellView : UITableViewCell
{
@protected
	IBOutlet UIImageView *iconImage;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIView *bkgView;
	CGRect nibTitleLabelFrame;
	CGRect nibFrame;
}

+ (SiteMapHeaderCellView *) siteMapHeaderCellViewInTable:(UITableView *)table;

- (void) setTitle:(NSString *)title;

@end
