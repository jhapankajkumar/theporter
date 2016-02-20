//
//  ParcelListViewController.m
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import "ParcelListViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DataFetchManager.h"
#import "ProductDetailViewController.h"
#import "Parcels.h"
#import "Constants.h"
@interface ParcelListViewController ()
@property (strong, nonatomic) NSMutableArray *parcelDataArray;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) SortType defaultSortType;
@property (nonatomic, assign) OrderBy defaultOrderType;
@property (nonatomic, assign) BOOL isPageRequestValid;

@property (nonatomic, assign) NSIndexPath *selectedIndexPath;

@end

@implementation ParcelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetup];
    [self getParcelList];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialSetup {
    [self.searchBar becomeFirstResponder];
    self.parcelDataArray   = [NSMutableArray new];
    self.parcerListTableView.rowHeight = UITableViewAutomaticDimension;
    self.parcerListTableView.estimatedRowHeight = 50;
    self.bottomView.alpha = 0.7;
    [self.searchBar resignFirstResponder];
}

- (void)showSearchResults {
    [self.searchBar resignFirstResponder];
    if (self.searchBar.text.length>0)
    {
        [self getParcelList];
    }
}

- (void)getParcelList {
    
    @try {
        self.totalPage = 1;
        self.pageNumber = 1;
        self.isPageRequestValid = NO;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        DataFetchManager *dataFetchManager = [DataFetchManager new];
        [dataFetchManager getParcelDataWithCompletionBlock:^(NSMutableArray *result, BOOL success, NSError *error) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success && result.count) {
                self.parcelDataArray  = result;
                [self sortByName:nil];
                self.bottomView.alpha = 1.0;
                [self.parcerListTableView setHidden:NO];
                NSInteger hits = -1;
                hits = [[NSUserDefaults standardUserDefaults] integerForKey:@"hits"];
                
                if (hits == NSNotFound) {
                    hits = 0;
                }
                [[NSUserDefaults standardUserDefaults]setInteger:hits+1 forKey:@"hits"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                self.apihits.text = [NSString stringWithFormat:@"API Hits : %ld",(long)hits+1];
                self.totalRecords.text  = [NSString stringWithFormat:@"Total Parcels : %ld",(long)self.parcelDataArray.count];
            }
            else {
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:APPLICATION_NAME message:OOPS_ERROR delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: ParcelListViewController");
        NSLog(@"Method: getParcelList");
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (self.parcelDataArray && [self.parcelDataArray count])?self.parcelDataArray.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
        Parcels *parcel = [self.parcelDataArray objectAtIndex:indexPath.row];
        UILabel *repositoryName =  [(UILabel *)cell viewWithTag:1001];
        
        UILabel *repositoryDescrepion = [(UILabel *)cell viewWithTag:1002];
        repositoryDescrepion.text = @"";
        repositoryName.text = parcel.name;
        
        repositoryDescrepion.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds) - 40;
        repositoryDescrepion.text = [NSString stringWithFormat:@"₹ %ld",(long)parcel.value];
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Class: ParcelListViewController");
        NSLog(@"Method: cellForRowAtIndexPath");
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        [self.parcerListTableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedIndexPath = indexPath;
        [self.searchBar resignFirstResponder];
        [self performSegueWithIdentifier:@"ParcelListToParcelDetail" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: ParcelListViewController");
        NSLog(@"Method: didSelectRowAtIndexPath");
    }
}

#pragma mark - UISearchBarDelegate Methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    return TRUE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    NSString * searchText =  [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length>0)
    {
        self.searchBar.text = searchText;
        [self getParcelList];
    }
}



-(void)showAlertWithError:(NSError*)aError {
    [[[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:aError.localizedDescription delegate:nil cancelButtonTitle:OK_MESSAGE otherButtonTitles:nil] show];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchBar resignFirstResponder];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)sortByValue:(id)sender {
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value"
                                                 ascending:true];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.parcelDataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    self.parcelDataArray = (NSMutableArray *)sortedArray;
    [self.parcerListTableView reloadData];
    
}
- (IBAction)sortByName:(id)sender {
    
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:true];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.parcelDataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    self.parcelDataArray = (NSMutableArray *)sortedArray;
    [self.parcerListTableView reloadData];
    
}
- (IBAction)sortByWight:(id)sender {
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weight"
                                                 ascending:true];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.parcelDataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    self.parcelDataArray = (NSMutableArray *)sortedArray;
    [self.parcerListTableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]isEqualToString:@"ParcelListToParcelDetail"]) {
        ProductDetailViewController *detailViewController = (ProductDetailViewController *)[segue destinationViewController];
        detailViewController.product = [self.parcelDataArray objectAtIndex:self.selectedIndexPath.row];
    }
}


@end
