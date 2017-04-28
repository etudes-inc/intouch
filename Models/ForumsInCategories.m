/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/ForumsInCategories.m $
 * $Id: ForumsInCategories.m 2054 2011-10-06 04:29:41Z ggolden $
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

#import "ForumsInCategories.h"
#import "Forum.h"

@interface ForumsInCategories()

@property (nonatomic, retain) NSArray /* <Category> */ *categories;
@property (nonatomic, retain) NSDictionary /* <NSString:categoryId, NSArray<Forum>> */ *forumsPerCategory;

@end

@implementation ForumsInCategories

@synthesize categories, forumsPerCategory;

// alloc and init auto-released based on this array of Forum objects
+ (ForumsInCategories *) forumsInCategoriesWithForums:(NSArray *)forums
{
	ForumsInCategories *rv = [[ForumsInCategories alloc] initWithForums:forums];
	return [rv autorelease];
}

- (id) initWithForums:(NSArray *)forums
{
	self = [super init];
	if (self)
	{
		NSMutableArray *theCategories = [[NSMutableArray alloc] init];
		NSMutableDictionary *theForums = [[NSMutableDictionary alloc] init];

		for (Forum *forum in forums)
		{
			// if we have this category already
			if ([theCategories containsObject:forum.category])
			{
				NSMutableArray *forums = [theForums objectForKey:forum.category];
				[forums addObject:forum];
			}
			
			// if this is the first time we see the category
			else
			{
				NSMutableArray *forums = [NSMutableArray arrayWithObject:forum];
				[theCategories addObject:forum.category];
				[theForums setObject:forums forKey:forum.category];
			}
		}
		
		self.categories = theCategories;
		self.forumsPerCategory = theForums;
		[theCategories release];
		[theForums release];
	}

	return self;
}

-  (void) dealloc
{
	[categories release];
	[forumsPerCategory release];
	
	[super dealloc];
}

// return the forums for this category id
- (NSArray *) /* <Forum> */ forumsInCategory:(NSString *)categoryId
{
	NSArray * rv = [self.forumsPerCategory objectForKey:categoryId];
	return rv;
}

@end
