/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/TopicViewController.h $
 * $Id: TopicViewController.h 2692 2012-02-25 01:57:40Z ggolden $
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
#import "Site.h"
#import "EtudesServerSession.h"
#import "NavDelegate.h"
#import "Forum.h"
#import "Topic.h"
#import "Delegates.h"
#import "Post.h"

@protocol DataLoader

- (void) reloadDataWhenPossible;

@end

@interface TopicViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIActionSheetDelegate>
{
@protected
	Site *site;
	id <Delegates> delegates;
	Topic *topic;
	NSString *topicId;
	id <DataLoader> loader;

	IBOutlet UITableView *list;
	IBOutlet UIBarButtonItem *refreshButton;
	IBOutlet UIBarButtonItem *replyButton;
	IBOutlet UILabel *updated;
	IBOutlet UILabel *updatedDate;
	IBOutlet UILabel *updatedTime;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIActivityIndicatorView *busy;
	NSMutableDictionary /* <NSString (avatar file id) -> UIImage> */ *avatars;
	NSArray /* <PostCellView> */ *cells;
	NSArray /* <PostHeaderView> */ *headers;
	NSDate *lastReload;
	NSTimeInterval autoReloadThreshold;
	NSArray *fullToolbarItems;
	Post *selectedPost;
}

// The designated initializer.  
- (id)initWithTopic:(Topic *)topic site:(Site *)site delegates:(id <Delegates>)delegates loader:(id <DataLoader>)loader;

// Init with just the topic id to load  
- (id)initWithTopicId:(NSString *)topicId site:(Site *)site delegates:(id <Delegates>)delegates loader:(id <DataLoader>)loader;

// refresh
- (IBAction)refresh:(id)sender;

// reply to the topic
- (IBAction)replyToTopic:(id)sender;

// reply to a postt
- (IBAction)replyToPost:(id)sender;

@end
