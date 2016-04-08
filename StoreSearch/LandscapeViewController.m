//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by XK on 16/4/6.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import "Search.h"

@interface LandscapeViewController () <UIScrollViewDelegate>
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIPageControl *pageControl;
@end

@implementation LandscapeViewController{
    BOOL _firstTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    self.pageControl.numberOfPages=0;       //hide the page control
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstTime=YES;
    }
    return self;
}

-(void)viewWillLayoutSubviews{      //Only after viewDidLoad is done does the view get resized to fit on the 3.5- or 4-inch screen.
    //The only safe place to perform any calculations that use the view’s frame or bounds is in viewWillLayoutSubviews.
    [super viewWillLayoutSubviews];
    if (_firstTime) {
        _firstTime=NO;      //that method may be invoked more than once,use the _firstTime variable to make sure you only place the buttons once.
        [self tileButtons];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"dealloc %@",self);
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.showsVerticalScrollIndicator=NO;
    for (UIButton *button in self.scrollView.subviews) {
        //这里曾出现一个BUG：因为UIScrollView的横竖滚动条导致在subviews里面多了两个UIImageView,我们只需要设置scrollView.showsHorizontalScrollIndicator=NO;scrollView.showsVerticalScrollIndicator=NO;就可以把两个UIImageView去掉
        [button cancelImageDownloadTaskForState:UIControlStateNormal];
    }
}

-(void)tileButtons{
    int columnsPerPage=5;
    CGFloat itemWidth=96.0f;
    CGFloat x=0.0f;
    CGFloat extraSpace=0.0f;
    
    CGFloat scrollViewWidth=self.scrollView.bounds.size.width;
    if (scrollViewWidth >480.0f) {
        columnsPerPage=6;
        itemWidth=94.0f;
        x=2.0f;
        extraSpace=4.0f;
    }
    const CGFloat itemHeight=88.0f;
    const CGFloat buttonWidth=82.0f;
    const CGFloat buttonHeight=82.0f;
    const CGFloat marginHorz=(itemWidth-buttonWidth)/2.0f;
    const CGFloat marginVert=(itemHeight-buttonHeight)/2.0f;
    
    int index=0;
    int row=0;
    int column=0;
    for (SearchResult *searchResult in self.search.searchResults) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        //button.backgroundColor=[UIColor whiteColor];
        //[button setTitle:[NSString stringWithFormat:@"%d",index] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
        button.frame=CGRectMake(x+marginHorz, 20.0f+row*itemHeight+marginVert, buttonWidth, buttonHeight);
        [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
        [self.scrollView addSubview:button];
        index++;
        row++;
        if (row==3) {
            row=0;
            column++;
            x += itemWidth;
            if (column==columnsPerPage) {
                column=0;
                x += extraSpace;
            }
        }
    }
    int tilesPerPage=columnsPerPage*3;
    int numPages=ceilf([self.search.searchResults count]/(float)tilesPerPage);
    self.scrollView.contentSize=CGSizeMake(numPages*scrollViewWidth, self.scrollView.bounds.size.height);
    NSLog(@"Number of pages:%d",numPages);
    
    self.pageControl.numberOfPages=numPages;
    self.pageControl.currentPage=0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat width=self.scrollView.bounds.size.width;
    int currentPage=(self.scrollView.contentOffset.x+width/2.0f)/width;
    self.pageControl.currentPage=currentPage;
}

-(IBAction)pageChanged:(UIPageControl *)sender{
    //self.scrollView.contentOffset=CGPointMake(self.scrollView.bounds.size.width*sender.currentPage, 0);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset=CGPointMake(self.scrollView.bounds.size.width*sender.currentPage, 0);
    }completion:nil];
}

-(void)downloadImageForSearchResult:(SearchResult *)searchResult andPlaceOnButton:(UIButton *)button{
    NSURL *url=[NSURL URLWithString:searchResult.artworkURL60];
    //[button setImageForState:UIControlStateNormal withURL:url];
    //1
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    //2
    __weak UIButton *weakButton=button;// Inside that block you place the image on the button, which means that the block captures the button variable. That creates an ownership cycle, because the button owns the block and the block owns the button, resulting in a possible memory leak.To prevent this, you create a new variable weakButton that refers to the same button but is a weak pointer. The button still owns the block but now the block doesn’t own the button back.
    //3
    [button setImageForState:UIControlStateNormal withURLRequest:request placeholderImage:nil success:^(NSURLRequest *request,NSHTTPURLResponse *response,UIImage *image){
        //4
        UIImage *unscaledImage=[UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:image.imageOrientation];//By passing 1.0 to the scale parameter you simply tell UIImage that it should not treat this as a Retina image
        [weakButton setImage:unscaledImage forState:UIControlStateNormal];
    }failure:nil];
}

@end
