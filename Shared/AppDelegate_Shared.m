/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Shared/AppDelegate_Shared.m $
 * $Id: AppDelegate_Shared.m 11714 2015-09-24 22:36:20Z ggolden $
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

#import "AppDelegate_Shared.h"
#import "LoginViewController.h"
#import "HelpViewController.h"
// #import "GatewayViewController.h"
#import "WelcomeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate_Shared

@synthesize window, session;

#pragma mark - Application lifecycle

/**
 Save changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
	// NSLog(@"applicationWillTerminate");
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// NSLog(@"applicationDidEnterBackground");
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
	{
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
		{
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// NSLog(@"applicationDidBecomeActive");

	// trigger viewWillAppear
	[self.window.rootViewController viewWillAppear:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	// NSLog(@"applicationWillResignActive");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	// NSLog(@"applicationWillEnterForeground");
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyEtudes" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyEtudes.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc
{
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
	[session release];
    [window release];

    [super dealloc];
}

#pragma mark - EtudesServerSessionDelegate

- (void) authenticateOverViewController:(UIViewController *)viewController completion:(completion_block_s)block
{
	// if already logged in, just run the completion block
	if (self.session.active)
	{
		block(success);
		return;
	}
	
	// create the login view controller
	LoginViewController *lvc = [[LoginViewController alloc] initWithDelegates:self];
	lvc.completion = block;
	
	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:lvc animated:NO];
	[lvc release];

	// present the controllers modally
    [viewController presentViewController:nav animated:YES completion:nil];
	[nav release];
}

- (void) helpFromViewController:(UIViewController *)viewController title:(NSString *)title url:(NSURL *)url
{
	// create the help view controller
	HelpViewController *hvc = [[HelpViewController alloc] initWithDelegates:self title:title url:url];

	// in a nav controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	[nav pushViewController:hvc animated:NO];
	[hvc release];
	
	// flip to it
	nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	// present the controllers modally
    [viewController presentViewController:nav animated:YES completion:nil];
	[nav release];
}

#pragma mark - NavDelegate

// make this the main navigation view controller
- (void) setMainViewController:(UIViewController *)controller direction:(int)direction
{
	// which transition? - only use a transition if we have a view already
	if (self.window.rootViewController)
	{
		CATransition *transition = [CATransition animation];
		transition.duration = 0.50;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		transition.type = kCATransitionPush;
		if (direction < 0)
		{
			transition.subtype = kCATransitionFromLeft;
		}
		else if (direction > 0)
		{
			transition.subtype = kCATransitionFromRight;
		}
		else
		{
			transition.type = kCATransitionFade;
		}
		[self.window.layer addAnimation:transition forKey:nil];
	}

	// change root controllers
	self.window.rootViewController = controller;
}

// go to the gateway (welcome, login) view
- (void) setMainViewControllerToGateway
{

	// make a welcome view
	WelcomeViewController *wvc = [[WelcomeViewController alloc] initWithDelegates:self];
	
	// make this the main view controller
	[self setMainViewController:wvc direction:0];
	[wvc release];

/*
	// nest the gateway in a navigation controller
	UINavigationController *nav = [[UINavigationController alloc] init];
	GatewayViewController *gvc = [[GatewayViewController alloc] initWithDelegates:self];
	[nav pushViewController:gvc animated:NO];
	[gvc release];
	
	// make this the main view controller
	[self setMainViewController:nav direction:0];
	[nav release];
*/
}

#pragma mark - PreferencesDelegate

// get the preferences user eid
- (NSString *) userEid
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value = [defaults stringForKey:@"account_eid"];
	return value;
}

// set the preferences user eid
- (void) setUserEid:(NSString *)ident;
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (ident == nil)
	{
		[defaults removeObjectForKey:@"account_eid"];
	}
	else
	{
		[defaults setObject:ident forKey:@"account_eid"];		
	}

	[defaults synchronize];
}

// get the preferences user internal id
- (NSString *) userId
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value = [defaults stringForKey:@"account_id"];
	return value;
}

// set the preferences user internal id
- (void) setUserId:(NSString *)ident;
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (ident == nil)
	{
		[defaults removeObjectForKey:@"account_id"];
	}
	else
	{
		[defaults setObject:ident forKey:@"account_id"];
	}

	[defaults synchronize];
}

// get the preferences password
- (NSString *) password
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value = [defaults stringForKey:@"account_password"];
	return value;
}

// set the preferences password
- (void) setPassword:(NSString *)pw;
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (pw == nil)
	{
		[defaults removeObjectForKey:@"account_password"];
	}
	else
	{
		[defaults setObject:pw forKey:@"account_password"];
	}

	[defaults synchronize];
}

// get the user email
- (NSString *) email
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *value = [defaults stringForKey:@"account_email"];
	return value;
}

// set the email
- (void) setEmail:(NSString *)email;
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (email == nil)
	{
		[defaults removeObjectForKey:@"account_email"];
	}
	else
	{
		[defaults setObject:email forKey:@"account_email"];
	}
	
	[defaults synchronize];
}

// get the preferences Site (autoreleased)
- (Site *) site
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ident = [defaults stringForKey:@"site_id"];
	NSString *title = [defaults stringForKey:@"site_title"];
	BOOL am = [defaults boolForKey:@"site_am"];
	BOOL cm = [defaults boolForKey:@"site_cm"];
	BOOL annc = [defaults boolForKey:@"site_annc"];
	BOOL instructorPrivileges = [defaults boolForKey:@"site_instructorPrivileges"];
	BOOL taPrivileges = [defaults boolForKey:@"site_taPrivileges"];
	if (ident == nil) return nil;
	
	Site *site = [[Site alloc] initWithId:ident title:title siteDescription:nil activityMeter:am
								courseMap:cm newAnnouncement:annc visible:YES instructorPrivileges:instructorPrivileges
							 taPrivileges:taPrivileges online:0 unreadMessages:0 unreadPosts:NO notVisitAlerts:0];
	
	return [site autorelease];
}

// set the preferences Site
- (void) setSite:(Site *)site;
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (site == nil)
	{
		[defaults removeObjectForKey:@"site_id"];
		[defaults removeObjectForKey:@"site_title"];
		[defaults removeObjectForKey:@"site_am"];
		[defaults removeObjectForKey:@"site_cm"];
		[defaults removeObjectForKey:@"site_annc"];
		[defaults removeObjectForKey:@"site_instructorPrivileges"];
		[defaults removeObjectForKey:@"site_taPrivileges"];
	}
	else
	{
		[defaults setObject:site.siteId forKey:@"site_id"];
		[defaults setObject:site.title forKey:@"site_title"];
		[defaults setBool:site.allowActivityMeter forKey:@"site_am"];
		[defaults setBool:site.allowCourseMap forKey:@"site_cm"];
		[defaults setBool:site.allowNewAnnouncement forKey:@"site_annc"];
		[defaults setBool:site.instructorPrivileges forKey:@"site_instructorPrivileges"];
		[defaults setBool:site.taPrivileges forKey:@"site_taPrivileges"];
	}

	[defaults synchronize];
}

#pragma mark - Delegates

//access the preferences delegate
- (id <PreferencesDelegate>) preferencesDelegate
{
	return self;
}

// access the nav delegate
- (id <NavDelegate>) navDelegate
{
	return self;
}

// access the session delegate
- (id <EtudesServerSessionDelegate>) sessionDelegate
{
	return self;
}

@end
