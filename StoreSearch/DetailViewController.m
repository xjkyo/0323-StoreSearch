//
//  DetailViewController.m
//  StoreSearch
//
//  Created by XK on 16/4/1.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)dealloc{
    NSLog(@"dealloc %@",self);
}

-(IBAction)close:(id)sender{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    NSLog(@"Before removeFromParentViewController");
    [self removeFromParentViewController];
    NSLog(@"After removeFromParentViewController");
}

@end
