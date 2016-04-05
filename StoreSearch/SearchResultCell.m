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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *selectedView=[[UIView alloc]initWithFrame:CGRectZero];//同理:cell被tableview引用的时候会默认和tableview的宽度一样
    selectedView.backgroundColor=[UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:0.5f];
    self.selectedBackgroundView=selectedView;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [self.artworkImageView cancelImageDownloadTask];
    self.nameLabel.text=nil;        //There was a BUG here:self.nameLabel=nil; 造成问题：第一次搜Southpark，tableView显示正常，再搜Batman，tableView显示的name和artistName仍然是Southpark的结果
    self.artistNameLabel.text=nil;
}

-(void)configureForSearchResult:(SearchResult *)searchResult{
    self.nameLabel.text=searchResult.name;
    //cell.artistNameLabel.text=searchResult.artistName;
    NSString *artistName=searchResult.artistName;
    if (artistName == nil) {
        artistName=@"Unknown";
    }
    NSString *kind=[searchResult kindForDisplay];
    self.artistNameLabel.text=[NSString stringWithFormat:@"%@ (%@)",artistName,kind];
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}


@end
