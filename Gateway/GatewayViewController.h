/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Gateway/GatewayViewController.h $
 * $Id: GatewayViewController.h 1888 2011-08-02 16:56:19Z ggolden $
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
#import "EtudesServerSession.h"
#import "NavDelegate.h"
#import "Delegates.h"

@interface GatewayViewController : UIViewController <UIWebViewDelegate>
{
@protected
	id <Delegates> delegates;

	IBOutlet UIWebView *motd;
	
	IBOutlet UIActivityIndicatorView *busy;
	BOOL loading;
}

// The designated initializer.  
- (id)initWithDelegates:(id <Delegates>)delegates;

@end
