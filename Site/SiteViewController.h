/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Site/SiteViewController.h $
 * $Id: SiteViewController.h 2063 2011-10-09 19:46:00Z ggolden $
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

@interface SiteViewController : UITabBarController
{
@protected
	id <Delegates> delegates;

	Site *site;
}

// The designated initializer.  
- (id)initWithSite:(Site *)site delegates:(id <Delegates>)delegates;

// Select the members tab
- (void) selectMembersTabWithMember:(NSString *)memberId;

@end
