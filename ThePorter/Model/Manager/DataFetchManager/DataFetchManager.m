//
//  DataFetchManager.m
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//


#import "DataFetchManager.h"
#import "Constants.h"

#define AccessToken  @"80f1c9a49d0e54a43814c30d0aad12bd127cde34"

@implementation DataFetchManager

- (void)getParcelDataWithCompletionBlock:(void(^) (NSMutableArray* result,BOOL success, NSError *error))completionBlock {
    
    @try {
        
        
        
        NSURL *url = [NSURL URLWithString:@"https://api-test.theporter.in/interview_api/parcels/all_parcels.json"];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:queue];
        
        NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error == nil) {
                
                NSMutableArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSMutableArray *parcelArray = [NSMutableArray new];
                if (dataArray.count ) {
                    for (NSDictionary *dict in dataArray) {
                        
                        Parcels *parcel = [Parcels new];
                        parcel.name = [dict objectForKey:@"name"];
                        parcel.image_link = [dict objectForKey:@"image_link"];
                        parcel.type = [dict objectForKey:@"type"];
                        parcel.weight = [[dict objectForKey:@"weight"] doubleValue];
                        parcel.quantiy = [[dict objectForKey:@"quantity"] integerValue];
                        parcel.value = [[dict objectForKey:@"value"] integerValue];
                        parcel.color = [dict objectForKey:@"color"];
                        parcel.datetime = [dict objectForKey:@"datetime"];
                        
                        CLLocationCoordinate2D coordiante = CLLocationCoordinate2DMake([[[dict objectForKey:@"current_location"] objectForKey:@"lat"]doubleValue], [[[dict objectForKey:@"current_location"] objectForKey:@"long"]doubleValue]);
                        parcel.location = coordiante;
                        [parcelArray addObject:parcel];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(parcelArray,true,nil);
                    });
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil,false,nil);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,false,error);
                });
            }
            
        }];
        
        [task resume];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Class: DataFetchManager");
        NSLog(@"Method: SearchRepositoryData");
    }
}



- (void)downloadImageWithURL:(NSString *)anImageURL withCompletionBock:(void (^) (UIImage *image, NSError *error))completionBlock {
    
    NSURL *url = [NSURL URLWithString:anImageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //Downloading image using NSURLSession
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error==nil) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image,nil);
            });
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,error);
            });
        }
    } ];
    
    [dataTask resume];
}


- (void)getUpdatedLocaitonForProductWihtName:(NSString *)productName withCompletionBock:(void (^) (CLLocationCoordinate2D locaiton, NSError *error))completionBlock {
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-test.theporter.in/interview_api/parcels/latest_location.json?name=%@",productName]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //Downloading image using NSURLSession
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error==nil) {
            NSDictionary *locationDicitonary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            CLLocationCoordinate2D  location = CLLocationCoordinate2DMake([[locationDicitonary objectForKey:@"lat"] doubleValue], [[locationDicitonary objectForKey:@"long"]doubleValue]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(location,nil);
            });
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CLLocationCoordinate2D  location = CLLocationCoordinate2DMake(0, 0) ;
                completionBlock(location,error);
            });
        }
    } ];
    
    [dataTask resume];
}

@end
