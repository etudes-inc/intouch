/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapCellView.h $
 * $Id: SiteMapCellView.h 2621 2012-02-07 19:56:26Z ggolden $
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

@interface SiteMapCellView : UITableViewCell
{
@protected
	IBOutlet UIImageView *iconImage;
	IBOutlet UIImageView *progressImage;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *status2Label;
	CGRect nibTitleLabelFrame;
	CGRect nibStatusLabelFrame;
	CGRect nibStatus2LabelFrame;
	CGRect nibFrame;
}

+ (SiteMapCellView *) siteMapCellViewInTable:(UITableView *)table;

- (void) setIcon:(UIImage *)image;

- (void) setProgress:(UIImage *)image;

- (void) setTitle:(NSString *)title;

- (void) setStatus:(NSString *)status color:(UIColor *)color;

- (void) setStatus2:(NSString *)status color:(UIColor *)color;

// set that the item is hidden from students
- (void) setHidden;

// set that the item is active
- (void) setActive;

@end
