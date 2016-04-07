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
#import "GradientView.h"

@interface DetailViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,weak) IBOutlet UIView *popupView;
@property (nonatomic,weak) IBOutlet UIImageView *artworkImageView;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *kindLabel;
@property (nonatomic,weak) IBOutlet UILabel *genreLabel;
@property (nonatomic,weak) IBOutlet UIButton *priceButton;
@end

@implementation DetailViewController{
    GradientView *_gradientView;
}

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
    [self dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
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

-(void)presentInParentViewController:(UIViewController *)parentViewController{
    _gradientView=[[GradientView alloc]initWithFrame:parentViewController.view.bounds];
    [parentViewController.view addSubview:_gradientView];
    //you’re doing this before you add DetailViewController’s view to the parent view controller, which causes the GradientView to sit below the popup
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue=@0.0f;
    fadeAnimation.toValue=@1.0f;
    fadeAnimation.duration=0.5;
    [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    
    self.view.frame=parentViewController.view.bounds;
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    //[self didMoveToParentViewController:parentViewController];
    CAKeyframeAnimation *bounceAnimation=[CAKeyframeAnimation animationWithKeyPath:@"transform.scale"]; //works on the view’s transform.scale attributes. That means you’ll be animating the size of the view.
    bounceAnimation.duration=0.5;
    bounceAnimation.delegate=self;
    bounceAnimation.values=@[@0.7,@1.2,@0.9,@1.0];  //Because you’re animating the view’s scale, these particular values represent how much bigger or smaller the view will be over time.
    bounceAnimation.keyTimes=@[@0.0,@0.334,@0.666,@1.0];    //百分比，总时间0.5
    bounceAnimation.timingFunctions=@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];  //specify a timing function that is used to go from one keyframe to the next.
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];   //Core Animation doesn’t work on the UIView objects themselves but on their CALayers
}

-(void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.4 animations:^{
        if (animationType==DetailViewControllerAnimationTypeSlide) {
            CGRect rect=self.view.bounds;
            rect.origin.y +=rect.size.height;
            self.view.frame=rect;
        }else{
            self.view.alpha=0.0f;
        }
        _gradientView.alpha=0.0f;
    }completion:^(BOOL finished){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [_gradientView removeFromSuperview];
    }];
    //[self.view removeFromSuperview];
    //[self removeFromParentViewController];
    //[_gradientView removeFromSuperview];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self didMoveToParentViewController:self.parentViewController];
    // When a view controller has been added to a parent controller using addChildViewController:, its parent property points to that parent controller.
}

@end
