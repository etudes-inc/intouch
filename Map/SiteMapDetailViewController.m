/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Map/SiteMapDetailViewController.m $
 * $Id: SiteMapDetailViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "SiteMapDetailViewController.h"
#import "NavBarTitle.h"
#import "DateFormat.h"

@interface SiteMapDetailViewController()

@property (nonatomic, retain) Site *site;

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) CourseMapItem *item;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL inAm;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *iconImage;
@property (nonatomic, retain) IBOutlet UIImageView *progressImage;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *status2Label;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) CGRect statusFrame;
@property (nonatomic, assign) CGRect status2Frame;
@property (nonatomic, assign) CGRect tableFrame;
@property (nonatomic, assign) CGRect progressFrame;

@end

@implementation SiteMapDetailViewController

@synthesize site, delegates, item, items, inAm;
@synthesize scrollView, iconImage, progressImage, titleLabel,statusLabel, status2Label, tableView;
@synthesize titleFrame, statusFrame, status2Frame, tableFrame, progressFrame;

// The designated initializer.  
- (id)initWithSite:(Site *)theSite delegates:(id <Delegates>)theDelegates courseMapItem:(CourseMapItem *)theItem
		  fromList:(NSArray *)theList inAM:(BOOL)theInAM
{
    self = [super init];
    if (self)
	{
		self.site = theSite;
		self.delegates = theDelegates;

		self.item = theItem;
		self.items = theList;
		self.inAm = theInAM;

		self.title = @"Item Details";
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];

		// next and prev
		NSUInteger pos = [self.items indexOfObject:self.item];
		
		UIImage *up = [UIImage imageNamed:@"up.png"];
		UIImage *down = [UIImage imageNamed:@"down.png"];
		UISegmentedControl *nextPrevControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:up, down, nil]];
		
		[nextPrevControl addTarget:self action:@selector(nextPrev:) forControlEvents:UIControlEventValueChanged];
		nextPrevControl.momentary = YES;
		nextPrevControl.segmentedControlStyle = UISegmentedControlStyleBar;
		[nextPrevControl setEnabled:NO forSegmentAtIndex:0];
		[nextPrevControl setEnabled:NO forSegmentAtIndex:1];
		if (pos > 0)
		{
			[nextPrevControl setEnabled:YES forSegmentAtIndex:0];
		}
		if (pos < [self.items count]-1)
		{
			[nextPrevControl setEnabled:YES forSegmentAtIndex:1];			
		}
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:nextPrevControl];
		[nextPrevControl release];
		self.navigationItem.rightBarButtonItem = button;
		[button release];
	}
	
    return self;
}

- (void) setupTitle:(NSString *)text
{
	// how many lines will the description render in?
	CGSize theSize = [text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, FLT_MAX)
									lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.titleLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y,
											  self.titleLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.titleLabel.numberOfLines = lines;
		
		// move status and the list down to make room
		[self.statusLabel setFrame:CGRectMake(self.statusLabel.frame.origin.x, self.statusLabel.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
										self.statusLabel.frame.size.width, self.statusLabel.frame.size.height)];
		[self.progressImage setFrame:CGRectMake(self.progressImage.frame.origin.x, self.progressImage.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.progressImage.frame.size.width, self.progressImage.frame.size.height)];
		[self.status2Label setFrame:CGRectMake(self.status2Label.frame.origin.x, self.status2Label.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.status2Label.frame.size.width, self.status2Label.frame.size.height)];
		[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
											  self.tableView.frame.size.width, self.tableView.frame.size.height)];

		// increase the scroll content
		self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
												 self.scrollView.contentSize.height + (self.titleLabel.font.lineHeight * (lines-1)));
	}
	
	self.titleLabel.text = text;
}

- (void) setupStatus:(NSString *)text color:(UIColor *)color
{
	// how many lines will the description render in?
	CGSize theSize = [text sizeWithFont:self.statusLabel.font constrainedToSize:CGSizeMake(self.statusLabel.frame.size.width, FLT_MAX)
						  lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.statusLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.statusLabel setFrame:CGRectMake(self.statusLabel.frame.origin.x, self.statusLabel.frame.origin.y,
											 self.statusLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.statusLabel.numberOfLines = lines;
		
		[self.progressImage setFrame:CGRectMake(self.progressImage.frame.origin.x,
												self.progressImage.frame.origin.y + ((self.statusLabel.font.lineHeight * (lines-1)) / 2),
												self.progressImage.frame.size.width, self.progressImage.frame.size.height)];
		[self.status2Label setFrame:CGRectMake(self.status2Label.frame.origin.x, self.status2Label.frame.origin.y + (self.statusLabel.font.lineHeight * (lines-1)),
											   self.status2Label.frame.size.width, self.status2Label.frame.size.height)];
		[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (self.statusLabel.font.lineHeight * (lines-1)),
											self.tableView.frame.size.width, self.tableView.frame.size.height)];
		
		// increase the scroll content
		self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
												 self.scrollView.contentSize.height + (self.statusLabel.font.lineHeight * (lines-1)));
	}
	
	self.statusLabel.text = text;
	self.statusLabel.textColor = color;
}

- (void) setupStatus2:(NSString *)text color:(UIColor *)color
{
	if (text == nil)
	{
		self.status2Label.hidden = YES;
		
		[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y - (self.status2Label.frame.size.height),
											self.tableView.frame.size.width, self.tableView.frame.size.height)];
	}
	else
	{
		// how many lines will the description render in?
		CGSize theSize = [text sizeWithFont:self.status2Label.font constrainedToSize:CGSizeMake(self.status2Label.frame.size.width, FLT_MAX)
							  lineBreakMode:NSLineBreakByWordWrapping];
		int lines = theSize.height / self.status2Label.font.lineHeight;
		
		// the layout is set for one line - adjust if needed
		if (lines > 1)
		{
			// make the frame larger
			[self.status2Label setFrame:CGRectMake(self.status2Label.frame.origin.x, self.status2Label.frame.origin.y,
												   self.status2Label.frame.size.width, theSize.height)];
			
			// set the number of lines
			self.status2Label.numberOfLines = lines;
			
			[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (self.status2Label.font.lineHeight * (lines-1)),
												self.tableView.frame.size.width, self.tableView.frame.size.height)];
			
			// increase the scroll content
			self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
													 self.scrollView.contentSize.height + (self.status2Label.font.lineHeight * (lines-1)));
		}
		
		self.status2Label.text = text;
		self.status2Label.textColor = color;
	}
}

- (void) setup
{
	[self setupTitle:self.item.title];
	
	if ([self.item hideActivityInAM:self.inAm])
	{
		// no progress icon
		self.progressImage.image = nil;
		
		// either available or closed
		enum CourseMapItemDisplayStatus status = available_cmids;
		if ((self.item.itemDisplayStatus1 == closedOn_cmids) || (self.item.itemDisplayStatus2 == closedOn_cmids))
		{
			status = closedOn_cmids;
		}
		[self setupStatus:[self.item statusTextForDisplayStatus:status] color:[self.item statusTextColorForDisplayStatus:status]];
		[self setupStatus2:nil color:nil];
	}
	else
	{
		[self setupStatus:[self.item statusText] color:[self.item statusTextColor]];
		[self setupStatus2:[self.item statusText2] color:[self.item statusTextColor2]];
		self.progressImage.image = [self.item imageForProgress]; // TODO: hide if nil
	}
	self.iconImage.image = [self.item imageForType];
	
	// set the content size of the scroll
	// table is 2 headers and footers (10), and 5 cells (44) = 260	
	int tableHeight = 260;
	[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,
										self.tableView.frame.size.width, tableHeight)];
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.tableView.frame.origin.y + tableHeight);

	// cause the table to refresh
	[self.tableView reloadData];
}

- (void)dealloc
{
	[site release];
	[item release];
	[items release];
	[scrollView release];
	[iconImage release];
	[progressImage release];
	[titleLabel release];
	[statusLabel release];
	[status2Label release];
	[tableView release];	
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.

	// record some sizes to restore
	self.titleFrame = self.titleLabel.frame;
	self.statusFrame = self.statusLabel.frame;
	self.status2Frame = self.status2Label.frame;
	self.tableFrame = self.tableView.frame;
	self.progressFrame = self.progressImage.frame;

	[self setup];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

// TODO:

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) return 2;
	return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cellv1";
	
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	}

	if (indexPath.section == 0)
	{
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Open";
			cell.detailTextLabel.text = [NSDate stringInEtudesFormatOrDash:self.item.open];
		}
		else
		{
			cell.textLabel.text = @"Due";
			cell.detailTextLabel.text = [NSDate stringInEtudesFormatOrDash:self.item.due];
		}
	}

	else
	{
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Activity";
			if ([self.item hideActivityInAM:self.inAm])
			{
				cell.detailTextLabel.text = @"n/a";
			}
			else
			{
				cell.detailTextLabel.text = [NSDate stringInEtudesFormatOrDash:self.item.finished];
			}
		}
		else if (indexPath.row == 1)
		{
			cell.textLabel.text = @"Count";
			if ([self.item hideActivityInAM:self.inAm])
			{
				cell.detailTextLabel.text = @"n/a";
			}
			else
			{
				cell.detailTextLabel.text = [self.item countText];
			}
		}
		else
		{
			cell.textLabel.text = @"Score";
			cell.detailTextLabel.text = [self.item scoreText];
		}
	}

	return cell;
}

#pragma mark - Actions

// respond to the next/prev control
- (IBAction) nextPrev:(id)control
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *) control;
	NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
	
	// which message position
	NSUInteger pos = [self.items indexOfObject:self.item];
	if (pos == NSNotFound) return;
	
	// prev
	if (selectedSegment == 0)
	{
		// prev message
		if (pos > 0)
		{
			pos--;
		}
	}
	
	else
	{
		// next message
		if (pos < [self.items count]-1)
		{
			pos++;
		}
	}
	
	// reset with the new item
	self.item = [self.items objectAtIndex:pos];
	
	// restore the frames to load conditions
	[self.titleLabel setFrame:self.titleFrame];
	[self.statusLabel setFrame:self.statusFrame];
	[self.status2Label setFrame:self.status2Frame];
	self.status2Label.hidden = NO;
	[self.tableView setFrame:self.tableFrame];
	[self.progressImage setFrame:self.progressFrame];

	[self setup];
	
	// reset enabled for the controls
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	if (pos > 0)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	}
	if (pos < [self.items count] -1)
	{
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}

@end
