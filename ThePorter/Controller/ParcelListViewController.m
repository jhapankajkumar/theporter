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

@interface ParcelListViewController ()<UISearchResultsUpdating,UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *parcelDataArray;
@property (nonatomic, assign) SortType defaultSortType;
@property (nonatomic, assign) OrderBy defaultOrderType;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) NSIndexPath *selectedIndexPath;

@end

@implementation ParcelListViewController

#pragma mark - ViewlifeCycle
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

-(void)viewWillDisappear:(BOOL)animated {
    
    if (self.searchController.isActive && ![self.searchController.searchBar.text isEqualToString:@""]) {
        [self.searchController dismissViewControllerAnimated:NO completion:^{
            //[self.searchController setActive:NO];
            self.navigationController.navigationBarHidden = false;
        }];
    }
    
}

#pragma mark - ActionMethods
- (IBAction)sortByValue:(id)sender {
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value"
                                                 ascending:false];
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


#pragma mark - Private Methods

-(void)initialSetup {
    
    self.parcelDataArray   = [NSMutableArray new];
    self.searchResults = [NSMutableArray new];
    self.parcerListTableView.rowHeight = UITableViewAutomaticDimension;
    self.parcerListTableView.estimatedRowHeight = 50;
    self.bottomView.alpha = 0.7;
    
    // There's no transition in our storyboard to our search results tableview or navigation controller
    // so we'll have to grab it using the instantiateViewControllerWithIdentifier: method
    //UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TableSearchResultsNavController"];
    
    self.searchController.definesPresentationContext = true;
    
    // Our instance of UISearchController will use searchResults
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    // The searchcontroller's searchResultsUpdater property will contain our tableView.
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]isEqualToString:@"ParcelListToParcelDetail"]) {
        ProductDetailViewController *detailViewController = (ProductDetailViewController *)[segue destinationViewController];
        if (self.searchController.isActive && ![self.searchController.searchBar.text isEqualToString:@""]) {
            detailViewController.product = [self.searchResults objectAtIndex:self.selectedIndexPath.row];
        }
        else {
            detailViewController.product = [self.parcelDataArray objectAtIndex:self.selectedIndexPath.row];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (self.searchController.isActive && ![self.searchController.searchBar.text isEqualToString:@""]) {
        return self.searchResults.count;
    }
    else{
        // Return the number of rows in the section.
        return (self.parcelDataArray && [self.parcelDataArray count])?self.parcelDataArray.count:0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
        Parcels *parcel = nil;
        if (self.searchController.isActive && ![self.searchController.searchBar.text isEqualToString:@""]) {
            parcel = [self.searchResults objectAtIndex:indexPath.row];
        }
        else {
            parcel = [self.parcelDataArray objectAtIndex:indexPath.row];
        }
        
        
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

#pragma mark - UISearchControllerDelegate & UISearchResultsDelegate
// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    // Set searchString equal to what's typed into the searchbar
    NSString *searchString = self.searchController.searchBar.text;
    [self updateFilteredContentForAirlineName:searchString];
    
}



// Update self.searchResults based on searchString, which is the argument in passed to this method
- (void)updateFilteredContentForAirlineName:(NSString *)searchText
{
    
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"name contains[c] %@",
                                    searchText];
    
    NSArray *results = [self.parcelDataArray filteredArrayUsingPredicate:resultPredicate];
    self.searchResults = (NSMutableArray *)results;
    [self.parcerListTableView reloadData];
}


@end
