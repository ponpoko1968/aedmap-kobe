//
//  AMFacilityDetailViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/05/17.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import "AMFacilityDetailViewController.h"
#import "AMPointAnnotation.h"

@interface AMFacilityDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *facilityName;
@property (weak, nonatomic) IBOutlet UILabel *majorCategory;
@property (weak, nonatomic) IBOutlet UILabel *minorCategory;
@property (weak, nonatomic) IBOutlet UILabel *zipCode;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *available24H;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AMFacilityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.facilityName.text = self.pointData[@"施設名称"];
    self.majorCategory.text = self.pointData[@"大カテゴリ"];
    self.minorCategory.text = self.pointData[@"小カテゴリ"];
    self.zipCode.text = self.pointData[@"郵便番号"];
    self.address.text = self.pointData[@"設置場所住所"];
    self.available24H.text = [self.pointData[@"２４H使用可能"] isEqualToString:@"○"]
      ? @"２４時間使用可"
      : @"使用可能時間帯に制限あり";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
  [self zoomMapAndCenter];

}

-(void)zoomMapAndCenter
{
 CLLocationDegrees longitude = [self.pointData[@"経度"] doubleValue];
  CLLocationDegrees latitude = [self.pointData[@"緯度"] doubleValue];
  CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude
						    longitude:longitude];

  AMPointAnnotation* annotation = [[AMPointAnnotation alloc] initWithCoodinate:location.coordinate
								     pointData:self.pointData];
  [self.mapView addAnnotation:annotation];
  MKCoordinateRegion region;
  region.center.latitude  = latitude;
  region.center.longitude = longitude;
  MKCoordinateSpan span;
  span.latitudeDelta  = 0.1;
  span.longitudeDelta = 0.1;
  region.span = span;
  [self.mapView setRegion:region animated:NO];  
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
  Log0();
  [self zoomMapAndCenter];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
