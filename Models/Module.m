/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Models/Module.m $
 * $Id: Module.m 2383 2011-12-20 02:54:45Z ggolden $
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

#import "Module.h"
#import "Section.h"

@interface Module()

@end

@implementation Module

@synthesize sections, title;

#pragma mark - lifecycle

- (id) initWithSections:(NSArray *)theSections
{
	self = [super init];
	if (self)
	{
		self.sections = theSections;
	}
	
	return self;
}

- (void)dealloc
{
	[sections release];
	
	[super dealloc];
}

+ (Module *) moduleForDef:(NSDictionary *)def
{
	Module *module = [[Module alloc] init];

	// the array of sections
	NSArray *sectionDefs = [def objectForKey:@"sections"];
	
	// build up an array of Sections
	NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:[sectionDefs count]];
	
	for (NSDictionary *sectionDef in sectionDefs)
	{
		Section *section = [Section sectionForDef:sectionDef];
		[sections addObject:section];
	}

	module.sections = sections;
	[sections release];

	// title
	NSString *title = [def objectForKey:@"title"];
	module.title = title;
	
	return [module autorelease];
}

@end
