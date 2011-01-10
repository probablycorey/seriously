/*  SeriouslyDemoAppDelegate.m */

/*  SeriouslyDemo
 *
 *  Created by Adam Duke on 1/10/11.
 *  Copyright 2011 None. All rights reserved.
 *
 */

#import "RootViewController.h"
#import "SeriouslyDemoAppDelegate.h"

@implementation SeriouslyDemoAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	/* Override point for customization after application launch. */

	/* Add the navigation controller's view to the window and display. */
	[self.window addSubview:navigationController.view];
	[self.window makeKeyAndVisible];

	return YES;
}

- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

