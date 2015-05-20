//
//  AMFacilityListViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/05/20.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//
#import <CCMPopup/CCMPopupSegue.h>


#import "AMFacilityListViewController.h"
#import "AMFacilityDetailViewController.h"

@interface AMFacilityListViewController ()

@end

@implementation AMFacilityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = self.town;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {


  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return self.facilities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = self.facilities[indexPath.row][@"施設名称"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"gotoFacilityDetailFromAddress" sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"gotoFacilityDetailFromAddress"]){
    AMFacilityDetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.title = NSLocalizedString(@"施設詳細",@"");
    NSIndexPath* indexPath = sender;
    detailViewController.pointData = _facilities[indexPath.row];

    CCMPopupSegue *popupSegue = (CCMPopupSegue *)segue;
    popupSegue.destinationBounds = CGRectMake(0,
					      0,
					      self.view.bounds.size.width*0.85,
					      self.view.bounds.size.height*0.65);
    popupSegue.backgroundBlurRadius = 3;
    popupSegue.backgroundViewAlpha = 0.3;
    popupSegue.backgroundViewColor = [UIColor blackColor];
    popupSegue.dismissableByTouchingBackground = YES;

  }
    // Pass the selected object to the new view controller.
}


@end
