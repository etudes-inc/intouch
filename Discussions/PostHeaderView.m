/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/PostHeaderView.m $
 * $Id: PostHeaderView.m 2680 2012-02-22 03:37:24Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011 Etudes, Inc.
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

#import "PostHeaderView.h"
#import "DateFormat.h"

@interface PostHeaderView()

@property (nonatomic, retain) IBOutlet UILabel *authorLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet UIImageView *revisedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *replyIcon;
@property (nonatomic, retain) IBOutlet UIImageView *editIcon;
@property (nonatomic, retain) IBOutlet UIImageView *deleteIcon;
@property (nonatomic, retain) IBOutlet UIImageView *instructorIcon;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *busy;
@property (nonatomic, retain) Post *post;

// set the author
- (void) setAuthor:(NSString *)author;

// set the date (original date, revised date)
- (void) setDate:(NSDate *)date revised:(NSDate *)revised;

// set the subject
- (void) setSubject:(NSString *)subject;

// set the instructor icon
- (void) setAsInstructor;

@end

@implementation PostHeaderView

@synthesize authorLabel, dateLabel, subjectLabel, avatarImage, revisedIcon, replyIcon, editIcon, deleteIcon, instructorIcon, busy;
@synthesize post;

+ (PostHeaderView *) postHeaderView:(Post *)post
{
	PostHeaderView *rv = nil;
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PostHeaderView" owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[PostHeaderView class]])
		{
			rv = (PostHeaderView *) obj;
			rv.post = post;
			
			[rv.busy stopAnimating];
			[rv setAuthor:post.from];
			[rv setSubject:post.subject];
			[rv setDate:post.date revised:post.revised];
			if (post.fromInstructor)
			{
				[rv setAsInstructor];
			}

			break;
		}
	}

	return rv;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
	[authorLabel release];
	[dateLabel release];
	[subjectLabel release];
	[avatarImage release];
	[revisedIcon release];
	[replyIcon release];
	[editIcon release];
	[deleteIcon release];
	[instructorIcon release];
	[busy release];
	[post release];

    [super dealloc];
}

// set the author
- (void) setAuthor:(NSString *)author
{
	self.authorLabel.text = author;
}

// set the date (original date, revised date)
- (void) setDate:(NSDate *)date revised:(NSDate *)revised
{
	if (revised != nil)
	{
		self.dateLabel.text = [revised stringInEtudesFormat];
		self.revisedIcon.hidden = NO;
	}
	else
	{
		self.dateLabel.text = [date stringInEtudesFormat];
	}
}

// set the subject
- (void) setSubject:(NSString *)subject
{
	self.subjectLabel.text = subject;
}

// set the action for touching the avatar or name
- (void) setAvatarTouchTarget:(id)target action:(SEL)action
{
	UIGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self.avatarImage addGestureRecognizer:avatarTap];
	[avatarTap release];

	avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self.authorLabel addGestureRecognizer:avatarTap];
	[avatarTap release];
}

// set the image for the avatar
- (void) setAvatar:(UIImage *)image
{
	self.avatarImage.image = image;
}

// set the action for and enable the the reply icon
- (void) setReplyTouchTarget:(id)target action:(SEL)action
{
	if (target != nil)
	{
		self.replyIcon.hidden = NO;

		UIGestureRecognizer *replyTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
		[self.replyIcon addGestureRecognizer:replyTap];
		[replyTap release];
	}
}

// set the instructor icon
- (void) setAsInstructor
{
	self.instructorIcon.hidden = NO;
}

// set the action for and enable editing
- (void) setEditTouchTarget:(id)target action:(SEL)action
{
	if (target != nil)
	{
		self.editIcon.hidden = NO;
		
		UIGestureRecognizer *replyTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
		[self.editIcon addGestureRecognizer:replyTap];
		[replyTap release];
	}
}

// set the action for and enable delete
- (void) setDeleteTouchTarget:(id)target action:(SEL)action
{
	if (target != nil)
	{
		self.deleteIcon.hidden = NO;
		
		UIGestureRecognizer *replyTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
		[self.deleteIcon addGestureRecognizer:replyTap];
		[replyTap release];
	}
}

@end
