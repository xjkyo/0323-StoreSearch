//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by XK on 16/4/6.
//  Copyright © 2016年 XK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Search;

@interface LandscapeViewController : UIViewController
//@property (nonatomic,strong) NSArray *searchResults;
@property (nonatomic,strong) Search *search;
-(void)searchResultsReceived;
@end
