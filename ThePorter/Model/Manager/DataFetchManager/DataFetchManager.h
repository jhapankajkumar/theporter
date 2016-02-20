//
//  DataFetchManager.h
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Constants.h"
#import "Parcels.h"

@interface DataFetchManager : NSObject <NSURLSessionDataDelegate>

/*
 * getParcelDataWithCompletionBlock This functions helps us to search data from server. This a block based function.

 CompletionBlock
 * @response
 - status - This is BOOL value, indicating the Regestration was sucessful or not, If YES, sucessful.
 - restult -  list of parser
 - error - This gives an error in case user regestration fails, or if some thing is not set.
 */
- (void)getParcelDataWithCompletionBlock:(void(^) (NSMutableArray* result,BOOL success, NSError *error))completionBlock;


//Method to download image of avatar
- (void)downloadImageWithURL:(NSString *)anImageURL withCompletionBock:(void (^) (UIImage *image, NSError *error))completionBlock;


- (void)getUpdatedLocaitonForProductWihtName:(NSString *)productName withCompletionBock:(void (^) (CLLocationCoordinate2D locaiton, NSError *error))completionBlock;



@end
