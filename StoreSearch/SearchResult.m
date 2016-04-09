//
//  SearchResult.m
//  StoreSearch
//
//  Created by XK on 16/3/25.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

-(NSComparisonResult)compareName:(SearchResult *)other{
    return [self.name localizedStandardCompare:other.name];
}

-(NSString *)kindForDisplay{
    if ([self.kind isEqualToString:@"album"]) {
        //return @"Album";
        return NSLocalizedString(@"Album", @"Localized kind:Album");
    }else if ([self.kind isEqualToString:@"audiobook"]){
        return NSLocalizedString(@"Audio Book", @"Localized kind:Audio Book");
    }else if ([self.kind isEqualToString:@"book"]){
        return NSLocalizedString(@"Book", @"Localized kind:Book");
    }else if ([self.kind isEqualToString:@"ebook"]){
        return NSLocalizedString(@"E-Book", @"Localized kind:E-Book");
    }else if ([self.kind isEqualToString:@"feature-movie"]){
        return NSLocalizedString(@"Movie", @"Localized kind:Movie");
    }else if ([self.kind isEqualToString:@"music-video"]){
        return NSLocalizedString(@"Music Video", @"Localized kind:Music Video");
    }else if ([self.kind isEqualToString:@"podcast"]){
        return NSLocalizedString(@"Podcast", @"Localized kind:Podcast");
    }else if ([self.kind isEqualToString:@"software"]){
        return NSLocalizedString(@"App", @"Localized kind:Software");
    }else if ([self.kind isEqualToString:@"song"]){
        return NSLocalizedString(@"Song", @"Localized kind:Song");
    }else if ([self.kind isEqualToString:@"tv-episode"]){
        return NSLocalizedString(@"TV Episode", @"Localized kind:TV Episode");
    }else{
        return self.kind;
    }
}


@end
