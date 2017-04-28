/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Assessment/AssessmentViewController.h $
 * $Id: AssessmentViewController.h 2674 2012-02-19 19:30:56Z ggolden $
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
#import "Site.h"
#import "Delegates.h"
#import "CourseMapItem.h"

@interface AssessmentViewController : UIViewController
{
@protected
	id <Delegates> delegates;
	Site *site;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *instructionsLabel;
	NSString *assessmentId;
	NSString *assessmentTitle;
	enum CourseMapItemType assessmentType;
}

// The designated initializer.  
- (id)initWitSite:(Site *)site delegates:(id <Delegates>)delegates assessmentId:(NSString *)aid assessmentTitle:(NSString *)aTitle
   assessmentType:(enum CourseMapItemType)aType;

@end
