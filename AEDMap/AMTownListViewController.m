//
//  AMTownListViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/05/20.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import "AMTownListViewController.h"
#import "AMDataManager.h"
#import "AMFacilityListViewController.h"
@interface AMTownListViewController ()

@end

@implementation AMTownListViewController
{
  NSArray* _townList;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  AMDataManager* manager = [AMDataManager sharedInstance];
  _townList = [manager townListByWard:self.ward];
  self.navigationItem.title = self.ward;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
    // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return _townList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = _townList[indexPath.row][@"town"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"gotoFacilityList" sender:indexPath];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if( [segue.identifier isEqualToString:@"gotoFacilityList"] ){
    NSIndexPath* indexPath = sender;
    AMFacilityListViewController* vc = [segue destinationViewController];
    AMDataManager* manager = [AMDataManager sharedInstance];
    vc.facilities = [manager facilitiesWithZip:_townList[indexPath.row][@"zip"]];
    vc.town = _townList[indexPath.row][@"town"];
  }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
