//
//  FirstViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/27.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import "AMMapViewController.h"
#import "AMDataManager.h"
#import "AMPointAnnotation.h"
#import "AMDataAnnotationView.h"

@interface AMMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AMMapViewController
{
  BOOL _observerRemoved;
  NSMutableDictionary* _locationDict;
  NSMutableSet*	       _oldPoints;
  NSDictionary*	       _selectedData;
  MKCoordinateSpan     _maximumDisplayableSpan;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _locationDict = [[NSMutableDictionary alloc] init];
  _maximumDisplayableSpan = MKCoordinateSpanMake(0.05,0.05);

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
  AMDataManager* manager = [AMDataManager sharedInstance];
  manager.locationManager.delegate = self;

  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

  if( status == kCLAuthorizationStatusAuthorizedAlways
      || status  == kCLAuthorizationStatusAuthorizedWhenInUse ){
    self.mapView.showsUserLocation=YES;
    [manager.locationManager startUpdatingLocation];
  }else if( status == kCLAuthorizationStatusDenied ){

  }else if( status == kCLAuthorizationStatusNotDetermined ){
    [manager.locationManager requestWhenInUseAuthorization];
  }
}

-(void)viewWillDisappear:(BOOL)animated
{
  AMDataManager* manager = [AMDataManager sharedInstance];
  manager.locationManager.delegate = nil;
}

- (void)locationManager:(CLLocationManager *)locationManager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  if( status == kCLAuthorizationStatusAuthorizedAlways
      || status  == kCLAuthorizationStatusAuthorizedWhenInUse ){
    [locationManager startUpdatingLocation];
    self.mapView.showsUserLocation=YES;
  }else{
    self.mapView.showsUserLocation=NO;
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation* latestLocation = [locations lastObject];
  
  Log(@"%f,%f",latestLocation.coordinate.latitude,latestLocation.coordinate.longitude);
  if(latestLocation.coordinate.longitude  == 0.0){
    Log(@"赤道上の位置");
    _observerRemoved = NO;
    return;
  }
  if( !_observerRemoved ){
    [self zoomMapAndCenterAtLatitude:latestLocation.coordinate.latitude
			andLongitude:latestLocation.coordinate.longitude];
    _observerRemoved = YES;
  }

}

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated
{


  MKCoordinateRegion region = self.mapView.region;
  if( region.span.latitudeDelta >   _maximumDisplayableSpan.latitudeDelta
      ||  region.span.longitudeDelta > _maximumDisplayableSpan.longitudeDelta ){
    return;
  }


  AMDataManager* manager = [AMDataManager sharedInstance];
  NSMutableSet* pointsInRegion = [manager pointsInRegion:self.mapView.region];






  // 集合演算でリージョンから出たポイントを取り除く
  if( _oldPoints ){
    NSMutableSet* pointsToDeleted = [NSMutableSet setWithSet:_oldPoints];
    [pointsToDeleted unionSet:pointsInRegion];
    [pointsToDeleted minusSet:pointsInRegion];
    for( CLLocation* location in pointsToDeleted){
      NSString* locationString = [NSString stringWithFormat:@"%lf:%lf",location.coordinate.latitude,location.coordinate.longitude];

      AMPointAnnotation* annotation = [_locationDict objectForKey:locationString];

      if( annotation ){		// 必ず存在するはずだけど、念のため
	[self.mapView removeAnnotation:annotation];
	[_locationDict removeObjectForKey:locationString];
      }else{
	Log(@"warn:annotation not found");
      }
    }
  }

  if( ! _oldPoints){
    _oldPoints = [[NSMutableSet alloc] init];
  }

  // 集合演算でリージョンに入ったポイントのみを追加する

  NSMutableSet* pointsToAdded = [NSMutableSet setWithSet:_oldPoints];
  [pointsToAdded unionSet:pointsInRegion];
  [pointsToAdded minusSet:_oldPoints];

  for( CLLocation* location in pointsToAdded){
    NSString* locationString = [NSString stringWithFormat:@"%lf:%lf",location.coordinate.latitude,location.coordinate.longitude];

    AMPointAnnotation* annotation = [_locationDict objectForKey:locationString];
    if( annotation ){
      [self.mapView removeAnnotation:annotation];
      [_locationDict removeObjectForKey:locationString];
    }else{
      NSDictionary* pointData = [manager pointDataWithLocation:location];
      annotation = [[AMPointAnnotation alloc] initWithCoodinate:location.coordinate pointData:pointData];
      [_locationDict setObject:annotation forKey:locationString];
      [self.mapView addAnnotation:annotation];
    }

  }
  Log(@"annotations=%d",[self.mapView.annotations count]);


  [_oldPoints setSet:pointsInRegion];
}



// 指定地点へ地図を移動させてズームレベルを変更する.
- (void) zoomMapAndCenterAtLatitude:(double) latitude andLongitude:(double) longitude
{
    MKCoordinateRegion region;
    region.center.latitude  = latitude;
    region.center.longitude = longitude;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.05;
    span.longitudeDelta = 0.05;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView
	    viewForAnnotation:(id <MKAnnotation>)_annotation
{
  Log(@"");
  if ([_annotation isKindOfClass:[MKUserLocation class]])
    return nil;
  if ([_annotation isKindOfClass:[AMPointAnnotation class]]) {
    AMPointAnnotation* annotation = _annotation;
    // Try to dequeue an existing pin view first.
    // NSString* pointID = [annotation.pointData objectForKey:@"point_id"];
    AMDataAnnotationView* annotationView
      = (AMDataAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
    if (!annotationView) {
      // If an existing pin view was not available, create one.
      annotationView = [[AMDataAnnotationView alloc] initWithAnnotation:annotation
							reuseIdentifier:@"annotation"];

    }
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.frame = CGRectMake(0,0,16,16);
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,16,16)];
    image.image = [UIImage imageNamed:@"aed-icon"];
    [annotationView addSubview:image];
    return annotationView;
  }
  return nil;
}
@end
