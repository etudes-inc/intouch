/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Discussions/TopicViewController.m $
 * $Id: TopicViewController.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "TopicViewController.h"
#import "Topic.h"
#import "NavBarTitle.h"
#import "PostCellView.h"
#import "PostHeaderView.h"
#import "SiteViewController.h"
#import "PostViewController.h"
#import "StringRe.h"
#import "StringHtml.h"
#import "MemberViewController.h"
#import "BrowserViewController.h"

@interface TopicViewController()

@property (nonatomic, retain) Site *site;

@property (nonatomic, assign) id <Delegates> delegates;
@property (nonatomic, assign) id <DataLoader> loader;
@property (nonatomic, retain) UITableView *list;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIBarButtonItem *replyButton;
@property (nonatomic, retain) UILabel *updated;
@property (nonatomic, retain) UILabel *updatedDate;
@property (nonatomic, retain) UILabel *updatedTime;
@property (nonatomic, retain) UIToolbar	*toolbar;
@property (nonatomic, retain) Topic *topic;
@property (nonatomic, retain) NSString *topicId;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, retain) NSMutableDictionary /* <NSString (avatar file id) -> UIImage> */ *avatars;
@property (nonatomic, retain) NSArray *cells;
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSDate *lastReload;
@property (nonatomic, assign) NSTimeInterval autoReloadThreshold;
@property (nonatomic, retain) NSArray *fullToolbarItems;
@property (nonatomic, retain) Post *selectedPost;

@end

@implementation TopicViewController

@synthesize site;
@synthesize delegates, loader;
@synthesize list, refreshButton, replyButton, updated, updatedDate, updatedTime, toolbar;
@synthesize topic, topicId;
@synthesize busy;
@synthesize avatars;
@synthesize cells, headers;
@synthesize lastReload, autoReloadThreshold;
@synthesize fullToolbarItems, selectedPost;

// The designated initializer.  
- (id)initWithTopic:(Topic *)theTopic site:(Site *)st delegates:(id <Delegates>)d loader:(id <DataLoader>)l
{
    self = [super init];
    if (self)
	{
		self.autoReloadThreshold = 60;
		self.lastReload = nil;

		self.topic = theTopic;
		self.delegates = d;
		self.loader = l;
		
		if (self.topic.posts != nil)
		{
			self.lastReload = self.topic.postsLoaded;
		}

		self.site = st;
		self.title = @"Posts";

		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];

		// cache of avatars
		self.avatars = [NSMutableDictionary	dictionaryWithCapacity:10];
	}
	
    return self;
}

// Init with just the topic id to load  
- (id)initWithTopicId:(NSString *)theTopicId site:(Site *)st delegates:(id <Delegates>)d loader:(id <DataLoader>)l
{
    self = [super init];
    if (self)
	{
		self.autoReloadThreshold = 60;
		self.lastReload = nil;
		
		self.topicId = theTopicId;
		self.delegates = d;
		self.loader = l;

		self.site = st;
		self.title = @"Posts";
		
		// the nav bar title
		NavBarTitle *nbt = [[NavBarTitle alloc] initWithSiteTitle:self.site.title title:self.title];
		self.navigationItem.titleView = nbt;
		[nbt release];
		
		// cache of avatars
		self.avatars = [NSMutableDictionary	dictionaryWithCapacity:10];
	}
	
    return self;
}

- (BOOL) mayReply
{
	// forum type must be regularForum or replyOnlyForum: readOnlyForum cannot have replies, nor can one that is past due-locked
	// topic must not be read only
	// instructors can always reply
	if (self.site.instructorPrivileges) return YES;
	return ((!self.topic.forumReadOnly) && (!self.topic.readOnly) && (!self.topic.pastDueLocked));
}

- (BOOL) mayDeletePost:(Post *)post
{
	// instructors may delete posts
	return self.site.instructorPrivileges;
}

- (void) imageForAvatar:(NSString *)avatar completion:(completion_block_i) block
{
	// NSLog(@"loading avatar: %@", avatar);
	
	// if we have it, process it now
	UIImage *imageNow = (UIImage *) [self.avatars objectForKey:avatar];
	if (imageNow != nil)
	{
		block(imageNow);
	}
	
	// otherwise get it, save it, process it
	else
	{
		completion_block_i blockCopy = [block copy];
		
		completion_block_i completion = ^(UIImage * image)
		{
			if (image != nil)
			{
				[self.avatars setObject:image forKey:avatar];
			}

			blockCopy(image);
		};

		[[self.delegates sessionDelegate ].session loadAvatarImage:avatar completion:completion];
		
		[blockCopy release];
	}
}

-(void) loadHeadersAndCells
{
	// NSDate *start = [NSDate date];

	// make a header and cell for each post
	NSMutableArray /* <PostHeaderView> */ *newHeaders = [[NSMutableArray alloc] initWithCapacity:[self.topic.posts count]];
	NSMutableArray /* <PostCellView> */ *newCells = [[NSMutableArray alloc] initWithCapacity:[self.topic.posts count]];
	
	// first pass to get all the headers and cells made - no avatars
	for (Post *post in self.topic.posts)
	{
		// header
		PostHeaderView *rv = [PostHeaderView postHeaderView:post];
		[newHeaders addObject:rv];
		
		// init the view
		if ([self mayReply])
		{
			[rv setReplyTouchTarget:self action:@selector(replyToPost:)];
		}
		[rv setAvatarTouchTarget:self action:@selector(avatarWasTapped:)];

		// if may edit ...
		if (post.mayEdit)
		{
			[rv setEditTouchTarget:self action:@selector(editPost:)];
		}

		// if may delete
		if ([self mayDeletePost:post])
		{
			[rv setDeleteTouchTarget:self action:@selector(deletePost:)];
		}

		// cell
		PostCellView *cell = [PostCellView postCellView];
		[newCells addObject:cell];
		
		cell.body.delegate = self;
		
		/* if we need to do processing here...
		dispatch_queue_t editPrepQueue = dispatch_queue_create("displayPrepQueue", NULL);
		dispatch_async(editPrepQueue, ^
					   {
						   // render [quote] and any BBCode syntax in the body html into pure html
						   NSString *processedBody = [[post.body stringHtmlFromQuote] stringHtmlFromBbCode];
						   
						   dispatch_async(dispatch_get_main_queue(), ^
										  {
											  // start loading the body - it will callback when completed (see webViewDidFinsihLoad:)
											  NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
											  [cell.body loadHTMLString:processedBody baseURL:baseUrl];
										  });
					   });
		
		dispatch_release(editPrepQueue);
		*/

		NSURL *baseUrl = [[self.delegates sessionDelegate] session].serverUrl;
		[cell.body loadHTMLString:post.body baseURL:baseUrl];
	}

	// now we have a header per post, load the avatars
	for (int pi = 0; pi < [self.topic.posts count]; pi++)
	{
		Post *post = [self.topic.posts objectAtIndex:pi];
		PostHeaderView *rv = [newHeaders objectAtIndex:pi];

		// for when the avatar image is loaded
		completion_block_i completion = ^(UIImage * image)
		{
			[rv.busy stopAnimating];

			if (image != nil)
			{
				// set this image into any header that uses this avatar
				for (int i = 0; i < [self.topic.posts count]; i++)
				{
					Post *p = [self.topic.posts objectAtIndex:i];
					if ([p.avatar isEqualToString:post.avatar])
					{
						PostHeaderView *phv = [newHeaders objectAtIndex:i];
						[phv setAvatar:image];
					}
				}
			}
		};
		
		// see if we need to load an avatar image
		if (post.avatar != nil)
		{
			// load the avatar only if the same has not already been loaded by a prior post
			BOOL alreadyLoaded = NO;
			for (Post *prior in self.topic.posts)
			{
				// if we get to me, we are done looking
				if (prior == post) break;
				
				if ([post.avatar isEqualToString:prior.avatar])
				{
					alreadyLoaded = YES;
					break;
				}
			}
			
			// if we need the avatar, load it
			if (!alreadyLoaded)
			{
				[rv.busy startAnimating];
				[self imageForAvatar:post.avatar completion:completion];
			}
		}
	}
	
	// switch to the new
	self.cells = newCells;
	self.headers = newHeaders;

	[newCells release];
	[newHeaders release];
	
	// NSDate *methodFinish = [NSDate date];
	// NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
	// NSLog(@"loadHeadersAndCells: %f", executionTime);
}

-(void) reloadListAfterFullyLoaded
{
	// if we have created all the views
	if ([self.cells count] == [self.topic.posts count])
	{
		// if all the views have a body height >1
		for (PostCellView *view in self.cells)
		{
			if (view.body.frame.size.height == 1)
			{
				return;
			}
		}
		
		// set the cell heights for the new body heights
		for (PostCellView *view in self.cells)
		{
			// they layout is for a body height of 1
			[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height + (view.body.frame.size.height - 1))];
		}

		// we are ready now to reload the table
		[self.list reloadData];

		// scroll to the bottom
		if ([self.topic.posts count] > 0)
		{
			NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:[self.topic.posts count] -1];
			[self.list scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
		}
	}
}

- (void) refreshView
{
	// pre-load the topics cells
	[self loadHeadersAndCells];

	self.updatedDate.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
	self.updatedTime.text = [NSDateFormatter localizedStringFromDate:self.lastReload dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
	self.updated.hidden = NO;
	self.updatedDate.hidden = NO;
	self.updatedTime.hidden = NO;

	// hide the compose button if the user does not have permission to reply
	[self.toolbar setItems:self.fullToolbarItems];
	if (![self mayReply])
	{
		NSArray *newItems = [NSArray arrayWithObjects:[self.toolbar.items objectAtIndex:0], nil];
		[self.toolbar setItems:newItems];
	}

	[self.list deselectRowAtIndexPath:[self.list indexPathForSelectedRow] animated:YES];
	[self.list flashScrollIndicators];
}

- (void) loadInfo
{
	self.lastReload = [NSDate date];
	
	// the completion block - when the posts are loaded
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		Topic *updatedTopic = [results objectForKey:@"topic"];
		Forum *updatedForum = [results objectForKey:@"forum"];

		// if we have a topic or forum, update them with the new info
		if (self.topic != nil)
		{
			if (self.topic.forum != nil)
			{
				[self.topic.forum setToMatch:updatedForum];
			}
			[self.topic setToMatch:updatedTopic];
		}

		// otherwise just keep the new topic
		else
		{
			self.topic = updatedTopic;
		}

		// save the posts
		self.topic.posts = [results objectForKey:@"posts"];
		
		// mark the topic (locally) as read
		[self.topic markAsRead];
		
		[self.busy stopAnimating];
		self.refreshButton.enabled = YES;
		self.replyButton.enabled =YES;
		
		[self refreshView];		
	};
	
	NSString *theId = self.topicId;
	if (self.topic != nil) theId = self.topic.topicId;

	self.refreshButton.enabled = NO;
	self.replyButton.enabled = NO;
	self.updated.hidden = YES;
	self.updatedDate.hidden = YES;
	self.updatedTime.hidden = YES;
	self.updatedDate.text = @"";
	self.updatedTime.text = @"";
	[self.busy startAnimating];
	[[self.delegates sessionDelegate].session getPosts:theId site:self.site completion:completion];
}

- (void) loadIfNeeded
{
	BOOL willReload = NO;
	
	// load if we have not loaded yet
	if (self.lastReload == nil) willReload = YES;
	
	// load if we have a threshold and are past it since last reload
	if ((self.autoReloadThreshold > 0) && (self.lastReload != nil) && (([self.lastReload timeIntervalSinceNow] * -1) > self.autoReloadThreshold))
		willReload = YES;
	
	// if we have no data
	if ((self.topic == nil) || (self.topic.posts == nil)) willReload = YES;
	
	// reload if needed
	if (willReload)
	{
		[self loadInfo];
	}
	
	// if we have our data, just get it on the screen
	else
	{
		[self refreshView];
	}
}

- (void)dealloc
{
	[site release];
	[list release];
	[refreshButton release];
	[replyButton release];
	[updated release];
	[updatedDate release];
	[updatedTime release];
	[toolbar release];
	[topic release];
	[topicId release];
	[busy release];
	[avatars release];
	[cells release];
	[headers release];
	[lastReload release];
	[fullToolbarItems release];
	[selectedPost release];

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

	[self.busy stopAnimating];

    // Do any additional setup after loading the view from its nib.
	self.fullToolbarItems = self.toolbar.items;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self loadIfNeeded];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// process a delete
- (void) processDelete:(Post *)post
{
	// delete from Etudes
	completion_block_sd whenDeleted = ^(enum resultStatus status, NSDictionary *def)
	{
		if (status == success)
		{
			NSMutableArray *newMessages = [NSMutableArray arrayWithArray:self.topic.posts];
			[newMessages removeObject:post];
			self.topic.posts = newMessages;
			
			// if no posts left, return
			if ([self.topic.posts count] == 0)
			{
				// tell the loader that its data may be dirty because of the delete
				[self.loader reloadDataWhenPossible];
				[self.navigationController popViewControllerAnimated:YES];
			}
			
			else
			{
				// refresh to show the deleted message
				[self refreshView];
			}
		}
	};
	[[self.delegates sessionDelegate].session deletePostForSite:self.site postId:post.postId completion:whenDeleted];		
}

// edit the post
- (void) processEdit:(Post *)post
{
	// on send - body is plain text
	completion_block_ss completion = ^(NSString *subject, NSString *body)
	{
		// NSLog(@"sending subject:%@ body:%@", subject, body);
		completion_block_s whenPosted = ^(enum resultStatus status)
		{
			// NSLog(@"post complete: status:%d", status);
			
			// refresh to show the new post TODO: only if successful?
			[self refresh:nil];
		};
		
		[[self.delegates sessionDelegate].session sendEditToPost:post.postId site:self.site subject:subject
															body:body completion:whenPosted plainText:YES];		
	};
	
	// create the send message view controller
	PostViewController *pvc = [[PostViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion editPost:post];
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:pvc animated:NO];
	[pvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// TODO:
	// get the forum
	// go there
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	// use the size of the pre-made header
	PostHeaderView * view = [self.headers objectAtIndex:section];
	return view.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// get one of our pre-made headers
	PostHeaderView * view = [self.headers objectAtIndex:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PostCellView *view = [self.cells objectAtIndex:indexPath.section];
	return view.frame.size.height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.headers count];	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PostCellView *cell = [self.cells objectAtIndex:indexPath.section];
	return cell;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// Note: webView height must be small, like 1, before loading content, else the original hight will be reported for shorter content
	CGRect frame = webView.frame;
	frame.size.height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height;"] intValue];
	BOOL needsScrolling = NO;
	
	webView.frame = frame;

	// if we don't need scrolling, disable that and bouncing
	if (!needsScrolling)
	{
		for(UIView *v in webView.subviews)
		{
			if([v isKindOfClass:[UIScrollView class]])
			{
				UIScrollView *sv = (UIScrollView*) v;
				sv.scrollEnabled = NO;
				sv.bounces = NO;
			}
		}
	}
	
	[self reloadListAfterFullyLoaded];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// NSLog(@"type:%d request:%@\n", navigationType, request);

	if (navigationType == UIWebViewNavigationTypeOther) return YES;
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		// internal
		NSString * urlStr = [[request URL] absoluteString];
		BrowserViewController *bvc = [[BrowserViewController alloc] initWitSite:self.site delegates:self.delegates url:urlStr];	
		[self.navigationController pushViewController:bvc animated:YES];
		[bvc release];
	}

	return NO;
}

#pragma mark - Actions

// refresh
- (IBAction)refresh:(id)sender
{
	[self loadInfo];
}

// add a new topic to the forum
- (IBAction)replyToTopic:(id)sender
{
	// on send - the body is in plain text
	completion_block_ss completion = ^(NSString *subject, NSString *body)
	{
		// NSLog(@"sending post: subject:%@ body:%@", subject, body);
		completion_block_s whenPosted = ^(enum resultStatus status)
		{
			// NSLog(@"post complete: status:%d", status);
			
			// refresh to show the new post TODO: only if successful?
			[self refresh:nil];
		};
		[[self.delegates sessionDelegate].session sendPostToTopic:self.topic site:self.site subject:subject body:body completion:whenPosted plainText:YES];		
	};

	// create the send message view controller
	PostViewController *pvc = [[PostViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion replyToTopic:self.topic];

	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:pvc animated:NO];
	[pvc release];

	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// respond to a tap on the avatar
- (IBAction) avatarWasTapped:(UIGestureRecognizer *)sender 
{
	PostHeaderView *phv = (PostHeaderView *) sender.view.superview;
	
	MemberViewController *mvc = [[MemberViewController alloc] initWithMemberId:phv.post.fromUserId site:self.site delegates:self.delegates];
	[self.navigationController pushViewController:mvc animated:YES];
	[mvc release];
}

// respond to a tap on the reply
- (IBAction) replyToPost:(UIGestureRecognizer *)sender 
{
	PostHeaderView *phv = (PostHeaderView *) sender.view.superview;

	// on send - body is plain text
	completion_block_ss completion = ^(NSString *subject, NSString *body)
	{
		// NSLog(@"sending subject:%@ body:%@", subject, body);
		completion_block_s whenPosted = ^(enum resultStatus status)
		{
			// NSLog(@"post complete: status:%d", status);
			
			// refresh to show the new post TODO: only if successful?
			[self refresh:nil];
		};

		[[self.delegates sessionDelegate].session sendReplyToPost:phv.post.postId topic:self.topic
															 site:self.site subject:subject body:body completion:whenPosted plainText:YES];		
	};

	// create the send message view controller
	PostViewController *pvc = [[PostViewController alloc] initWithSite:self.site delegates:self.delegates whenDone:completion replyToPost:phv.post];

	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:pvc animated:NO];
	[pvc release];
	
	// present the controllers modally
	[self presentViewController:nav animated:YES completion:nil];
	[nav release];
}

// edit the item - confirm first
- (IBAction) editPost:(UIGestureRecognizer *)sender
{
	// setup the post for if the delete is confirmed
	PostHeaderView *phv = (PostHeaderView *) sender.view.superview;
	self.selectedPost = phv.post;

	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Some formatting may be lost.  Do you want to edit this post?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:nil 
											   otherButtonTitles:@"Edit", nil];
	action.tag = 1;
	[action showFromToolbar:self.toolbar];
	[action release];
}

// delete the post (confirm)
- (IBAction) deletePost:(UIGestureRecognizer *)sender
{
	// setup the post for if the delete is confirmed
	PostHeaderView *phv = (PostHeaderView *) sender.view.superview;
	self.selectedPost = phv.post;

	// confirm
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete this post?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:@"Delete" 
											   otherButtonTitles:nil];
	action.tag = 2;
	[action showFromToolbar:self.toolbar];
	[action release];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// index 0 is confirmation
	if (buttonIndex == 0)
	{
		
		// tag 1 confirms edit
		if (actionSheet.tag == 1)
		{
			[self processEdit:self.selectedPost];
		}	
		
		// tag 2 confirms delete
		else if (actionSheet.tag == 2)
		{
			[self processDelete:self.selectedPost];
		}
	}

	self.selectedPost = nil;
}

@end
