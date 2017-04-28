/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Assessment/AssessmentViewController.m $
 * $Id: AssessmentViewController.m 11714 2015-09-24 22:36:20Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2012 Etudes, Inc.
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

#import "AssessmentViewController.h"
#import "NavBarTitle.h"
#import "EtudesColors.h"
#import "BrowserViewController.h"

@interface AssessmentViewController()

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, retain) Site *site;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, retain) NSString *assessmentId;
@property (nonatomic, retain) NSString *assessmentTitle;
@property (nonatomic, assign) enum CourseMapItemType assessmentType;

@end

@implementation AssessmentViewController

@synthesize delegates, site, titleLabel, instructionsLabel, assessmentId, assessmentTitle, assessmentType;

// The designated initializer.  
- (id)initWitSite:(Site *)s delegates:(id <Delegates>)d assessmentId:(NSString *)aid assessmentTitle:(NSString *)aTitle
   assessmentType:(enum CourseMapItemType)aType
{
    self = [super init];
    if (self)
	{
		self.delegates = d;
		self.site = s;
		
		self.assessmentId = aid;
		self.assessmentTitle = aTitle;
		self.assessmentType = aType;

		self.title = @"AT&S";

		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
	}

    return self;
}

- (void)dealloc
{
	[site release];
	[titleLabel release];
	[instructionsLabel release];
	[assessmentId release];
	[assessmentTitle release];

    [super dealloc];
}

- (void) adjustView
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) loadDetails
{
	// set the title
	self.titleLabel.text = self.assessmentTitle;
	
	// how many lines will the title render in?
	CGSize theSize = [self.assessmentTitle sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.bounds.size.width, FLT_MAX)
						   lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.titleLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.titleLabel.numberOfLines = lines;
		
		// move the author, dates, icons down to make room
		[self.instructionsLabel setFrame:CGRectMake(self.instructionsLabel.frame.origin.x,
													self.instructionsLabel.frame.origin.y + (self.titleLabel.font.lineHeight * (lines-1)),
													self.instructionsLabel.frame.size.width, self.instructionsLabel.frame.size.height)];
	}
	
	// set the instructions
	NSString *typeStr = @"test";
	if (self.assessmentType == survey_type)
	{
		typeStr = @"survey";
	}
	else if (self.assessmentType == assignment_type)
	{
		typeStr = @"assignment";
	}

	NSString *instructions = [NSString stringWithFormat:@"To access this %@, visit your course site in myEtudes from a supported browser on your computer.",
							  typeStr];
	self.instructionsLabel.text = instructions;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	//[self adjustView];
	[self loadDetails];
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

@end
