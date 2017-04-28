/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Modules/SectionViewController.h $
 * $Id: SectionViewController.h 2418 2011-12-28 16:53:55Z ggolden $
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
#import "Module.h"
#import "Section.h"

@interface SectionViewController : UIViewController <UIWebViewDelegate>
{
@protected
	id <Delegates> delegates;
	Site *site;
	NSString *loadingUrl;
	BOOL loading;
	Module *module;
	Section *section;

	IBOutlet UILabel *moduleTitleLabel;
	IBOutlet UILabel *sectionTitleLabel;
	IBOutlet UIWebView *bodyView;
	IBOutlet UIActivityIndicatorView *busy;  
}

// The designated initializer.  
- (id)initWitSite:(Site *)site delegates:(id <Delegates>)delegates module:(Module *)theModule section:(Section *)theSection;

@end
