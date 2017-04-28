/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Shared/PreferencesDelegate.h $
 * $Id: PreferencesDelegate.h 1945 2011-08-24 15:36:48Z ggolden $
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

#import <Foundation/Foundation.h>
#import "Site.h"

@protocol PreferencesDelegate <NSObject>

// the user login eid
- (NSString *) userEid;
- (void) setUserEid:(NSString *)ident;

// the user internal id
- (NSString *) userId;
- (void) setUserId:(NSString *)ident;

// get the preferences password
- (NSString *) password;
- (void) setPassword:(NSString *)pw;

// the user email
- (NSString *) email;
- (void) setEmail:(NSString *)email;

// get the preferences Site (autoreleased)
- (Site *) site;
- (void) setSite:(Site *)site;

@end
