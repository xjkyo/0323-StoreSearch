//
//  SearchViewController.m
//  StoreSearch
//
//  Created by XK on 16/3/24.
//  Copyright © 2016年 XK. All rights reserved.
//  v0.1

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

static NSString * const SearchResultCellIdentifier=@"SearchResultCell";
static NSString * const NothingFoundCellIdentifier=@"NothingFoundCell";

@interface SearchViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
//A nib, the user interface of a view controller, is owned by that view controller.
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController{
    NSMutableArray *_searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset=UIEdgeInsetsMake(64, 0, 0, 0);
    UINib *cellNib=[UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    cellNib=[UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    self.tableView.rowHeight=80;
    
    [self.searchBar becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchResults == nil) {
        return 0;
    }else if([_searchResults count]==0){
        return 1;
    }else{
        return [_searchResults count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if([_searchResults count]==0){
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
    }else{
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        SearchResult *searchResult=_searchResults[indexPath.row];
        cell.nameLabel.text=searchResult.name;
        //cell.artistNameLabel.text=searchResult.artistName;
        NSString *artistName=searchResult.artistName;
        if (artistName == nil) {
            artistName=@"Unknown";
        }
        NSString *kind=[self kindForDisplay:searchResult.kind];
        cell.artistNameLabel.text=[NSString stringWithFormat:@"%@ (%@)",artistName,kind];
        return cell;
    }
}

-(NSString *)kindForDisplay:(NSString *)kind{
    if ([kind isEqualToString:@"album"]) {
        return @"Album";
    }else if ([kind isEqualToString:@"audiobook"]){
        return @"Audio Book";
    }else if ([kind isEqualToString:@"book"]){
        return @"Book";
    }else if ([kind isEqualToString:@"ebook"]){
        return @"E-Book";
    }else if ([kind isEqualToString:@"feature-movie"]){
        return @"Movie";
    }else if ([kind isEqualToString:@"music-video"]){
        return @"Music Video";
    }else if ([kind isEqualToString:@"podcast"]){
        return @"Podcase";
    }else if ([kind isEqualToString:@"software"]){
        return @"App";
    }else if ([kind isEqualToString:@"song"]){
        return @"Song";
    }else if ([kind isEqualToString:@"tv-episode"]){
        return @"TV Episode";
    }else{
        return kind;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([_searchResults count]==0){
        return nil;//it may still turn gray if you hold down on the row for a short while. That is because you did not change the selectionStyle property of the cell.
    }else{
        return indexPath;
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
    if([searchBar.text length]>0){
        [searchBar resignFirstResponder];
        _searchResults=[NSMutableArray arrayWithCapacity:10];
        NSURL *url=[self urlWithSearchText:searchBar.text];
        NSLog(@"URL '%@'",url);
        NSString *jsonString=[self performStoreRequestWithURL:url];
        if (jsonString == nil) {
            [self showNetworkError];
            return;
        }
        NSDictionary *dictionary=[self parseJSON:jsonString];
        if (dictionary == nil) {
            [self showNetworkError];
            return;
        }
        NSLog(@"Dictionary '%@'",dictionary);
        [self parseDictionary:dictionary];
        [_searchResults sortUsingSelector:@selector(compareName:)];
        [self.tableView reloadData];
    }
}

-(NSURL *)urlWithSearchText:(NSString *)searchText{
    //NSString *escapedSearchText=[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *escapedSearchText=[searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString=[NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@",escapedSearchText];
    NSURL *url=[NSURL URLWithString:urlString];
    return url;
}

-(NSString *)performStoreRequestWithURL:(NSURL *)url{
    NSError *error;
    NSString *resultString=[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if(resultString==nil){
        NSLog(@"Download Error:%@",error);
        return nil;
    }
    return resultString;
}

#pragma mark - Parsing JSON 
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
}

-(void)parseDictionary:(NSDictionary *)dictionary{
    //NSArray *array=dictionary[@"results"];
    NSArray *array=[dictionary objectForKey:@"results"];
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
