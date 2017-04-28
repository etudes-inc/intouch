/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/StringHtml.h $
 * $Id: StringHtml.h 2351 2011-12-14 17:50:35Z ggolden $
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

@interface NSString (StringHtml)

// return the string with BBCode syntax converted into html as needed.
- (NSString *) stringHtmlFromBbCode;

// return the string with plain text characters and BBCode syntax converted into html as needed.
- (NSString *) stringHtmlFromPlain;

// return the string with [quote] syntax rendered into html.
- (NSString *) stringHtmlFromQuote;

// return the string with any html formatting "rendered" into plain (with BBCode) text.  Some formatting may be lost.
- (NSString *) stringPlainFromHtml;

@end
