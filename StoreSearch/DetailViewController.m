//
//  DetailViewController.m
//  StoreSearch
//
//  Created by XK on 16/4/1.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,weak) IBOutlet UIView *popupView;
@property (nonatomic,weak) IBOutlet UIImageView *artworkImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *kindLabel;
@property (nonatomic,weak) IBOutlet UILabel *genreLabel;
@property (nonatomic,weak) IBOutlet UIButton *priceButton;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //UIImage *image=[UIImage imageNamed:@"PriceButton"];
    UIImage *image=[[UIImage imageNamed:@"PriceButton"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];//UIKit will remove the original colors from the image and paint the whole thing in the tint color.
    [self.priceButton setBackgroundImage:image forState:UIControlStateNormal];
    self.view.tintColor=[UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
    self.popupView.layer.cornerRadius=10.0f;
    
    UITapGestureRecognizer *gestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(close:)];
    gestureRecognizer.cancelsTouchesInView=NO;
    gestureRecognizer.delegate=self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    if (self.searchResult != nil) {
        [self updateUI];
    }
    
    self.view.backgroundColor=[UIColor clearColor];
}

-(void)dealloc{
    NSLog(@"dealloc %@",self);
    [self.artworkImageView cancelImageDownloadTask];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return (touch.view==self.view);     //not in popupView
}

-(IBAction)close:(id)sender{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    NSLog(@"Before removeFromParentViewController");
    [self removeFromParentViewController];
    NSLog(@"After removeFromParentViewController");
}

-(void)updateUI{
    self.nameLabel.text=self.searchResult.name;
    NSString *artistName=self.searchResult.artistName;
    if (artistName == nil) {
        artistName=@"Unknown";
    }
    self.artistNameLabel.text=artistName;
    self.kindLabel.text=[self.searchResult kindForDisplay];
    self.genreLabel.text=self.searchResult.genre;
    
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:self.searchResult.currency];
    NSString *priceText;
    if ([self.searchResult.price floatValue]==0.0f) {
        priceText=@"Free";
    }else{
        priceText=[formatter stringFromNumber:self.searchResult.price];
    }
    //[self.priceButton setTitle:[NSString stringWithFormat:@"%@ %@",self.searchResult.currency,self.searchResult.price] forState:UIControlStateNormal];
    [self.priceButton setTitle:priceText forState:UIControlStateNormal];
    
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.searchResult.artworkURL100]];
}

-(IBAction)openInStore:(id)sender{
    NSLog(@"storeURL:%@",self.searchResult.storeURL);
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

@end
