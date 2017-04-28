/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Syllabus/SyllabusViewController.h $
 * $Id: SyllabusViewController.h 2424 2011-12-28 22:32:18Z ggolden $
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
#import "Delegates.h"

@interface SyllabusViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
@protected
	id <Delegates> delegates;
	Site *site;
	NSString *loadingUrl;
	BOOL loading;
	BOOL accepted;

	IBOutlet UIWebView *bodyView;
	IBOutlet UIActivityIndicatorView *busy;  
}

// The designated initializer.  
- (id)initWitSite:(Site *)site delegates:(id <Delegates>)delegates accepted:(BOOL)accepted;

// reply to an actions touch
- (IBAction) doActions:(id)sender;

@end
