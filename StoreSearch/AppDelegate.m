//
//  AppDelegate.m
//  StoreSearch
//
//  Created by XK on 16/3/23.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "DetailViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [self customizeAppearance];
    
    self.searchViewController=[[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        self.splitViewController=[[UISplitViewController alloc]init];
        DetailViewController *detailViewController=[[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
        UINavigationController *detailNavigationController=[[UINavigationController alloc]initWithRootViewController:detailViewController];
        // create an instance of DetailViewController and put that inside a new UINavigationController. It is this navigation controller that you actually put in the split-view’s detail pane.
        self.splitViewController.delegate=detailViewController;
        self.splitViewController.viewControllers=@[self.searchViewController,detailNavigationController];   //master pane, detail pane.
        self.window.rootViewController=self.splitViewController;
        self.searchViewController.detailViewController=detailViewController;
    }else{
        self.window.rootViewController=self.searchViewController;
    }
    //self.window.rootViewController=self.searchViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)customizeAppearance{
    UIColor *barTintColor=[UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    [[UISearchBar appearance]setBarTintColor:barTintColor];
    self.window.tintColor=[UIColor colorWithRed:10/255.0f green:80/255.0f blue:80/255.0f alpha:1.0f];
}

@end
