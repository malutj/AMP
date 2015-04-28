//
//  AppDelegate.m
//  AMP
//
//  Created by Jason Malutich on 4/21/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property NSUserDefaults *defaults;
@property NSString *clientCode;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"creating window");
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    NSLog(@"Creating storyboard");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    UIViewController *viewController;
    if([self clientCodeIsSet]){
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsPage"];
    }
    else{
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
    }
    
    NSLog(@"Viewcontroller is set");
    self.window.rootViewController = viewController;
    
    NSLog(@"calling makeKeyandVisible");
    [self.window makeKeyAndVisible];
    
    NSLog(@"returning");

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)clientCodeIsSet {
    NSLog(@"testing defaults");
    if(!_defaults)
        _defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Getting client code");
    _clientCode = [_defaults stringForKey:@"clientCode"];
    
    NSLog(@"returning");
    return _clientCode != nil ? true : false;
}

@end
