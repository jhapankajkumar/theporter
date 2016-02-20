//
//  GHRepository.h
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface Parcels : NSObject
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * image_link;
@property (nonatomic,strong) NSString * type;
@property (nonatomic) NSInteger  value;
@property (nonatomic) double  weight;
@property (nonatomic) NSInteger  quantiy;
@property (nonatomic,strong) NSString * datetime;
@property (nonatomic,strong) NSString * color;
@property (nonatomic) CLLocationCoordinate2D  location;


@end
