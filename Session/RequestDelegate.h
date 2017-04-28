/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Session/RequestDelegate.h $
 * $Id: RequestDelegate.h 2382 2011-12-20 00:35:18Z ggolden $
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
#import "SessionStuff.h"

@interface RequestDelegate : NSObject
{
@protected
	NSInteger status;
	NSString *type;
	NSMutableData *data;
	completion_block_sd completion_sd;
	completion_block_d completion_d;
	NSURLConnection *connection;
	NSTimer *timer;
}

@property (nonatomic, assign, readonly) NSInteger status;
@property (nonatomic, retain, readonly) NSString *type;

// initializer - send in at most one completion block
- (id) initWithRequest:(NSURLRequest *)request completion:(completion_block_sd)block_sd orRaw:(completion_block_d)block_d;

// cancel the current request
- (void) cancel;

@end
