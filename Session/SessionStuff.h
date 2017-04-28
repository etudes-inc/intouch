/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Session/SessionStuff.h $
 * $Id: SessionStuff.h 2477 2012-01-10 00:11:32Z ggolden $
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

enum resultStatus {success, accessDenied, notLoggedIn, serverUnavailable, oldVersion, badRequest};

// completion block that has just request status
typedef void (^completion_block_s)(enum resultStatus status);

// completion block that has request status and dictionary
typedef void (^completion_block_sd)(enum resultStatus status, NSDictionary *results);

// completion block that has request status and NSArray
typedef void (^completion_block_sa)(enum resultStatus status, NSArray *results);

// completion block that has UIImage
typedef void (^completion_block_i)(UIImage *image);

// completion block that has NSData
typedef void (^completion_block_d)(NSData *image);
