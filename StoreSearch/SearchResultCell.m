//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by XK on 16/3/25.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *selectedView=[[UIView alloc]initWithFrame:CGRectZero];//同理:cell被tableview引用的时候会默认和tableview的宽度一样
    selectedView.backgroundColor=[UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:0.5f];
    self.selectedBackgroundView=selectedView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
