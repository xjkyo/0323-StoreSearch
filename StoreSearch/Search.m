//
//  Search.m
//  StoreSearch
//
//  Created by XK on 16/4/7.
//  Copyright © 2016年 XK. All rights reserved.
//

#import "Search.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>
static AFHTTPSessionManager *manager = nil;
//This defines a so-called global variable. It sits outside any class or method. It works just like any other variable, except that you can use it from anywhere and it keeps its value until the application ends. However, this is not a regular global variable. The keyword static restricts its use to just this one source file.

@interface Search()
@property (nonatomic,readwrite,strong)NSMutableArray *searchResults;
//inside the Search class you do want full control over the searchResults array and therefore you re-declare it as “readwrite” in the class extension.

@end

@implementation Search

-(void)dealloc{
    NSLog(@"dealloc %@",self);
}

-(void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block{
    NSLog(@"Searching...");
    if ([text length]>0) {
        if (manager) {
            [manager invalidateSessionCancelingTasks:YES];
        }
        self.isLoading=YES;
        self.searchResults=[NSMutableArray arrayWithCapacity:10];
        NSURL *url=[self urlWithSearchText:text category:category];
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer=[AFJSONResponseSerializer serializer];
        [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject){
            //NSLog(@"Success: %@",responseObject);
            NSLog(@"Success!");
            [self parseDictionary:responseObject];
            [self.searchResults sortUsingSelector:@selector(compareName:)];
            self.isLoading=NO;
            block(YES);
        }failure:^(NSURLSessionTask *operation, NSError *error){
            if (error.code == -999) {    //手动取消无需弹框
                return;
            }
            NSLog(@"Failure: %@",error);
            self.isLoading=NO;
            block(NO);
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
            [self.searchResults addObject:searchResult];
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
