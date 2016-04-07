//
//  SearchViewController.m
//  StoreSearch
//
//  Created by XK on 16/3/24.
//  Copyright © 2016年 XK. All rights reserved.
//  v0.2

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import <AFNetworking/AFNetworking.h>
#import "DetailViewController.h"
#import "LandscapeViewController.h"

static NSString * const SearchResultCellIdentifier=@"SearchResultCell";
static NSString * const NothingFoundCellIdentifier=@"NothingFoundCell";
static NSString * const LoadingCellIdentifier=@"LoadingCell";

@interface SearchViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
//A nib, the user interface of a view controller, is owned by that view controller.
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SearchViewController{
    NSMutableArray *_searchResults;
    BOOL _isLoading;
    AFHTTPSessionManager *manager;
    LandscapeViewController *_landscapeViewController;
    UIStatusBarStyle _statusBarStyle;
    __weak DetailViewController *_detailViewController;     //Now this pointer is no longer keeping the object alive and as soon as the object is deallocated, _detailViewController automatically becomes nil.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset=UIEdgeInsetsMake(108, 0, 0, 0);
    self.tableView.rowHeight=80;
    UINib *cellNib=[UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    cellNib=[UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    cellNib=[UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    NSLog(@"tableView frame height:%f",self.tableView.frame.size.height);
    NSLog(@"view frame height:%f",self.view.frame.size.height);  //这里是600，后面是568，why?  答：此处frame还没设置好
    [self.searchBar becomeFirstResponder];
    
    _statusBarStyle=UIStatusBarStyleDefault;
}

/*
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer=[AFJSONResponseSerializer serializer];
    }
    return self;
}*/

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self hideLandscapeViewWithDuration:duration];
    }else{
        [self showLandscapeViewWithDuration:duration];
    }
}

-(void)showLandscapeViewWithDuration:(NSTimeInterval)duration{
    if (_landscapeViewController == nil) {
        _landscapeViewController=[[LandscapeViewController alloc]initWithNibName:@"LandscapeViewController" bundle:nil];
        _landscapeViewController.view.frame=self.view.bounds;
        _landscapeViewController.view.alpha=0.0f;
        [self.view addSubview:_landscapeViewController.view];
        [self addChildViewController:_landscapeViewController];
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha=1.0f;
            _statusBarStyle=UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
        }completion:^(BOOL finished){
            [_landscapeViewController didMoveToParentViewController:self];
        }];
        [self.searchBar resignFirstResponder];
        [_detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeFade];
    }
}

-(void)hideLandscapeViewWithDuration:(NSTimeInterval)duration{
    if (_landscapeViewController != nil) {
        [_landscapeViewController willMoveToParentViewController:nil];
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha=0.0f;
            _statusBarStyle=UIStatusBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
        }completion:^(BOOL finished){
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            _landscapeViewController=nil;       //Remember to deallocate the LandscapeViewController
        }];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{     //[self setNeedsStatusBarAppearanceUpdate]; This causes the preferredStatusBarStyle method
    return _statusBarStyle;
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isLoading) {
        return 1;
    }else if (_searchResults == nil) {
        return 0;
    }else if([_searchResults count]==0){
        return 1;
    }else{
        return [_searchResults count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (_isLoading) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *spinner=(UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        return cell;
    }else if([_searchResults count]==0){
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
    }else{
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        SearchResult *searchResult=_searchResults[indexPath.row];
        [cell configureForSearchResult:searchResult];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *controller=[[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];  //This is the equivalent of making a modal segue
    SearchResult *searchResult=_searchResults[indexPath.row];
    controller.searchResult=searchResult;
    /*
    controller.view.frame=self.view.bounds;      //After you instantiate the DetailViewController it always has a view that is 568 points high, even on a 3.5-inch device. Before you add its view to the window you need to resize it to the proper dimensions.
    NSLog(@"tableView frame height:%f",self.tableView.frame.size.height);
    NSLog(@"view frame height:%f",self.view.frame.size.height);
    NSLog(@"subview frame height:%f",controller.view.frame.size.height);
    
    //放在这里将会使得pupView的标签为空，因为DetailViewController中对标签的设置在ViewDidLoad方法里，controlller.view.frame设置以后已经完成了ViewDidLoad，此处的设置不再生效
    //SearchResult *searchResult=_searchResults[indexPath.row];
    //controller.searchResult=searchResult;
    
    //[self presentViewController:controller animated:YES completion:nil];
    [self.view addSubview:controller.view]; //This places it on top of the table view, search bar and segmented control
    [self addChildViewController:controller];   //Then tell the SearchViewController that the DetailViewController is now managing that part of the screen
    [controller didMoveToParentViewController:self];    //Tell the new view controller that it now has a parent view controller
    //In this new arrangement, SearchViewController is the “parent” view controller, and DetailViewController is the “child”. In other words, the Detail screen is embedded inside the SearchViewController.
     */
    [controller presentInParentViewController:self];
    
    _detailViewController=controller;       //此处造成了一个内存泄露,dismiss时没有dealloc消息,所以要设置成weak
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([_searchResults count]==0 || _isLoading){
        return nil;//it may still turn gray if you hold down on the row for a short while. That is because you did not change the selectionStyle property of the cell.
    }else{
        return indexPath;
    }
}

#pragma mark - UISegmentedControl
-(IBAction)segmentChanged:(UISegmentedControl *)sender{
    NSLog(@"segment changed:%d",sender.selectedSegmentIndex);
    if (_searchResults != nil) {
        [self performSearch];
    }
}

#pragma mark - UISearchBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

-(void)showNetworkError{
    UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"Whoops" message:@"There was an error reading from iTunes Store. Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self performSearch];
}

-(void)performSearch{
    if([self.searchBar.text length]>0){
        [self.searchBar resignFirstResponder];
        if (manager) {
            //[manager.operationQueue cancelAllOperations];     //没有效果
            //[manager.tasks makeObjectsPerformSelector:@selector(cancel)];     //可行,所有任务取消后还可以继续发送请求
            [manager invalidateSessionCancelingTasks:YES];      //所有任务取消，不能继续请求，除非再创建一个新的manager
        }
        _isLoading=YES;
        [self.tableView reloadData];//the main thread never gets around to handling that event because you immediately keep the thread busy with the networking operation.

        _searchResults=[NSMutableArray arrayWithCapacity:10];
        /*
        dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSURL *url=[self urlWithSearchText:searchBar.text];
            NSLog(@"URL '%@'",url);
            NSString *jsonString=[self performStoreRequestWithURL:url];
            if (jsonString == nil) {
                //[self showNetworkError];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showNetworkError];    //涉及到UI
                });
                return;
            }
            NSDictionary *dictionary=[self parseJSON:jsonString];
            if (dictionary == nil) {
                //[self showNetworkError];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showNetworkError];
                });
                return;
            }
            NSLog(@"Dictionary '%@'",dictionary);
            [self parseDictionary:dictionary];
            [_searchResults sortUsingSelector:@selector(compareName:)];
            //_isLoading=NO;
            //[self.tableView reloadData];  // All UI code should always be performed on the main thread because of changing the UI from other threads would not be allowed.
            dispatch_async(dispatch_get_main_queue(), ^{
                _isLoading=NO;
                [self.tableView reloadData];
            });
        });*/
        NSURL *url=[self urlWithSearchText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex];
        //AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer=[AFJSONResponseSerializer serializer];
        [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject){
            //NSLog(@"Success: %@",responseObject);
            NSLog(@"Success!");
            [self parseDictionary:responseObject];
            [_searchResults sortUsingSelector:@selector(compareName:)];
            _isLoading=NO;
            [self.tableView reloadData];
        }failure:^(NSURLSessionTask *operation, NSError *error){
            if (error.code == -999) {    //手动取消无需弹框
                return;
            }
            NSLog(@"Failure: %@",error);
            [self showNetworkError];
            _isLoading=NO;
            [self.tableView reloadData];
        }];
    }
}

-(NSURL *)urlWithSearchText:(NSString *)searchText category:(NSInteger)category{
    NSString *categoryName;
    switch (category) {
        case 0: categoryName = @""; break;
        case 1: categoryName = @"musicTrack"; break;
        case 2: categoryName = @"software"; break;
        case 3: categoryName = @"ebook"; break;
    }
    
    //NSString *escapedSearchText=[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *escapedSearchText=[searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString=[NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@",escapedSearchText,categoryName];
    NSURL *url=[NSURL URLWithString:urlString];
    return url;
}

/*
-(NSString *)performStoreRequestWithURL:(NSURL *)url{
    NSError *error;
    NSString *resultString=[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if(resultString==nil){
        NSLog(@"Download Error:%@",error);
        return nil;
    }
    return resultString;
}*/

#pragma mark - Parsing JSON 
/*
-(NSDictionary *)parseJSON:(NSString *)jsonString{
    NSData *data=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id resuleObject=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(resuleObject==nil){
        NSLog(@"JSON Error: %@",error);
        return nil;
    }
    if(![resuleObject isKindOfClass:[NSDictionary class]]){
        NSLog(@"JSON Error: Expected dictionary");//It could have returned an NSArray or even an NSString or NSNumber...
        return nil;
    }
    return resuleObject;
}*/

-(void)parseDictionary:(NSDictionary *)dictionary{
    //NSArray *array=dictionary[@"results"];
    NSArray *array=dictionary[@"results"];//[dictionary objectForKey:@"results"];
    if (array == nil) {
        NSLog(@"Excepted 'result' array");
        return;
    }
    for (NSDictionary *resultDict in array) {
        //NSLog(@"wrapperType:%@,kind:%@",resultDict[@"wrapperType"],resultDict[@"kind"]);
        SearchResult *searchResult;
        NSString *wrapperType=resultDict[@"wrapperType"];
        NSString *kind=resultDict[@"kind"];
        
        if ([wrapperType isEqualToString:@"track"]) {
            searchResult=[self parseTrack:resultDict];
        }else if ([wrapperType isEqualToString:@"audiobook"]){
            searchResult=[self parseAudioBook:resultDict];
        }else if ([wrapperType isEqualToString:@"software"]){
            searchResult=[self parseSoftware:resultDict];
        }else if ([kind isEqualToString:@"ebook"]){
            searchResult=[self parseEbook:resultDict];
        }
        if (searchResult!=nil) {
            [_searchResults addObject:searchResult];
        }
    }
}

-(SearchResult *)parseTrack:(NSDictionary *)dictionary{
    SearchResult *searchResult=[[SearchResult alloc]init];
    searchResult.name=[dictionary objectForKey:@"trackName"]; //dictionary[@"trackName"];
    searchResult.artistName=dictionary[@"artistName"];
    searchResult.artworkURL60=dictionary[@"artworkUrl60"];
    searchResult.artworkURL100=dictionary[@"artworkUrl100"];
    searchResult.storeURL=dictionary[@"trackViewUrl"];
    searchResult.kind=dictionary[@"kind"];
    searchResult.price=dictionary[@"trackPrice"];
    searchResult.currency=dictionary[@"currency"];
    searchResult.genre=dictionary[@"primaryGenreName"];
    return searchResult;
}

-(SearchResult *)parseAudioBook:(NSDictionary *)dictionary{
    SearchResult *searchResult=[[SearchResult alloc]init];
    searchResult.name=dictionary[@"collectionName"];
    searchResult.artistName=dictionary[@"artistName"];
    searchResult.artworkURL60=dictionary[@"artworkUrl60"];
    searchResult.artworkURL100=dictionary[@"artworkUrl100"];
    searchResult.storeURL=dictionary[@"collectionViewUrl"];
    searchResult.kind=@"audiobook";
    searchResult.price=dictionary[@"collectionPrice"];
    searchResult.currency=dictionary[@"currency"];
    searchResult.genre=dictionary[@"primaryGenreName"];
    return searchResult;
}

-(SearchResult *)parseSoftware:(NSDictionary *)dictionary{
    SearchResult *searchResult=[[SearchResult alloc]init];
    searchResult.name=dictionary[@"trackName"];
    searchResult.artistName=dictionary[@"artistName"];
    searchResult.artworkURL60=dictionary[@"artworkUrl60"];
    searchResult.artworkURL100=dictionary[@"artworkUrl100"];
    searchResult.storeURL=dictionary[@"trackViewUrl"];
    searchResult.kind=dictionary[@"kind"];
    searchResult.price=dictionary[@"price"];
    searchResult.currency=dictionary[@"currency"];
    searchResult.genre=dictionary[@"primaryGenreName"];
    return searchResult;
}

-(SearchResult *)parseEbook:(NSDictionary *)dictionary{
    SearchResult *searchResult=[[SearchResult alloc]init];
    searchResult.name=dictionary[@"trackName"];
    searchResult.artistName=dictionary[@"artistName"];
    searchResult.artworkURL60=dictionary[@"artworkUrl60"];
    searchResult.artworkURL100=dictionary[@"artworkUrl100"];
    searchResult.storeURL=dictionary[@"trackViewUrl"];
    searchResult.kind=dictionary[@"kind"];
    searchResult.price=dictionary[@"price"];
    searchResult.currency=dictionary[@"currency"];
    searchResult.genre=[(NSArray *)dictionary[@"genres"]componentsJoinedByString:@", "];
    return searchResult;
}




@end
