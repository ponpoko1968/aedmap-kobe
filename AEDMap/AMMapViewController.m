//
//  FirstViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/27.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import "AMMapViewController.h"

@interface AMMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AMMapViewController
{
  CLLocationManager* _locationManager;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  _locationManager = [[CLLocationManager alloc] init];
  [_locationManager requestWhenInUseAuthorization];
  self.mapView.showsUserLocation=YES;
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
