//
//  FirstViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/27.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//
#import <CCMPopup/CCMPopupSegue.h>

#import "AMMapViewController.h"
#import "AMDataManager.h"
#import "AMPointAnnotation.h"
#import "AMDataAnnotationView.h"
#import "AMFacilityDetailViewController.h"

@interface AMMapViewController ()
@property (weak, nonatomic) IBOutlet ADClusterMapView *mapView;

@end

@implementation AMMapViewController
{
  BOOL _isInitialLocationShown;
  NSDictionary* _selectedData;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _isInitialLocationShown = YES;

  NSMutableArray * annotations = [[NSMutableArray alloc] init];
  //[self.mapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];
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
  if( _isInitialLocationShown ){
    CLLocation* latestLocation = [locations lastObject];

    // TODO:横展開のために外に出すこと
    // 神戸市のだいたい中心から20キロ以内か

    CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(34.734374,135.134395)
								 radius:20 * 1000 // 20km
							     identifier:@"aroundCity"];
    if( [region containsCoordinate:latestLocation.coordinate] ){
      [self zoomMapAndCenterAtLocation:latestLocation];
    }else{
      UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
								     message:@"エリア外にいるため、神戸市の中心部を表示します"
							      preferredStyle:UIAlertControllerStyleAlert];

      UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
							    handler:^(UIAlertAction * action) {
	  // 市役所にズーム
	  CLLocation* location = [[CLLocation alloc]initWithLatitude:34.689929
							   longitude:135.195614];
	  [self zoomMapAndCenterAtLocation:location];

	}];

      [alert addAction:defaultAction];
      UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel
							   handler:^(UIAlertAction * action) {}];

      [alert addAction:cancelAction];
      [self presentViewController:alert animated:YES completion:nil];


    }
    _isInitialLocationShown = NO;
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

-(void)showDetails
{
  [self performSegueWithIdentifier:@"FromMapViewToDetailView" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"FromMapViewToDetailView"]){
    AMFacilityDetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.title = NSLocalizedString(@"施設詳細",@"");
    detailViewController.pointData = _selectedData;

    CCMPopupSegue *popupSegue = (CCMPopupSegue *)segue;
    popupSegue.destinationBounds = CGRectMake(0,
					      0,
					      self.view.bounds.size.width*0.85,
					      self.view.bounds.size.height*0.65);
    popupSegue.backgroundBlurRadius = 4;
    popupSegue.backgroundViewAlpha = 0.3;
    popupSegue.backgroundViewColor = [UIColor blackColor];
    popupSegue.dismissableByTouchingBackground = YES;

  }
}



#pragma mark - ADClusterMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)_annotation
{
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
    annotationView.frame = CGRectMake(0,0,36,36);

    // Add a detail disclosure button to the callout.
    UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    [rightButton addTarget:self action:@selector(showDetails)
	  forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = rightButton;


    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,24,24)];
    image.image = [UIImage imageNamed:@"aed-icon"];
    [annotationView addSubview:image];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
  Log(@"");
  ADClusterAnnotation* annotation = (ADClusterAnnotation*) view.annotation;

  AMPointAnnotation* originalAnnotation = (AMPointAnnotation*) annotation.originalAnnotations[0];
  _selectedData = originalAnnotation.pointData;
}


- (NSString *)clusterTitleForMapView:(ADClusterMapView *)mapView
{
  return @"%d 施設";
}


- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation
{
  MKAnnotationView * annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ADMapCluster"];
  ADClusterAnnotation* ann = (ADClusterAnnotation*)annotation;
  if (!annotationView) {
    annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
						  reuseIdentifier:@"ADMapCluster"];
    annotationView.backgroundColor = [UIColor clearColor];
    annotationView.frame = CGRectMake(0,0,40,40);
    annotationView.canShowCallout = YES;
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,40,40)];
    image.image = [UIImage imageNamed:@"clustered-Icon"];
    [annotationView addSubview:image];

  }

  return annotationView;
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
