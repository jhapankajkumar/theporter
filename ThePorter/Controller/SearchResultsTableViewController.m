//
//  SearchResultsTableViewController.m
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#import "SearchResultsTableViewController.h"
#import "Parcels.h"
#import "ProductDetailViewController.h"
@interface SearchResultsTableViewController ()
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSArray *array;

@end

@implementation SearchResultsTableViewController

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        
    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"list" forIndexPath:indexPath];
    Parcels *parcel = [self.searchResults objectAtIndex:indexPath.row];
    UILabel *repositoryName =  [(UILabel *)cell viewWithTag:1001];
    
    UILabel *repositoryDescrepion = [(UILabel *)cell viewWithTag:1002];
    repositoryDescrepion.text = @"";
    repositoryName.text = parcel.name;
    
    repositoryDescrepion.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds) - 40;
    repositoryDescrepion.text = [NSString stringWithFormat:@"₹ %ld",(long)parcel.value];
    
    //cell.textLabel.text = self.searchResults[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedIndexPath = indexPath;
        //[self performSegueWithIdentifier:@"SearchTableToDetail" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Class: SearchResultsTableView");
        NSLog(@"Method: didSelectRowAtIndexPath");
    }
}


@end
