/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Session/RequestDelegate.m $
 * $Id: RequestDelegate.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "RequestDelegate.h"
#import "JSON.h"

#define TIMEOUT 30.0

@interface RequestDelegate()

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, copy) completion_block_sd completion_sd;
@property (nonatomic, copy) completion_block_d completion_d;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation RequestDelegate

@synthesize status, type, data, completion_sd, completion_d, connection, timer;

#pragma mark - lifecycle

- (id) initWithRequest:(NSURLRequest *)request completion:(completion_block_sd)block_sd orRaw:(completion_block_d)block_d
{
	self = [super init];
    if (self)
	{
		self.status = -1;
		self.type = nil;

		NSMutableData *dta = [[NSMutableData alloc] init];
		self.data = dta;
		[dta release];

		completion_block_sd bsd = [block_sd copy];
		self.completion_sd = bsd;
		[bsd release];
		
		completion_block_d bd = [block_d copy];
		self.completion_d = bd;
		[bd release];
		
		NSTimer *tmr = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
		self.timer = tmr;

		// start the request
		self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }

    return self;
}

- (void) cancel
{
	[self.connection cancel];
}

- (void) dealloc
{
	[type release];
	[data release];
	[completion_sd release];
	[completion_d release];
	[connection release];
	if (timer != nil) [timer invalidate];
	[timer release];

    [super dealloc];
}

#pragma mark - Timer

- (void)timeout:(NSTimer*)theTimer
{
	//NSLog(@"timeout");

	// cancel the connection
	[self.connection cancel];

	// run completion
	if (self.completion_sd != nil)
	{
		self.completion_sd(serverUnavailable, nil);
	}
	else if (self.completion_d != nil)
	{
		self.completion_d(nil);		
	}
}

#pragma mark - JSON

- (void) parseJson:(NSString *)response into:(NSMutableDictionary *)dictionary
{
	// TODO: might be array?  Who owns?
	NSDictionary * d = [response JSONValue];
	[dictionary setDictionary:d];
}

#pragma mark - Connection Data and Responses

// request complete - get status and type
- (void) connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
	// stop our timeout timer
	[self.timer invalidate];
	self.timer = nil;

	// status
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
	self.status = httpResponse.statusCode;
	//NSLog(@"response headers: %@", [httpResponse allHeaderFields]);
	
	// mime type
	self.type = [[httpResponse MIMEType] lowercaseString];
}

// take some data
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)moreData
{
	[self.data appendData:moreData];
}

#pragma mark - Connection Completion

// failure
- (void) connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
	// stop our timeout timer
	[self.timer invalidate];
	self.timer = nil;

	// cancel the connection
	[self.connection cancel];
	
	// run completion
	if (self.completion_sd != nil)
	{
		self.completion_sd(serverUnavailable, nil);
	}
	else if (self.completion_d != nil)
	{
		self.completion_d(nil);		
	}
}

// success
- (void) connectionDidFinishLoading:(NSURLConnection *)conn
{
	// cancel the connection
	[self.connection cancel];

	// if we have the _sd compltion, process the data
	if (self.completion_sd != nil)
	{
		// the status code
		enum resultStatus rStatus = badRequest;

		// the parsed results
		NSMutableDictionary * results = [[NSMutableDictionary alloc] init];

		// parse the results only if we got a valid response
		if (self.status == 200)
		{
			//NSLog(@"raw response\n%@\n", [self.data description]);
			NSString *responseString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
			//NSLog(@"response:\n%@\n", responseString);

			// return content type
			//NSLog(@"type:\n%@\n", self.type);

			if ([@"application/json" isEqualToString:self.type])
			{
				// parse the return data into a dictionary
				[self parseJson:responseString into:results];
			}

			[responseString release];

			// pull out the status code
			rStatus = [[results objectForKey:@"cdp:status"] intValue];
		}

		// run the completion block
		self.completion_sd(rStatus, results);

		[results release];
	}

	// otherwise try the _d completion
	else if (self.completion_d != nil)
	{
		self.completion_d(self.data);
	}
}

@end
