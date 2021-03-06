//
//  DetailViewController.h
//  StoreSearch
//
//  Created by XK on 16/4/1.
//  Copyright © 2016年 XK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchResult;
typedef NS_ENUM(NSUInteger,DetailViewControllerAnimationType) {
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
};

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic,strong) SearchResult *searchResult;

-(void)presentInParentViewController:(UIViewController *)parentViewController;
-(void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;
-(void)sendSupportEmail;
@end
