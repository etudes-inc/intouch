/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Gateway/WelcomeViewController.h $
 * $Id: WelcomeViewController.h 2584 2012-01-30 20:12:08Z ggolden $
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
#import "EtudesServerSession.h"
#import "NavDelegate.h"
#import "Delegates.h"

@interface WelcomeViewController : UIViewController <UITextFieldDelegate>
{
@protected
	id <Delegates> delegates;

	IBOutlet UIScrollView *scroll;
	IBOutlet UITableView *fields;
	IBOutlet UIButton *loginButton;
	IBOutlet UIActivityIndicatorView *busy;
	IBOutlet UILabel *versionLabel;
	IBOutlet UILabel *inst1Label;
	IBOutlet UILabel *inst2Label;

	NSArray /* TextEditCell */ *cells;
	UITextField *loginField;
	UITextField *passwordField;
}

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)delegates;

@end
