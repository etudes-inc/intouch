/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Messages/MessagesCellView.h $
 * $Id: MessagesCellView.h 2640 2012-02-11 21:11:30Z ggolden $
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


@interface MessagesCellView : UITableViewCell
{
@protected
    IBOutlet UILabel *subjectLabel;
    IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *fromLabel;
	IBOutlet UIImageView *unreadImage;
	IBOutlet UIImageView *repliedImage;
	CGRect nibSubjectLabelFrame;
	CGRect nibDateLabelFrame;
	CGRect nibFromLabelFrame;
	CGRect nibFrame;
}

+ (MessagesCellView	*) messagesCellViewInTable:(UITableView *)table;

- (void) setSubject:(NSString *)subject;

- (void) setDate:(NSDate *)date;

- (void) setPreviewText:(NSString *)text;

- (void) setUnread:(BOOL)unread replied:(BOOL)replied;

- (void) setFrom:(NSString *)from;

@end
