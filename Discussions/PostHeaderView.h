/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/PostHeaderView.h $
 * $Id: PostHeaderView.h 2680 2012-02-22 03:37:24Z ggolden $
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
#import "Post.h"

@interface PostHeaderView : UIView
{
@protected
    IBOutlet UILabel *authorLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *subjectLabel;
	IBOutlet UIImageView *avatarImage;
	IBOutlet UIImageView *revisedIcon;
	IBOutlet UIImageView *replyIcon;
	IBOutlet UIImageView *editIcon;
	IBOutlet UIImageView *deleteIcon;
	IBOutlet UIImageView *instructorIcon;
	IBOutlet UIActivityIndicatorView *busy;
	Post *post;
}

@property (nonatomic, retain, readonly) IBOutlet UIActivityIndicatorView *busy;
@property (nonatomic, retain, readonly) Post *post;

+ (PostHeaderView *) postHeaderView:(Post *)post;

// set the action for touching the avatar
- (void) setAvatarTouchTarget:(id)target action:(SEL)action;

// set the image for the avatar
- (void) setAvatar:(UIImage *)image;

// set the action for and enable the reply icon
- (void) setReplyTouchTarget:(id)target action:(SEL)action;

// set the action for and enable editing
- (void) setEditTouchTarget:(id)target action:(SEL)action;

// set the action for and enable delete
- (void) setDeleteTouchTarget:(id)target action:(SEL)action;

@end
