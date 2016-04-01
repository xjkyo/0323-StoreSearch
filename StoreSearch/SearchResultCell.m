//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by XK on 16/3/25.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation SearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *selectedView=[[UIView alloc]initWithFrame:CGRectZero];//同理:cell被tableview引用的时候会默认和tableview的宽度一样
    selectedView.backgroundColor=[UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:0.5f];
    self.selectedBackgroundView=selectedView;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [self.artworkImageView cancelImageDownloadTask];
    self.nameLabel=nil;
    self.artistNameLabel=nil;
}

-(void)configureForSearchResult:(SearchResult *)searchResult{
    self.nameLabel.text=searchResult.name;
    //cell.artistNameLabel.text=searchResult.artistName;
    NSString *artistName=searchResult.artistName;
    if (artistName == nil) {
        artistName=@"Unknown";
    }
    NSString *kind=[self kindForDisplay:searchResult.kind];
    self.artistNameLabel.text=[NSString stringWithFormat:@"%@ (%@)",artistName,kind];
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
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

@end
