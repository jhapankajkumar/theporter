//
//  ProductDetailViewController.m
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "DataFetchManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ProductDetailViewController ()

@end

@implementation ProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setProductInfromation];
    [self showPorductLocation];
    [self downloadProductImage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProductInfromation {
    
    self.title =  self.product.name;
    self.productType.text = self.product.type;
    self.productQuantity.text = [NSString stringWithFormat:@"%ld",(long)self.product.quantiy];
    self.productPrice.text  = [NSString stringWithFormat:@"%ld",(long)self.product.value];
    self.productWeight.text  = [NSString stringWithFormat:@"kg %@",[NSNumber numberWithDouble:self.product.weight]];
    self.productName.text  = self.product.name;
    self.productImage.image = [UIImage imageNamed:@"placeholder.png"];
    self.productColor.backgroundColor = [self colorFromHexString:self.product.color];
    self.productInformationView.layer.borderWidth = 2.0;
    self.productInformationView.layer.borderColor = [UIColor blackColor].CGColor;
    self.productInformationView.layer.cornerRadius = 5.0;
    
    //set datetime
    NSString *dateStr = self.product.datetime;
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    self.dateTimeLabe.text = [NSString stringWithFormat:@"ETA : %@",[dateFormat stringFromDate:date]];
}

-(void)downloadProductImage {
    DataFetchManager *dataManager = [DataFetchManager new];
    self.loadinIndicator.hidden = false;
    [self.loadinIndicator startAnimating ];
    __weak __typeof(&*self)weakSelf = self;
    [dataManager downloadImageWithURL:self.product.image_link withCompletionBock:^(UIImage *image, NSError *error) {
        
        [self.loadinIndicator stopAnimating];
        self.loadinIndicator.hidden = true;
        if (image) {
            weakSelf.productImage.image = image;
        }
    }];
}

- (void)showPorductLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.product.location, 8000, 8000);
    
    region.span.longitudeDelta  = 0.001;
    region.span.latitudeDelta  = 0.001;
    
    [self.locationMapView setRegion:[self.locationMapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = self.product.location;
    //point.title = @"Where am I?";
    //point.subtitle = @"I'm here!!!";
    
    [self.locationMapView addAnnotation:point];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
- (IBAction)zoomIn:(id)sender {
    
    MKCoordinateRegion region;
    //Set Zoom level using Span
    MKCoordinateSpan span;
    region.center=  self.locationMapView.region.center;
    
    span.latitudeDelta= self.locationMapView.region.span.latitudeDelta /2.0002;
    span.longitudeDelta=self.locationMapView.region.span.longitudeDelta /2.0002;
    region.span=span;
    [self.locationMapView setRegion:region animated:TRUE];
    //self.locationMapView.region = region;
    
}
- (IBAction)zoomOut:(id)sender {
    
    MKCoordinateRegion region;
    //Set Zoom level using Span
    MKCoordinateSpan span;
    region.center=  self.locationMapView.region.center;
    
    span.latitudeDelta= self.locationMapView.region.span.latitudeDelta *2;
    span.longitudeDelta=self.locationMapView.region.span.longitudeDelta *2;
    region.span=span;
    [self.locationMapView setRegion:region animated:TRUE];
}
- (IBAction)getUpdatedLocation:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.locationMapView animated:YES];
    DataFetchManager *dataManager = [DataFetchManager new];
    __weak __typeof(&*self)weakSelf = self;
    [dataManager getUpdatedLocaitonForProductWihtName:self.productName.text withCompletionBock:^(CLLocationCoordinate2D locaiton, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.locationMapView animated:YES ];
        if (error == nil) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locaiton, 8000, 8000);
            weakSelf.product.location = locaiton;
            region.span.longitudeDelta  = 0.001;
            region.span.latitudeDelta  = 0.001;
            
            [weakSelf.locationMapView setRegion:[weakSelf.locationMapView regionThatFits:region] animated:YES];
            
        }
    }];
}
- (IBAction)shareButtonClicked:(id)sender {
    
        
        NSArray *objectsToShare = @[self.productName.text,self.product.image_link];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        NSArray *excludedActivities = @[
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        controller.excludedActivityTypes = excludedActivities;
        
        [controller setCompletionHandler:^(NSString *activityType, BOOL completed)
         {
             
             
             NSMutableString *messageString = [[NSMutableString alloc]initWithCapacity:0];
             if ([activityType isEqualToString:@"com.apple.UIKit.activity.SaveToCameraRoll"])
             {
                 [messageString appendString:@" Saved"];
             }
             else if ([activityType isEqualToString:@"com.apple.UIKit.activity.PostToTwitter"])
             {
                 [messageString appendString:@" Posted to twitter"];
             }
             else if ([activityType isEqualToString:@"com.apple.UIKit.activity.Mail"])
             {
                 [messageString appendString:@" Sent by email"];
             }
             else if ([activityType isEqualToString:@"com.apple.UIKit.activity.CopyToPasteboard"])
             {
                 [messageString appendString:@" Copied to pasteboard"];
             }
             else if ([activityType isEqualToString:@"com.apple.UIKit.activity.AssignToContact"])
             {
                 [messageString appendString:@" Assigned to contact"];
             }
             else if ([activityType isEqualToString:@"com.apple.UIKit.activity.Message"])
             {
                 [messageString appendString:@" Sent via message"];
             }
             else if ([activityType isEqualToString:@"com.apple.UIKit.activity.Print"])
             {
                 [messageString appendString:@" Sent to printer"];
             }
             else if ([activityType isEqualToString:@"com.linkedin.LinkedIn.ShareExtension"])
             {
                 [messageString appendString:@" Sent to LinkedIn"];
             }
             else if ([activityType isEqualToString:@"net.whatsapp.WhatsApp.ShareExtension"])
             {
                 [messageString appendString:@" Sent to WhatsApp"];
             }
             
             if (completed == TRUE)
             {
                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:APPLICATION_NAME message:messageString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [alert show];
                 
             }
         }];
        // Present the controller
        [self presentViewController:controller animated:YES completion:nil];

}

@end
