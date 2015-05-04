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
@property (weak, nonatomic) IBOutlet ADClusterMapView *mapView;

@end

@implementation AMMapViewController
{
  BOOL _observerRemoved;

}

- (void)viewDidLoad {
  [super viewDidLoad];


  NSMutableArray * annotations = [[NSMutableArray alloc] init];
  [self.mapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];
  self.mapView.showsUserLocation = YES;

  NSLog(@"Loading data…");
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      AMDataManager* manager = [AMDataManager sharedInstance];



      for (NSDictionary * aRecord in manager.allList) {
	CLLocationDegrees longitude = [aRecord[@"経度"] doubleValue];
	CLLocationDegrees latitude = [aRecord[@"緯度"] doubleValue];
	CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude
							  longitude:longitude];

	AMPointAnnotation* annotation = [[AMPointAnnotation alloc] initWithCoodinate:location.coordinate
									  pointData:aRecord];

	[annotations addObject:annotation];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
	  NSLog(@"Building KD-Tree…");
	  [self.mapView setAnnotations:annotations];
        });
    });

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

    // TODO:横展開のために外に出すこと
    // 神戸市のだいたい中心から20キロ以内か
    CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(34.734374,135.134395)
							       radius:20 * 1000 // 20km
							   identifier:@"aroundCity"];
    if( [region containsCoordinate:latestLocation.coordinate] ){
      [self zoomMapAndCenterAtLocation:latestLocation];
    }else{
      // 市役所にズーム
       CLLocation* location = [[CLLocation alloc]initWithLatitude:34.689929
							longitude:135.195614];
       [self zoomMapAndCenterAtLocation:location];
    }
    @try{
      [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    }
    @catch(NSException* exception){
    }
    _observerRemoved = YES;

  }

}



// 指定地点へ地図を移動させてズームレベルを変更する.
- (void) zoomMapAndCenterAtLocation:(CLLocation*) location

{
  Log(@"lon=%lf lat=%lf",location.coordinate.longitude,location.coordinate.latitude);
  MKCoordinateRegion region;
  region.center.latitude  = location.coordinate.latitude;
  region.center.longitude = location.coordinate.longitude;
  MKCoordinateSpan span;
  span.latitudeDelta  = 0.05;
  span.longitudeDelta = 0.05;
  region.span = span;
  [self.mapView setRegion:region animated:YES];
}

#pragma mark - ADClusterMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)_annotation
{
  Log(@"%@",[[_annotation class] description]);
  if ([_annotation isKindOfClass:[MKUserLocation class]])
    return nil;

    AMPointAnnotation* annotation = _annotation;
    AMDataAnnotationView* annotationView
      = (AMDataAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
    if (!annotationView) {
      annotationView = [[AMDataAnnotationView alloc] initWithAnnotation:annotation
							reuseIdentifier:@"annotation"];

    }
    annotationView.canShowCallout = YES;
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.frame = CGRectMake(0,0,16,16);
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,16,16)];
    image.image = [UIImage imageNamed:@"aed-icon"];
    [annotationView addSubview:image];
    return annotationView;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  Log(@"lat=%f,long=%f",self.mapView.userLocation.location.coordinate.latitude,
      self.mapView.userLocation.location.coordinate.longitude );
}

- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation {
  MKAnnotationView * pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ADMapCluster"];
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:@"ADMapCluster"];
        pinView.image = [UIImage imageNamed:@"second"];
        pinView.canShowCallout = NO;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}


- (void)mapViewDidFinishClustering:(ADClusterMapView *)mapView {
    NSLog(@"Done");
}

- (NSInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView {
    return 40;
}

- (double)clusterDiscriminationPowerForMapView:(ADClusterMapView *)mapView {
    return 1.8;
}
@end
