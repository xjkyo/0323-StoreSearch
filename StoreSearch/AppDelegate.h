//
//  AppDelegate.h
//  StoreSearch
//
//  Created by XK on 16/3/23.
//  Copyright © 2016年 XK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SearchViewController *searchViewController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

