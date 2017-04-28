/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Modules/ModuleViewController.m $
 * $Id: ModuleViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "ModuleViewController.h"
#import "NavBarTitle.h"
#import "SectionCell.h"
#import "Section.h"
#import "SectionViewController.h"

@interface ModuleViewController()

@property (nonatomic, retain) NSString *moduleId;
@property (nonatomic, retain) UIBarButtonItem *refresh;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIView *titleBkg;
@property (nonatomic, retain) UIView *titleSeparator;
@property (nonatomic, retain) UITableView *sectionsTable;
@property (nonatomic, retain) Module *module;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) CGRect sectionsFrame;

@end

@implementation ModuleViewController

@synthesize moduleId, refresh, updated, updatedDate, updatedTime, titleLabel, titleBkg, titleSeparator, sectionsTable, module, titleFrame, sectionsFrame;

#pragma mark - View lifecycle

// The designated initializer.  
- (id)initWitSite:(Site *)theSite delegates:(id <Delegates>)theDelegates moduleId:(NSString *)theModuleId
{
    self = [super initAsNavWithSite:theSite delegates:theDelegates title:@"Module"];
    if (self)
	{
		self.moduleId = theModuleId;
	}
	
    return self;
}

- (void)dealloc
{
	[moduleId release];
	[refresh release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[titleLabel release];
	[titleBkg release];
	[titleSeparator release];
	[sectionsTable release];
	[module release];

    [super dealloc];
}

- (void) adjustView
{
	self.titleFrame = self.titleLabel.frame;
	self.sectionsFrame = self.sectionsTable.frame;
}

- (void) reset
{
	self.titleLabel.frame = self.titleFrame;
	self.titleLabel.numberOfLines = 1;
	self.sectionsTable.frame = self.sectionsFrame;
}

- (SectionCell *) cellForIndexPath:(NSIndexPath *)indexPath
{
	Section *section = [self.module.sections objectAtIndex:indexPath.row];

	SectionCell *cell = [SectionCell sectionCellInTable:self.sectionsTable];
	[cell setTitle:section.title];
	[cell setViewed:section.viewed];

	return cell;
}

- (void) setModuleTitle:(NSString *)title
{
	self.titleLabel.text = title;
	
	// how many lines will the title render in?
	CGSize theSize = [title sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.bounds.size.width, FLT_MAX)
						   lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.titleLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.titleLabel.numberOfLines = lines;
		
		// the bkg and separator
		[self.titleBkg setFrame:CGRectMake(self.titleBkg.frame.origin.x, self.titleBkg.frame.origin.y,
										   self.titleBkg.frame.size.width,
										   self.titleBkg.frame.size.height + (self.titleLabel.font.lineHeight * (lines-1)))];
		[self.titleSeparator setFrame:CGRectMake(self.titleSeparator.frame.origin.x,
												 self.titleSeparator.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
												 self.titleSeparator.frame.size.width,
												 self.titleSeparator.frame.size.height)];
		
		// move the table down to make room
		[self.sectionsTable setFrame:CGRectMake(self.sectionsTable.frame.origin.x,
												self.sectionsTable.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
												self.sectionsTable.frame.size.width,
												self.sectionsTable.frame.size.height - + (self.titleLabel.font.lineHeight * (lines-1)))];		
	}
}

- (void) refreshView
{
	[self reset];

	// title
	[self setModuleTitle:self.module.title];

	// cause the table to refresh
	[self.sectionsTable reloadData];
}

- (void) loadInfo
{
	[super loadInfo];

	// the completion block - when the module is loaded
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// save the Module
		self.module = [results objectForKey:@"module"];
		
		[self.busy stopAnimating];
		self.refresh.enabled = YES;
		
		self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
		self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
		self.updated.hidden = NO;
		self.updatedDate.hidden = NO;
		self.updatedTime.hidden = NO;
		
		[self refreshView];
	};

	// clear the refresh fields
	self.refresh.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";
	
	// get the Module
	[self.busy startAnimating];
	[[self.delegates sessionDelegate ].session getModuleForSite:self.site moduleId:self.moduleId completion:completion];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:animated];
	[self.sectionsTable flashScrollIndicators];
}

#pragma mark - Table view delegate

// match SectionCell.xib
#define HEIGHT 60
#define TITLE_FONT systemFontOfSize
#define TITLE_FONT_SIZE 17
#define TITLE_WIDTH 255
#define VIEWED_LABEL_HEIGHT 14

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat adjust = 0;
	
	Section *section = [self.module.sections objectAtIndex:indexPath.row];
	
	// title
	UIFont *font = [UIFont TITLE_FONT:TITLE_FONT_SIZE];
	CGSize theSize = [section.title sizeWithFont:font constrainedToSize:CGSizeMake(TITLE_WIDTH, FLT_MAX)
								   lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / font.lineHeight;
	adjust += (font.lineHeight * (lines-1));
	
	// hide the viewed lable?
	if (section.viewed == nil)
	{
		adjust -= VIEWED_LABEL_HEIGHT;
	}

	CGFloat rv = HEIGHT + adjust;
	
	// SectionCell *sc = [self cellForIndexPath:indexPath];
	// if (sc.frame.size.height != rv) NSLog(@"sc mismatch path: %@   view height: %f   computed height: %f", indexPath, sc.frame.size.height, rv);
	
	return rv;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Section *section = [self.module.sections objectAtIndex:indexPath.row];
	SectionViewController *svc = [[SectionViewController alloc] initWitSite:self.site delegates:self.delegates module:module section:section];
	[self.navigationController pushViewController:svc animated:YES];
	[svc release];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.module.sections count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SectionCell *cell = [self cellForIndexPath:indexPath];
	return cell;
}

#pragma mark - Actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

@end
