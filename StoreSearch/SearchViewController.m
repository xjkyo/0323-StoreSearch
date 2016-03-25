//
//  SearchViewController.m
//  StoreSearch
//
//  Created by XK on 16/3/24.
//  Copyright © 2016年 XK. All rights reserved.
//  git tag v0.1

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
        //cell.nameLabel.text=@"(Nothing found)";
        //cell.artistNameLabel.text=@"";
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
    }else{
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        SearchResult *searchResult=_searchResults[indexPath.row];
        cell.nameLabel.text=searchResult.name;
        cell.artistNameLabel.text=searchResult.artistName;
        return cell;
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
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _searchResults=[NSMutableArray arrayWithCapacity:10];
    if(![searchBar.text isEqualToString:@"Null"]){
        for (int i=0; i<3; i++) {
            //[_searchResults addObject:[NSString stringWithFormat:@"Fake Result %d for '%@'",i,searchBar.text]];
            SearchResult *searchResult=[[SearchResult alloc]init];
            searchResult.name=[NSString stringWithFormat:@"Fake Result %d for",i];
            searchResult.artistName=searchBar.text;
            [_searchResults addObject:searchResult];
        }
    }
    [self.tableView reloadData];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

@end
