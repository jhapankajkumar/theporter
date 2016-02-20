//
//  ParcelListViewController.h
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@interface ParcelListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *apihits;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *parcerListTableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *totalRecords;
@end
