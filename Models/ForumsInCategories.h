/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ForumsInCategories.h $
 * $Id: ForumsInCategories.h 2054 2011-10-06 04:29:41Z ggolden $
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

@interface ForumsInCategories : NSObject
{
@protected
	NSArray /* <Category> */ *categories;
	NSDictionary /* <NSString:categoryId, NSArray<Forum>> */ *forumsPerCategory;
}

// alloc and init auto-released based on this array of Forum objects
+ (ForumsInCategories *) forumsInCategoriesWithForums:(NSArray *)forums;

- (id) initWithForums:(NSArray *)forums;

// return the forums for this category id
- (NSArray *) /* <Forum> */ forumsInCategory:(NSString *)categoryId;

// return the categories
@property (nonatomic, retain, readonly) NSArray /* <Category> */ *categories;

@end
