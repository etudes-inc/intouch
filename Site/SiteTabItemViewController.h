/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Site/SiteTabItemViewController.h $
 * $Id: SiteTabItemViewController.h 2210 2011-11-09 19:20:05Z ggolden $
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

#import <UIKit/UIKit.h>
#import "Site.h"
#import "EtudesServerSession.h"
#import "NavDelegate.h"
#import "Delegates.h"

// Root class for all of the views for the site that are in the site tab items

@interface SiteTabItemViewController : UIViewController <UIActionSheetDelegate>
{
@protected
	Site *site;
	id <Delegates> delegates;
	IBOutlet UIActivityIndicatorView *busy;
	NSDate *lastReload;
	NSTimeInterval autoReloadThreshold;
}

@property (nonatomic, retain) Site *site;
@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) NSDate *lastReload;
@property (nonatomic, assign) NSTimeInterval autoReloadThreshold;

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delgates title:(NSString *)title;

// Init as a nav, not a tab view 
- (id)initAsNavWithSite:(Site *)site delegates:(id <Delegates>)delgates title:(NSString *)title;

// load view's data
- (void) loadInfo;

// get the data into the view
- (void) refreshView;

// adjust the view - one time after load
- (void) adjustView;

@end
