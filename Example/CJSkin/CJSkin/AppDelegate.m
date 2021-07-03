//
//  CJAppDelegate.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "AppDelegate.h"
#import "CJViewController.h"
#import "CJSecondViewController.h"
#import "CJNavigationController.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [CJSkin loadSkinInfoFromBundle:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    CJViewController *firstCtr = [[CJViewController alloc] initWithNibName:@"CJViewController" bundle:nil];
    firstCtr.hidesBottomBarWhenPushed = NO;
    firstCtr.title = @"First";
    CJNavigationController *firstNavController = [[CJNavigationController alloc] initWithRootViewController:firstCtr];
    UITabBarItem *tabItem1 = [[UITabBarItem alloc]CJ_skin_initWithTitle:@"First" imageKey:@"tabbar_message_nor" selectedImageKey:@"tabbar_message_sel"];
    [tabItem1 CJ_skin_setTitleTextAttributes:@{NSForegroundColorAttributeName:SkinColorTool(CJSkinTabBarTextColorKey)} forState:UIControlStateNormal];
    [tabItem1 CJ_skin_setTitleTextAttributes:@{NSForegroundColorAttributeName:SkinColorTool(CJSkinTabBarTextSelectColorKey)} forState:UIControlStateSelected];
    firstNavController.tabBarItem = tabItem1;
    
    CJSecondViewController *secondCtr = [[CJSecondViewController alloc] initWithNibName:@"CJSecondViewController" bundle:nil];
    secondCtr.title = @"Second";
    secondCtr.hidesBottomBarWhenPushed = NO;
    CJNavigationController *secondNavController = [[CJNavigationController alloc] initWithRootViewController:secondCtr];
    UITabBarItem *tabItem2 = [[UITabBarItem alloc]CJ_skin_initWithTitle:@"Second" imageKey:@"tabbar_work_nor" selectedImageKey:@"tabbar_work_sel"];
    [tabItem2 CJ_skin_setTitleTextAttributes:@{NSForegroundColorAttributeName:SkinColorTool(CJSkinTabBarTextColorKey)} forState:UIControlStateNormal];
    [tabItem2 CJ_skin_setTitleTextAttributes:@{NSForegroundColorAttributeName:SkinColorTool(CJSkinTabBarTextSelectColorKey)} forState:UIControlStateSelected];
    secondNavController.tabBarItem = tabItem2;
    
    UITabBarController *tabCtr = [[UITabBarController alloc] init];
    tabCtr.viewControllers = [NSArray arrayWithObjects:firstNavController,secondNavController,nil];
    self.window.rootViewController = tabCtr;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
