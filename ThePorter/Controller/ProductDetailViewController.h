//
//  ProductDetailViewController.h
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Parcels.h"

@interface ProductDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UIView *productInformationView;
@property (weak, nonatomic) IBOutlet UILabel *productQuantity;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@property (weak, nonatomic) IBOutlet UIView *productColor;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabe;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productType;
@property (weak, nonatomic) IBOutlet UILabel *productWeight;
@property (weak, nonatomic) IBOutlet UILabel *contactNumber;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadinIndicator;

@property (nonatomic,strong) Parcels *product;
@end
