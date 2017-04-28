/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Activity/SiteActivityCell.m $
 * $Id: SiteActivityCell.m 2624 2012-02-07 23:28:15Z ggolden $
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

#import "SiteActivityCell.h"
#import "DateFormat.h"
#import "EtudesColors.h"

@interface SiteActivityCell()

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *statusIcon;
@property (nonatomic, retain) IBOutlet UILabel *lastVisitLabel;
@property (nonatomic, retain) IBOutlet UIImageView *syllabusAcceptedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *meleteCountIcon;
@property (nonatomic, retain) IBOutlet UIImageView *mnemeCountIcon;
@property (nonatomic, retain) IBOutlet UIImageView *jforumCountIcon;
@property (nonatomic, retain) IBOutlet UIImageView *visitCountIcon;
@property (nonatomic, retain) IBOutlet UILabel *syllabusAcceptedLabel;
@property (nonatomic, retain) IBOutlet UILabel *meleteCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *mnemeCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *jforumCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *visitCountLabel;

@end

@implementation SiteActivityCell

@synthesize nameLabel, statusIcon, lastVisitLabel;
@synthesize syllabusAcceptedIcon, meleteCountIcon, mnemeCountIcon, jforumCountIcon, visitCountIcon;
@synthesize syllabusAcceptedLabel, meleteCountLabel, mnemeCountLabel, jforumCountLabel, visitCountLabel;

+ (SiteActivityCell *) siteActivityCellInTable:(UITableView *)table
{
	static NSString *SiteActivityCellId = @"SiteActivityCell";

	SiteActivityCell *cell = [table dequeueReusableCellWithIdentifier:SiteActivityCellId];
	if (cell != nil)
	{
		// restore to nib conditions
	}

	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:SiteActivityCellId owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[SiteActivityCell class]])
		{
			cell = (SiteActivityCell *) obj;
			
			// record nib conditions

			break;
		}
	}
	
	return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
	[nameLabel release];
	[statusIcon release];
	[lastVisitLabel release];
	[syllabusAcceptedIcon release];
	[meleteCountIcon release];
	[mnemeCountIcon	release];
	[jforumCountIcon release];
	[visitCountIcon release];
	[syllabusAcceptedLabel release];
	[meleteCountLabel release];
	[mnemeCountLabel release];
	[jforumCountLabel release];
	[visitCountLabel release];

    [super dealloc];
}

- (void) setName:(NSString *)name
{
	self.nameLabel.text = name;
}

- (void) setStatus:(enum ParticipantStatus)status
{
	// match logic to the progress column in myEtudes's coursemape in list.xml
	NSString *name = nil;
	NSString *ext = @"png";
	
	switch (status)
	{
		case enrolled_participantStatus:
			name = @"user_enrolled";
			break;
			
		case dropped_participantStatus:
			name = @"user_dropped";
			self.nameLabel.textColor = [UIColor colorEtudesRed];
			break;

		case blocked_participantStatus:
			name = @"user_blocked";
			self.nameLabel.textColor = [UIColor colorEtudesRed];
			break;

		case hat_participantStatus:
			name = @"user_suit";
			self.nameLabel.textColor = [UIColor colorEtudesRed];
			break;
	}

	UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
	self.statusIcon.image = image;
}

- (void) setLastVisit:(NSDate *)lastVisit notVisitedAlert:(BOOL)notVisitedAlert
{
	if (lastVisit == nil)
	{
		self.lastVisitLabel.text = @"never visited";
	}
	else
	{
		self.lastVisitLabel.text = [NSDate stringInEtudesFormatOrDash:lastVisit];
	}

	if (notVisitedAlert)
	{
		self.lastVisitLabel.textColor = [UIColor colorEtudesRed];
	}
}

- (void) setSyllabusAccepted:(NSDate *)when;
{
	if (when != nil)
	{
		self.syllabusAcceptedLabel.text = [NSDate stringInEtudesFormatOrDash:when];
	}
	else
	{
		self.syllabusAcceptedLabel.text = @"not accepted";
	}
}

- (void) setMeleteCount:(int)count
{
	if (count > 0)
	{
		self.meleteCountLabel.text = [NSString stringWithFormat:@"%d", count];
	}
	else
	{
		self.meleteCountLabel.text = @"-";
	}
}

- (void) setMnemeCount:(int)count
{
	if (count > 0)
	{
		self.mnemeCountLabel.text = [NSString stringWithFormat:@"%d", count];
	}
	else
	{
		self.mnemeCountLabel.text = @"-";
	}
}

- (void) setJforumCount:(int)count
{
	if (count > 0)
	{
		self.jforumCountLabel.text = [NSString stringWithFormat:@"%d", count];
	}
	else
	{
		self.jforumCountLabel.text = @"-";
	}
}

- (void) setVisitCount:(int)count
{
	if (count > 0)
	{
		self.visitCountLabel.text = [NSString stringWithFormat:@"(%d visits)", count];
	}
	else
	{
		self.visitCountLabel.text = @"";
	}
}

@end
