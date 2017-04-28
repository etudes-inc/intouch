/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Members/MemberCell.m $
 * $Id: MemberCell.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "MemberCell.h"

@interface MemberCell()

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *statusIcon;
@property (nonatomic, retain) IBOutlet IBOutlet UIImageView *sitePresenceIcon;
@property (nonatomic, retain) IBOutlet IBOutlet UIImageView *chatPresenceIcon;
@property (nonatomic, assign) CGRect nibNameLabelFrame;
@property (nonatomic, assign) CGRect nibStatusIconFrame;

@end

@implementation MemberCell

@synthesize nameLabel, statusIcon, sitePresenceIcon, chatPresenceIcon, nibNameLabelFrame, nibStatusIconFrame;

+ (MemberCell *) memberCellInTable:(UITableView *)table;
{
	MemberCell *cell = [table dequeueReusableCellWithIdentifier:@"MemberCell"];
	if (cell != nil)
	{
		// restore to nib conditions
		cell.statusIcon.hidden = YES;
		cell.sitePresenceIcon.hidden = YES;
		cell.chatPresenceIcon.hidden = YES;
		cell.nameLabel.frame = cell.nibNameLabelFrame;
		cell.statusIcon.frame = cell.nibStatusIconFrame;
		return cell;	
	}
	
	NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed: @"MemberCell" owner:nil options:nil];		
	for (id obj in nibObjects)
	{
		if([obj isKindOfClass:[MemberCell class]])
		{
			cell = (MemberCell *) obj;
			
			// record the initial nib conditions
			cell.nibNameLabelFrame = cell.nameLabel.frame;
			cell.nibStatusIconFrame = cell.statusIcon.frame;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[nameLabel release];
	[statusIcon release];
	[sitePresenceIcon release];
	[chatPresenceIcon release];
	
    [super dealloc];
}

- (void) setName:(NSString *)name
{
	self.nameLabel.text = name;
	
/*
	// how many lines will the name render in?
	CGSize theSize = [name sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(self.nameLabel.bounds.size.width, FLT_MAX)
						  lineBreakMode:NSLineBreakByWordWrapping];
	int lines = theSize.height / self.nameLabel.font.lineHeight;
	
	// the layout is set for one line - adjust if needed
	if (lines > 1)
	{
		// make the frame larger
		[self.nameLabel setFrame:CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, theSize.height)];
		
		// set the number of lines
		self.nameLabel.numberOfLines = lines;

		// increase our frame
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y,
								  self.frame.size.width, self.frame.size.height + (self.nameLabel.font.lineHeight * (lines-1)))];
		
		// re-center the status icon
		[self.statusIcon setFrame:CGRectMake(self.statusIcon.frame.origin.x, (self.frame.size.height / 2) - (self.statusIcon.frame.size.height / 2),
											 self.statusIcon.frame.size.width, self.statusIcon.frame.size.height)];
	}
*/
}

- (void) setStatus:(enum ParticipantStatus)status
{
	if (status == hat_participantStatus)
	{
		self.statusIcon.hidden = NO;
		
		// shift the name to make room
		[self.nameLabel setFrame:CGRectMake(self.nameLabel.frame.origin.x + self.statusIcon.frame.size.width,
											self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width - self.statusIcon.frame.size.width,
											self.nameLabel.frame.size.height)];
	}
}

- (void) setPresenceSite:(BOOL)sitePresence chat:(BOOL)chatPresence
{
	self.sitePresenceIcon.hidden = !sitePresence;
	self.chatPresenceIcon.hidden = !chatPresence;

	if (sitePresence || chatPresence)
	{
		// shift the name and status to make room
		[self.nameLabel setFrame:CGRectMake(self.nameLabel.frame.origin.x + self.sitePresenceIcon.frame.size.width,
											self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width - self.sitePresenceIcon.frame.size.width,
											self.nameLabel.frame.size.height)];
		[self.statusIcon setFrame:CGRectMake(self.statusIcon.frame.origin.x + self.sitePresenceIcon.frame.size.width,
											self.statusIcon.frame.origin.y, self.statusIcon.frame.size.width - self.sitePresenceIcon.frame.size.width,
											self.statusIcon.frame.size.height)];
	}
}

@end
