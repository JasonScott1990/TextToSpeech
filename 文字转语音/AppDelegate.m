//
//  AppDelegate.m
//  文字转语音
//
//  Created by HuangXunhui on 2017/6/6.
//  Copyright © 2017年 HuangXunhui. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    FirstViewController *firstViewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    firstViewController.title = @"文字转语音";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    //  不设置可能因为手机设置而听不到声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
        NSLog(@"set category error : %@", error);
    }
    
    if (![audioSession setActive:YES error:&error]) {
        NSLog(@"set active error: %@", error);
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

//后台播放
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) { // Do some error handling
    }
    [session setActive:YES error:&error];
    if (error) { // Do some error handling
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
