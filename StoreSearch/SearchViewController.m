//
//  SearchViewController.m
//  StoreSearch
//
//  Created by XK on 16/3/24.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchResults == nil) {
        return 0;
    }else{
        return [_searchResults count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
//    cell.textLabel.text=_searchResults[indexPath.row];
    SearchResult *searchResult=_searchResults[indexPath.row];
    cell.textLabel.text=searchResult.name;
    cell.detailTextLabel.text=searchResult.artistName;
    return cell;
}

#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _searchResults=[NSMutableArray arrayWithCapacity:10];
    for (int i=0; i<3; i++) {
        //[_searchResults addObject:[NSString stringWithFormat:@"Fake Result %d for '%@'",i,searchBar.text]];
        SearchResult *searchResult=[[SearchResult alloc]init];
        searchResult.name=[NSString stringWithFormat:@"Fake Result %d for",i];
        searchResult.artistName=searchBar.text;
        [_searchResults addObject:searchResult];
    }
    [self.tableView reloadData];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

@end
