/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Chat/ChatBodyCell.h $
 * $Id: ChatBodyCell.h 2701 2012-02-28 00:40:16Z ggolden $
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
#import "ETMessage.h"

@interface ChatBodyCell : UITableViewCell
{
@protected
	IBOutlet UILabel *bodyLabel;
    IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UIImageView *deleteIcon;
	ETMessage *message;
	id deleteTarget;
	SEL deleteSelector; 
	CGRect nibFrame;
	CGRect nibBodyLabelFrame;
}

+ (ChatBodyCell *) chatBodyCellInTable:(UITableView *)table;

@property (nonatomic, retain) ETMessage *message;

// set the body
- (void) setBody:(NSString *)body;

// set the author
- (void) setAuthor:(NSString *)author color:(UIColor *)color;

// set the date
- (void) setDate:(NSDate *)date;

// set the action for and enable delete
- (void) setDeleteTouchTarget:(id)target action:(SEL)action;

@end
