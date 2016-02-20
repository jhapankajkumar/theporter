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
#import "SearchResultsTableViewController.h"
@interface ParcelListViewController ()<UISearchResultsUpdating>
@property (strong, nonatomic) NSMutableArray *parcelDataArray;
@property (nonatomic, assign) SortType defaultSortType;
@property (nonatomic, assign) OrderBy defaultOrderType;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

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

    self.parcelDataArray   = [NSMutableArray new];
    self.parcerListTableView.rowHeight = UITableViewAutomaticDimension;
    //self.parcerListTableView.estimatedRowHeight = 50;
    self.bottomView.alpha = 0.7;
    
    // There's no transition in our storyboard to our search results tableview or navigation controller
    // so we'll have to grab it using the instantiateViewControllerWithIdentifier: method
    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
    // Our instance of UISearchController will use searchResults
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    // The searchcontroller's searchResultsUpdater property will contain our tableView.
    self.searchController.searchResultsUpdater = self;
    
    // The searchBar contained in XCode's storyboard is a leftover from UISearchDisplayController.
    // Don't use this. Instead, we'll create the searchBar programatically.
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                       self.searchController.searchBar.frame.origin.y,
                                                       self.searchController.searchBar.frame.size.width, 44.0);
    
    self.parcerListTableView.tableHeaderView = self.searchController.searchBar;
    
}



- (void)getParcelList {
    
    @try {
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




-(void)showAlertWithError:(NSError*)aError {
    [[[UIAlertView alloc] initWithTitle:APPLICATION_NAME message:aError.localizedDescription delegate:nil cancelButtonTitle:OK_MESSAGE otherButtonTitles:nil] show];
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

#pragma mark - UISearchControllerDelegate & UISearchResultsDelegate

// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    // Set searchString equal to what's typed into the searchbar
    NSString *searchString = self.searchController.searchBar.text;
    
    
    [self updateFilteredContentForAirlineName:searchString];
    
    // If searchResultsController
    if (self.searchController.searchResultsController) {
        
        UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
        
        // Present SearchResultsTableViewController as the topViewController
        SearchResultsTableViewController *vc = (SearchResultsTableViewController *)navController.topViewController;
        
        // Update searchResults
        vc.searchResults = self.searchResults;
        
        // And reload the tableView with the new data
        [vc.tableView reloadData];
    }
}

// Update self.searchResults based on searchString, which is the argument in passed to this method
- (void)updateFilteredContentForAirlineName:(NSString *)productName
{
    
    if (productName == nil) {
        
        // If empty the search results are the same as the original data
        self.searchResults = [self.parcelDataArray mutableCopy];
    } else {
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"name contains[c] %@",
                                        productName];
            
            NSArray *results = [self.parcelDataArray filteredArrayUsingPredicate:resultPredicate];
            self.searchResults = (NSMutableArray *)results;

    }
}


@end
