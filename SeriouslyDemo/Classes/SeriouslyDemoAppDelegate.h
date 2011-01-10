/*  SeriouslyDemoAppDelegate.h */

/*  SeriouslyDemo
 *
 *  Created by Adam Duke on 1/10/11.
 *  Copyright 2011 None. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@interface SeriouslyDemoAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

