//
//  AMWardListViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/05/20.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import "AMWardListViewController.h"
#import "AMTownListViewController.h"

@interface AMWardListViewController ()

@end

@implementation AMWardListViewController
{
  NSArray* _wardList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
  NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wardlist" ofType:@"txt"]];
  _wardList = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  
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
  return _wardList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
  cell.textLabel.text = _wardList[indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"gotoTownList" sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if( [segue.identifier isEqualToString:@"gotoTownList"] ){
    NSIndexPath* indexPath = sender;
    AMTownListViewController* vc = [segue destinationViewController];
    Log1(_wardList[indexPath.row]);
    vc.ward = _wardList[indexPath.row];
  }
}


@end
