//
//  Search.h
//  StoreSearch
//
//  Created by XK on 16/4/7.
//  Copyright © 2016年 XK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SearchBlock)(BOOL success);

@interface Search : NSObject
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,readonly,strong) NSMutableArray *searchResults;
-(void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;
@end
