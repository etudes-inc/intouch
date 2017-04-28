/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Session/EtudesServerSession.m $
 * $Id: EtudesServerSession.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "EtudesServerSession.h"
#import "Site.h"
#import "ETMessage.h"
#import "Post.h"
#import	"Category.h"
#import "Forum.h"
#import "Topic.h"
#import "CourseMap.h"
#import "RequestDelegate.h"
#import "ActivityOverview.h"
#import "Module.h"

@interface EtudesServerSession()

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *internalUserId;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSURL *serverUrl;
@property (nonatomic, retain) NSString *serverProtocol;
@property (nonatomic, retain) NSString *serverHost;
@property (nonatomic, assign) NSInteger serverPort;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *build;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) id <PreferencesDelegate> preferencesDelegate;
@property (nonatomic, assign) int networkCount;
@property (nonatomic, retain) NSArray /* <Member> */ *cachedSiteMembers;
@property (nonatomic, retain) NSString *cachedSiteMembersSiteId;
@property (nonatomic, retain) NSString *cachedSiteMembersUserId;

@end

@implementation EtudesServerSession

@synthesize active;
@synthesize userId, password, internalUserId, serverUrl, serverProtocol, serverHost, serverPort, version, build, email;
@synthesize preferencesDelegate;
@synthesize networkCount;
@synthesize cachedSiteMembers, cachedSiteMembersSiteId, cachedSiteMembersUserId;

#define BOUNDARY @"AaB03x"

// the version of the protocol - change anytime a new protocol feature is added
#define CDP_VERSION @"18"

#pragma mark - lifecycle

// construct with the server components
- (id) initWithProtocol:(NSString *)theProtocol host:(NSString *)theHost port:(NSInteger)thePort preferences:(id <PreferencesDelegate>)pd
				version:(NSString *)theVersion build:(NSString *)theBuild
{
	self = [super init];
    if (self)
	{
		self.preferencesDelegate = pd;
		
		// not yet logged in / active
		self.active = NO;
		
		self.serverProtocol = theProtocol;
		self.serverHost = theHost;
		self.serverPort = thePort;
		self.version = theVersion;
		self.build = theBuild;

		// skip the port if the port is standard
		BOOL skipPort = false;
		if (([self.serverProtocol isEqualToString:@"http"]) && (self.serverPort == 80)) skipPort = YES;
		if (([self.serverProtocol isEqualToString:@"https"]) && (self.serverPort == 443)) skipPort = YES;
		
		// construct the URL
		if (skipPort)
		{
			// construct url with default (i.e. no) port
			self.serverUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", self.serverProtocol, self.serverHost]];
		}
		else
		{
			self.serverUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%ld", self.serverProtocol, self.serverHost, (long)self.serverPort]];
		}

		self.networkCount = 0;
    }
	
    return self;
}

- (id) initWithUrl:(NSURL *)url preferences:(id<PreferencesDelegate>)pd
{
	self = [super init];
    if (self)
	{
		self.preferencesDelegate = pd;

		// not yet logged in / active
		self.active = NO;
		
		// save the URL
		self.serverUrl = url;
		
		self.networkCount = 0;
    }

    return self;
}

- (void)dealloc
{
	[userId release];
	[password release];
	[internalUserId release];
	[serverUrl release];
	[serverProtocol release];
	[serverHost release];
	[version release];
	[build release];
	[cachedSiteMembers release];
	[cachedSiteMembersSiteId release];
	[cachedSiteMembersUserId release];

    [super dealloc];
}

#pragma mark - base64

// base64EncodingTable and base64StringFromData in this section ONLY...
// taken from https://github.com/eczarny/xmlrpc
//
// Copyright (c) 2010 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

/* Base64 Encoding Table */
static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

- (NSString *)base64StringFromData: (NSData *)data length: (NSUInteger)length includeNewLines: (BOOL)includeNewLines {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    
    if (lentext < 1) {
        return @"";
    }
    
    result = [NSMutableString stringWithCapacity: lentext];
    
    raw = [data bytes];
    
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        
        if (ctremaining <= 0) {
            break;
        }
        
        for (i = 0; i < 3; i++) { 
            unsigned long ix = ixtext + i;
            
            if (ix < lentext) {
                input[i] = raw[ix];
            } else {
                input[i] = 0;
            }
        }
        
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        
        ctcopy = 4;
        
        switch (ctremaining) {
            case 1: 
                ctcopy = 2;
                break;
            case 2: 
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString: @"="];
        }
        
        ixtext += 3;
        charsonline += 4;

        if (includeNewLines)
		{
			if ((ixtext % 90) == 0) {
				[result appendString: @"\n"];
			}
        
			if (length > 0) {
				if (charsonline >= length) {
					charsonline = 0;
                
					[result appendString: @"\n"];
				}
			}
		}
    }

    return result;
}

#pragma mark - request processing

- (NSString *) basicAuthHeaderValue
{
	// put them in a string: "<userName>:<password>"
	NSString *userNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.userId, self.password];
	
	// base 64 encode
	NSData *userNameAndPasswordData = [userNameAndPassword dataUsingEncoding:NSUTF8StringEncoding];
	NSString *encodedNameAndPassword = [self base64StringFromData:userNameAndPasswordData length:[userNameAndPassword length] includeNewLines:NO];

	// finall, the format "Basic <encodedNameAndPassword>"
	return [NSString stringWithFormat:@"Basic %@", encodedNameAndPassword]; 
}

- (void) appendParameterToData:(NSMutableData *)data boundary:(NSString *)boundary name:(NSString *)name value:(NSString *)value
{
	NSString * valueStr = [NSString	stringWithFormat:@"%@", value];
	
	// encode into the data
	[data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[@"Content-Type: text/plain;charset=UTF-8\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", name, valueStr] dataUsingEncoding:NSUTF8StringEncoding]];
}

// pack the parameters into a HTTP POST body with the requested encoding.  Return nil if there is a problem, such as an invalid encoding
- (NSData *) postBodyForParameters:(NSDictionary *)parameters multipartBoundary:(NSString *)boundary
{
	NSMutableData *data = [[NSMutableData alloc] init];

	for (NSString *key in [parameters allKeys])
	{
		id value = [parameters objectForKey:key];
		[self appendParameterToData:data boundary:boundary name:key value:value];
	}

	// add the version information
	[self appendParameterToData:data boundary:boundary name:@"inTouch_version" value:self.version];
	[self appendParameterToData:data boundary:boundary name:@"inTouch_build" value:self.build];
	[self appendParameterToData:data boundary:boundary name:@"cdp_version" value:CDP_VERSION];

	// final boundary
	[data appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	return [data autorelease];
}

- (BOOL) loadAvatarImage:(NSString *)avatarPath completion:(completion_block_i) block
{
	if (avatarPath == nil) return NO;

	// the avatar image URL
	NSURL *url = [NSURL URLWithString:avatarPath relativeToURL:serverUrl];
	// NSLog(@"avatar url: %@", url);
	
	// authorization
	NSString *authorization = [self basicAuthHeaderValue];
	
	// set up a request
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"GET"];
	[req setValue:authorization forHTTPHeaderField:@"Authorization"];

	// copy the caller's block for later async. access
	completion_block_i blockCopy = [block copy];
	
	// completion block 
	completion_block_d myBlock = ^(NSData *data)
	{
		[self endNetworkActivity];

		if (blockCopy != nil)
		{
			UIImage *image = nil;
			if (data != nil)
			{
				// load the image from the data
				image = [UIImage imageWithData: data];
			}
			
			// run the compltion block
			blockCopy(image);
		}
	};

	[self startNetworkActivity];

	// make a the request delegate - the request is started once this is created
	// Note: The delegate holds a reference to the connection, and the connection holds a reference to the delegate.
	[[[RequestDelegate alloc] initWithRequest:req completion:nil orRaw:myBlock] release];

	[blockCopy release];

	return YES;
}

// put up an alert telling of server communications trouble
- (void) alertServerCommunicationsTrouble
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Alert"
						  message: @"Unable to contact Etudes at this time."
						  delegate: self
						  cancelButtonTitle: @"OK"
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

// put up an alert telling of a too-old app version
- (void) alertAppTooOld
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle: @"Alert"
						  message: @"You need to update your inTouch app."
						  delegate: self
						  cancelButtonTitle: @"OK"
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

- (BOOL) processRequest:(NSString *)requestPath parameters:(NSDictionary *)parameters completion:(completion_block_sd) block
{
	// the POST body content type
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;charset=UTF-8;boundary=%@", BOUNDARY];
	//NSLog(@"content type: %@\n", contentType);
	
	// pack the parameters into a post body
	NSData *postBody = [self postBodyForParameters:parameters multipartBoundary:BOUNDARY];
	
	//NSLog(@"post body len: %d:\n%@", [postBody length], postBody);
	//NSString *postBodyString = [[NSString alloc]initWithData:postBody encoding:NSUTF8StringEncoding];
	//NSLog(@"post body:\n%@", postBodyString);
	//[postBodyString release];
	
	// the request path
	NSString *fullPath = [NSString stringWithFormat:@"/cdp/%@", requestPath];
	
	// the request URL
	NSURL *url = [NSURL URLWithString:fullPath relativeToURL:serverUrl];
	//NSLog(@"url: %@", url);
	
	// authorization
	NSString *authorization = [self basicAuthHeaderValue];
	
	// set up a request
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"POST"];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	[req setValue:authorization forHTTPHeaderField:@"Authorization"];
	[req setHTTPBody:postBody];

	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];

	// completion block 
	completion_block_sd myBlock = ^(enum resultStatus status, NSDictionary *results)
	{
		[self endNetworkActivity];

		// run the caller's block
		if (blockCopy != nil) blockCopy(status, results);

		// if there was a problem
		if ((status == serverUnavailable) || (success == badRequest))
		{
			[self alertServerCommunicationsTrouble];
		}

		// if this app is too old to work with the server
		if (status == oldVersion)
		{
			[self alertAppTooOld];
		}
	};
	
	[self startNetworkActivity];

	// make a the request delegate - the request is started once this is created
	// Note: The delegate holds a reference to the connection, and the connection holds a reference to the delegate.
	[[[RequestDelegate alloc] initWithRequest:req completion:myBlock orRaw:nil] release];

	[blockCopy release];

	return YES;
}

- (NSString *) encodeBool:(BOOL)value
{
	if (value) return @"1";
	return @"0";
}

#pragma mark - test

- (BOOL) test:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"student1", @"name", @"etudes", @"password", nil];

	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		NSLog(@"Status:\n%d\n", status);
		NSLog(@"Results:\n%@\n", results);
		blockCopy(status, results);
	};
	
	// process the request
	[self processRequest:@"snoop" parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

#pragma mark - cdp access

- (BOOL) getSites:(completion_block_sa)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sa blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// pull sites from the results
		NSMutableArray *sites = [[NSMutableArray alloc] init];

		// make the Site objects from the strings in the dictionary
		NSArray *siteDefs = [results objectForKey:@"sites"];
		for (NSDictionary *siteDef in siteDefs)
		{
			Site *site = [Site siteForDef:siteDef];
			[sites addObject:site];
		}

		blockCopy(status, sites);
		[sites release];
	};

	// process the request
	[self processRequest:@"sites" parameters:nil completion:completion];
	
	[blockCopy release];

	return YES;
}

// get the announcements for the site
// asynchronous - runs the completion block with the Message objects in the array when done
- (BOOL) getAnnouncementsForSite:(Site *)site limit:(NSInteger)limit completion:(completion_block_sa)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sa blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// pull announcements from the results
		NSMutableArray *announcements = [[NSMutableArray alloc] init];
		
		// make the Message objects from the strings in the dictionary
		NSArray *defs = [results objectForKey:@"announcements"];
		for (NSDictionary *def in defs)
		{
			ETMessage *message = [ETMessage messageForDef:def];
			[announcements addObject:message];
		}
		
		blockCopy(status, announcements);
		[announcements release];
	};
	
	// send the siteId parameter
	NSDictionary *parameters = nil;
	if (limit > 0)
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", [NSString stringWithFormat:@"%ld",(long)limit], @"limit", nil];
	}
	else
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	}

	// process the request
	[self processRequest:[NSString stringWithFormat:@"announcements/%@",site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

// get the CourseMap for the site
// asynchronous - runs the completion block with the dictionary with "courseMap" item containing the CourseMap.
- (BOOL) getCourseMapForSite:(Site *)site forUserId:(NSString *)forUserId completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// the map is in a "courseMap" entry in the results dictionary
		NSDictionary *mapDef = [results objectForKey:@"courseMap"];
		CourseMap *map = [CourseMap courseMapForDef:mapDef];
		
		// pack this into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObject:map forKey:@"courseMap"];
		
		blockCopy(status, rv);
	};

	// send the siteId parameter
	NSDictionary *parameters = nil;
	if (forUserId == nil)
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	}
	else
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", forUserId, @"forUserId", nil];
	}

	// process the request
	[self processRequest:[NSString stringWithFormat:@"courseMap/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

// get the Module for the site
// asynchronous - runs the completion block with the dictionary with "module" item containing the module.
- (BOOL) getModuleForSite:(Site *)site moduleId:(NSString *)moduleId completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// the map is in a "courseMap" entry in the results dictionary
		NSDictionary *moduleDef = [results objectForKey:@"module"];
		Module *module = [Module moduleForDef:moduleDef];

		// pack this into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObject:module forKey:@"module"];
		
		blockCopy(status, rv);
	};
	
	// send the siteId and moduleId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", moduleId, @"moduleId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"module/%@", moduleId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;
}

// get the Activity Meter Overview for the site
// asynchronous - runs the completion block with the dictionary with "activity" item containing the AM overview items.
- (BOOL) getActivityForSite:(Site *)site completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// the map is in a "activity" entry in the results dictionary
		NSDictionary *def = [results objectForKey:@"activity"];
		ActivityOverview *overview = [ActivityOverview activityOverviewForDef:def];

		// pack this into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObject:overview forKey:@"activity"];

		blockCopy(status, rv);
	};
	
	// send the siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"activity/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;
}

// get the chat messages for the site
// asynchronous - runs the completion block with the Message objects in the array when done
- (BOOL) getChatForSite:(Site *)site lastSeenMessageId:(NSString *)lastSeenMessageId  completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// pull announcements from the results
		NSMutableArray *chat = [[NSMutableArray alloc] init];
		
		// make the Message objects from the strings in the dictionary
		NSArray *defs = [results objectForKey:@"chat"];
		for (NSDictionary *def in defs)
		{
			ETMessage *message = [ETMessage messageForDef:def];
			[chat addObject:message];
		}
		
		NSNumber *append = [results objectForKey:@"append"];

		// pack this into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObjectsAndKeys:chat, @"messages", append, @"append", nil];
		[chat release];

		blockCopy(status, rv);
	};
	
	// send the siteId parameter
	NSDictionary *parameters = nil;
	if (lastSeenMessageId != nil)
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", lastSeenMessageId, @"lastSeenMessageId", nil];
	}
	else
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	}
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"chat/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

// get the private messages for the site
// asynchronous - runs the completion block with the Announcements in the array when done
- (BOOL) getPrivateMessagesForSite:(Site *)site limit:(NSInteger)limit completion:(completion_block_sa)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sa blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// pull announcements from the results
		NSMutableArray *announcements = [[NSMutableArray alloc] init];
		
		// make the Message objects from the strings in the dictionary
		NSArray *defs = [results objectForKey:@"messages"];
		for (NSDictionary *def in defs)
		{
			ETMessage *message = [ETMessage messageForDef:def];
			[announcements addObject:message];
		}
		
		blockCopy(status, announcements);
		[announcements release];
	};
	
	// send the siteId parameter
	NSDictionary *parameters = nil;
	if (limit > 0)
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", [NSString stringWithFormat:@"%ld",(long)limit], @"limit", nil];
	}
	else
	{
		parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	}
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"privateMessages/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

// get a private message by this id, possibly converted into plain text
// asynchronous - runs the completion block with the ETMessage in the dictionary entry "message" when done
- (BOOL) getMessageInSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// make the Message objects from the strings in the dictionary
		NSDictionary *def = [results objectForKey:@"message"];
		ETMessage *message = [ETMessage messageForDef:def];
		// [str stringPlainFromHtml]; ??
		
		// pack this into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObject:message forKey:@"message"];

		blockCopy(status, rv);
	};
	
	// send the siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId,
								@"siteId", messageId, @"messageId", [self encodeBool:plainText], @"plainText", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"message/%@", messageId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;
}

// get a news item by this id, possibly converted into plain text
// asynchronous - runs the completion block with the ETMessage in the dictionary entry "message" when done
- (BOOL) getNewsInSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// make the Message objects from the strings in the dictionary
		NSDictionary *def = [results objectForKey:@"message"];
		ETMessage *message = [ETMessage messageForDef:def];
		NSNumber *editLockAlert = [results objectForKey:@"editLockAlert"];

		// pack these into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", editLockAlert, @"editLockAlert", nil];
		
		blockCopy(status, rv);
	};
	
	// send the siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId,
								@"siteId", messageId, @"messageId", [self encodeBool:plainText], @"plainText", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"news/%@", messageId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;
}

// get the discussion categories and forums for the site, with chat info
// asynchronous - runs the completion block with the arrays of categories, chat name and presence in the dictionary
- (BOOL) getForumsForSite:(Site *)site category:(NSString *)categoryId completion:(completion_block_sd)block;
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		NSMutableDictionary * rv = [[NSMutableDictionary alloc] init];

		// process the categories w/ forums
		NSMutableArray *categories = [[NSMutableArray alloc] init];
		NSArray *defs = [results objectForKey:@"categories"];
		for (NSDictionary *def in defs)
		{
			Category *category = [Category CategoryForDef:def];
			[categories addObject:category];
		}

		[rv setObject:categories forKey:@"categories"];
		[categories release];
		
		// get the name of the chat channel
		NSString * chatName = [results objectForKey:@"chatName"];
		if (chatName != nil) [rv setObject:chatName forKey:@"chatName"];
		
		// if anyone is present there
		NSNumber *the_presence = [results objectForKey:@"chatPresence"];
		if (the_presence != nil)
		{
			[rv setObject:the_presence forKey:@"chatPresence"];
		}

		blockCopy(status, rv);
		[rv release];
	};
	
	// send the siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", categoryId, @"categoryId", nil];

	// process the request
	[self processRequest:[NSString stringWithFormat:@"forums/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

// get the topics for the forum - also getting the updated forum object
// asynchronous - runs the completion block with the arrays of actual items in the dictionary by item group name.
- (BOOL) getTopicsForForumId:(NSString *)forumId site:(Site *)site completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		NSMutableDictionary * rv = [[NSMutableDictionary alloc] init];

		NSDictionary *def = [results objectForKey:@"forum"];
		Forum *forum = [Forum forumInCategory:nil forDef:def];
		[rv setObject:forum forKey:@"forum"];

		NSMutableArray *topics = [[NSMutableArray alloc] init];		
		NSArray *defs = [results objectForKey:@"topics"];
		for (NSDictionary *def in defs)
		{
			Topic *topic = [Topic topicInForum:forum forDef:def];
			[topics addObject:topic];
		}
		
		[rv setObject:topics forKey:@"topics"];
		[topics release];

		blockCopy(status, rv);
		[rv release];
	};
	
	// send the forumId and siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:forumId, @"forumId", site.siteId, @"siteId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"topics/%@", forumId] parameters:parameters completion:completion];
	
	[blockCopy release];

	return YES;
}

// get the recent topics for the site
// asynchronous - runs the completion block with the arrays of actual items in the dictionary by item group name.
- (BOOL) getRecentTopicsForSite:(Site *)site completion:(completion_block_sa)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sa blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		NSMutableArray *topics = [[NSMutableArray alloc] init];		
		NSArray *defs = [results objectForKey:@"topics"];
		for (NSDictionary *def in defs)
		{
			Topic *topic = [Topic topicInForum:nil forDef:def];
			[topics addObject:topic];
		}
		
		// sort by topic.latestPost (reversed)
		NSArray *sortedTopics = [topics sortedArrayUsingComparator: ^(id obj1, id obj2)
		{
			Topic *t1 = (Topic *) obj1;
			Topic *t2 = (Topic *) obj2;
			return [t2.latestPost compare:t1.latestPost];
		}];
		
		blockCopy(status, sortedTopics);
		[topics release];
	};
	
	// send the forumId and siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"recentTopics/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;
}

// get the posts for a topic: marks the topic as read - also delivers an updated topic and forum
// asynchronous - runs the completion block when done
- (BOOL) getPosts:(NSString *)topicId site:(Site *)site completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		NSMutableDictionary *rv = [[NSMutableDictionary alloc] init];

		NSDictionary *def = [results objectForKey:@"forum"];
		Forum *forum = [Forum forumInCategory:nil forDef:def];
		[rv setObject:forum forKey:@"forum"];

		def = [results objectForKey:@"topic"];
		Topic *topic = [Topic topicInForum:nil forDef:def];
		[rv setObject:topic forKey:@"topic"];

		NSMutableArray *posts = [[NSMutableArray alloc] init];		
		NSArray *defs = [results objectForKey:@"posts"];
		for (NSDictionary *def in defs)
		{
			Post *post = [Post postForDef:def];
			[posts addObject:post];
		}

		[rv setObject:posts forKey:@"posts"];
		[posts release];
		
		blockCopy(status, rv);
		[rv release];
	};
	
	// send the topicId and siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:topicId, @"topicId", site.siteId, @"siteId", nil];

	// process the request
	[self processRequest:[NSString stringWithFormat:@"posts/%@", topicId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;
}

// get the plain text body for a post
// asynchronous - runs the completion block when done
- (BOOL) getPostBody:(Site *)site postId:(NSString *)postId completion:(completion_block_sd)block;
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// send the messageId and siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:postId, @"postId", site.siteId, @"siteId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"postBody/%@", postId] parameters:parameters completion:block];
	
	return YES;
}

// get the quoted, plain text body for a post
// asynchronous - runs the completion block when done
- (BOOL) getPostBodyQuote:(Site *)site postId:(NSString *)postId completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}

	// send the messageId and siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:postId, @"postId", site.siteId, @"siteId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"postBodyQuote/%@", postId] parameters:parameters completion:block];
	
	return YES;
}

// get the members for the site
// asynchronous - runs the completion block with the Announcements in the array when done
- (BOOL) getMembersForSite:(Site *)site refresh:(BOOL)refresh completion:(completion_block_sa)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sa blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// pull announcements from the results
		NSMutableArray *members = [[NSMutableArray alloc] init];
		
		// make the Members objects from the strings in the dictionary
		NSArray *defs = [results objectForKey:@"members"];
		for (NSDictionary *def in defs)
		{
			Member *member = [Member memberForDef:def];
			[members addObject:member];
		}
		
		// cache
		self.cachedSiteMembers = members;
		self.cachedSiteMembersSiteId = site.siteId;
		self.cachedSiteMembersUserId = self.userId;

		blockCopy(status, members);
		[members release];
	};
	
	// if we can use the available cache
	if ((!refresh) && ([site.siteId isEqualToString:self.cachedSiteMembersSiteId])
		&& (self.cachedSiteMembers != nil) && ([self.cachedSiteMembersUserId isEqualToString:self.userId]))
	{
		blockCopy(success, self.cachedSiteMembers);
	}
	
	else
	{
		// send the siteId parameter
		NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
		
		// process the request
		[self processRequest:[NSString stringWithFormat:@"members/%@", site.siteId] parameters:parameters completion:completion];
	}

	[blockCopy release];

	return YES;
}

#pragma mark - login / logout

// TODO: do we need to clear this on logout?
- (void) storeLoginCredentials
{
	// Note: NSURLCredentialPersistencePermanent does NOT share credentials across apps (such as with Safari) in iOS, just in Mac OSX.
	NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userId
															 password:self.password
														  persistence:NSURLCredentialPersistenceForSession];
	
	NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc]
											 initWithHost:self.serverHost
											 port:self.serverPort
											 protocol:self.serverProtocol
											 realm:@"Etudes"
											 authenticationMethod:NSURLAuthenticationMethodHTTPBasic];

	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
														forProtectionSpace:protectionSpace];
	[protectionSpace release];
}

- (BOOL) loginAsUser:(NSString *)userIdCredential password:(NSString *)passwordCredential completion:(completion_block_s) block
{
	// if logged in, logout first
	if (self.active)
	{
		[self logout];
	}

	// the parameter dictionary / request body
	NSDictionary *parameters = [NSDictionary dictionary];

	// set the credentials
	self.userId = userIdCredential;
	self.password = passwordCredential;

	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// if successful, set active
		if (status == success)
		{
			self.active = YES;
			
			// pick up the internal user id and email
			self.internalUserId = [results objectForKey:@"internalUserId"];
			self.email = [results objectForKey:@"email"];

			// set prefs
			[self.preferencesDelegate setUserEid:self.userId];
			[self.preferencesDelegate setPassword:self.password];
			[self.preferencesDelegate setUserId:self.internalUserId];			
			[self.preferencesDelegate setEmail:self.email];
			
			[self storeLoginCredentials];
		}

		// otherwise clear the credentials
		else
		{
			self.userId = nil;
			self.password = nil;
		}

		// run the client's block
		blockCopy(status);			
	};

	// process the request
	[self processRequest:[NSString stringWithFormat:@"authenticate/%@", userIdCredential] parameters:parameters completion:completion];

	[blockCopy release];

	return YES;
}

// logout
- (BOOL) logout
{
	// bail out if we are not logged in
	if (!self.active) return NO;

	// we are now not logged in, as far as we are concerned
	self.active = NO;
	
	// process the request
	[self processRequest:@"logout" parameters:nil completion:NULL];

	// forget the credentials
	self.userId = nil;
	self.password = nil;
	self.internalUserId = nil;
	
	// remove the pw from prefs
	[self.preferencesDelegate setPassword:nil];
	
	// and site
	[self.preferencesDelegate setSite:nil];

	return YES;
}

// attempt a login based on stored user preference info, checking that the preferences site is still valid for the user
// authentication is asynchronous - runs one of the completion blocks when done:
// if user login works, and the internal id matches, and the site is valid for the user, block2
// if the login works, an the internal id matches, but the site is no longer valid for the user, block1
// if the login fails or the user id has changed, block0
- (void) authenticateFromPreferences:(completion_block_s)block0 badSite:(completion_block_s)block1 success:(completion_block_s)block2
{
	// collect the preferences
	NSString *eid = [self.preferencesDelegate userEid];
	NSString *pw = [self.preferencesDelegate password];
	NSString *iid = [self.preferencesDelegate userId];
	Site *site = [self.preferencesDelegate site];
	
	// bail out if we are logging in or logged in
	if (self.active)
	{
		block0(badRequest);
	}

	// the parameter dictionary / request body
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: site.siteId, @"siteId", site.title, @"siteTitle", iid, @"userId", nil];

	// set the credentials
	self.userId = eid;
	self.password = pw;
	
	// the parameters

	// copy the caller's blocks for later async. access
	completion_block_s blockCopy0 = [block0 copy];
	completion_block_s blockCopy1 = [block1 copy];
	completion_block_s blockCopy2 = [block2 copy];

	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// if successful, set active
		int resultCode = 0;
		if (status == success)
		{
			// what was the outcome - 0 for user login / iid failure, 1 for successful user info, bad site info, 2 for all is good
			NSNumber * resultCodeNs = [results objectForKey:@"resultCode"];
			resultCode = [resultCodeNs intValue];

			// if we had a successful login
			if (resultCode != 0)
			{
				self.active = YES;
			
				// pick up the internal user id
				self.internalUserId = [results objectForKey:@"internalUserId"];
				self.email = [results objectForKey:@"email"];
				
				[self storeLoginCredentials];
			}
		}
		
		// otherwise clear the credentials
		else
		{
			self.userId = nil;
			self.password = nil;
		}
		
		// based on results, update prefs and run the client's blocks
		switch (resultCode)
		{
			// login failure
			case 0:
				// clear site, iid, pw from prefs
				[self.preferencesDelegate setUserId:nil];
				[self.preferencesDelegate setPassword:nil];
				[self.preferencesDelegate setEmail:nil];
				[self.preferencesDelegate setSite:nil];

				blockCopy0(status);			
				break;

			// login successful, site failure
			case 1:
				// clear site from prefs
				[self.preferencesDelegate setSite:nil];

				blockCopy1(status);			
				break;

			// login and site successful
			case 2:
				blockCopy2(status);			
				break;
		}
	};
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"authenticateUserSite/%@", eid] parameters:parameters completion:completion];
	
	[blockCopy0 release];
	[blockCopy1 release];
	[blockCopy2 release];
}

#pragma mark - cdp post

// send an edit to a post
// asynchronous - runs the completion block with the status when done
- (BOOL) sendEditToPost:(NSString *)postId site:(Site *)site
				subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", postId, @"postId",
								subject, @"subject", [self encodeBool:plainText], @"plainText", body, @"body", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"editPost/%@", postId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send a post as a reply to another post in the topic
// asynchronous - runs the completion block with the status when done
- (BOOL) sendReplyToPost:(NSString *)postId topic:(Topic *)topic
					site:(Site *)site subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", postId, @"postId",
								topic.topicId, @"topicId", subject, @"subject", [self encodeBool:plainText], @"plainText", body, @"body", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"replyPost/%@", topic.topicId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send a post
// asynchronous - runs the completion block with the status when done
- (BOOL) sendPostToTopic:(Topic *)topic site:(Site *)site subject:(NSString *)subject
					body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId",
								topic.topicId, @"topicId", subject, @"subject", [self encodeBool:plainText], @"plainText", body, @"body", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"newPost/%@", topic.topicId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send a chat message
// asynchronous - runs the completion block with the status when done
- (BOOL) sendChatForSite:(Site *)site body:(NSString *)body completion:(completion_block_s)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", body, @"body", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"newChat/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send a Private Message (body may be in plain text)
// asynchronous - runs the completion block with the status when done
- (BOOL) sendPrivateMessageTo:(NSArray *)to site:(Site *)site subject:(NSString *)subject
						 body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};

	// concat all user ids with | separator
	NSMutableString *toUsers = [[NSMutableString alloc] init];
	BOOL first = YES;
	for (NSString *uid in to)
	{
		if (!first)
		{
			[toUsers appendString:@"|"];
		}
		first = NO;
		[toUsers appendString:uid];
	}

	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId",
								toUsers, @"toUserIds", subject, @"subject", body, @"body", [self encodeBool:plainText], @"plainText", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"newPrivateMessage/%@", site.siteId] parameters:parameters completion:completion];
	
	[toUsers release];
	[blockCopy release];
	
	return YES;	
}

// send a Private Message reply (body may be in plain text)
// asynchronous - runs the completion block with the status when done
- (BOOL) sendPrivateMessageReplyTo:(NSString *)messageId site:(Site *)site
						   subject:(NSString *)subject body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};

	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId",
								messageId, @"messageId", subject, @"subject", body, @"body", [self encodeBool:plainText], @"plainText", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"replyPrivateMessage/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send a topic
// asynchronous - runs the completion block with the status when done
- (BOOL) sendTopicToForum:(Forum *)forum site:(Site *)site subject:(NSString *)subject
					 body:(NSString *)body completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId",
								forum.forumId, @"forumId", subject, @"subject", [self encodeBool:plainText], @"plainText", body, @"body", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"newTopic/%@", forum.forumId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send a new news item
// asynchronous - runs the completion block with the status when done
- (BOOL) sendNewNewsForSite:(Site *)site subject:(NSString *)subject
					   body:(NSString *)body draft:(BOOL)draft priority:(BOOL)priority completion:(completion_block_s)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", subject, @"subject", body, @"body",
								[self encodeBool:draft], @"draft", [self encodeBool:priority], @"priority", [self encodeBool:plainText], @"plainText", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"newNewsItem/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send an updated news item
// asynchronous - runs the completion block with the status and the updated message when done
- (BOOL) sendUpdatedNewsForSite:(Site *)site messageId:(NSString *)messageId subject:(NSString *)subject body:(NSString *)body
						  draft:(BOOL)draft priority:(BOOL)priority completion:(completion_block_sd)block plainText:(BOOL)plainText
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		// pull a message from the results
		NSDictionary *def = [results objectForKey:@"update"];
		ETMessage *message = [ETMessage messageForDef:def];
		NSNumber *editLockAlert = [results objectForKey:@"editLockAlert"];

		// pack these into a dictionary
		NSDictionary *rv = [NSDictionary dictionaryWithObjectsAndKeys:message, @"update", editLockAlert, @"editLockAlert", nil];

		blockCopy(status, rv);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", messageId, @"messageId", subject, @"subject", body, @"body",
								[self encodeBool:draft], @"draft", [self encodeBool:priority], @"priority", [self encodeBool:plainText], @"plainText", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"updatedNewsItem/%@", messageId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// send an acceptance for syllabus
// asynchronous - runs the completion block with the status when done
- (BOOL) sendSyllabusAcceptance:(Site *)site completion:(completion_block_s)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_s blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status);
	};
	
	// send the siteId parameter
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"acceptSyllabus/%@", site.siteId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;		
}

#pragma mark - cdp delete

// delete a private message
// asynchronous - runs the completion block with the status when done
- (BOOL) deleteMessageForSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status, results);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", messageId, @"messageId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"deletePrivateMessage/%@", messageId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// delete a post
// asynchronous - runs the completion block with the status when done
- (BOOL) deletePostForSite:(Site *)site postId:(NSString *)postId completion:(completion_block_sd)block
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status, results);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", postId, @"postId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"deletePost/%@", postId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// delete a news item
// asynchronous - runs the completion block with the status when done
- (BOOL) deleteNewsForSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block;
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status, results);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", messageId, @"messageId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"deleteNewsItem/%@", messageId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

// delete a chat message
// asynchronous - runs the completion block with the status when done
- (BOOL) deleteChatForSite:(Site *)site messageId:(NSString *)messageId completion:(completion_block_sd)block;
{
	// must be logged in
	if (!self.active)
	{
		block(notLoggedIn, nil);
		return NO;
	}
	
	// copy the caller's block for later async. access
	completion_block_sd blockCopy = [block copy];
	
	// the completion block
	completion_block_sd completion = ^(enum resultStatus status, NSDictionary *results)
	{
		blockCopy(status, results);
	};
	
	// send the siteId, topic, subject, and body parameters
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:site.siteId, @"siteId", messageId, @"messageId", nil];
	
	// process the request
	[self processRequest:[NSString stringWithFormat:@"deleteChat/%@", messageId] parameters:parameters completion:completion];
	
	[blockCopy release];
	
	return YES;	
}

#pragma mark - network activity

// there is network activity - make sure the spinner is spinning - balance with a call to endNetworkActivity
- (void) startNetworkActivity
{
	if (self.networkCount == 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	self.networkCount = self.networkCount + 1;
	//NSLog(@"network count +: %d", self.networkCount);
}

// network activity is ended, remove the spinner if there is no other network activity
- (void) endNetworkActivity
{
	self.networkCount = self.networkCount - 1;
	//NSLog(@"network count -: %d", self.networkCount);
	if (self.networkCount == 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@end
