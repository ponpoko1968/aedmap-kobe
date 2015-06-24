//
//  AMFacilityDetailViewController.h
//  AEDMap
//
//  Created by 越智 修司 on 2015/05/17.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AMFacilityDetailViewController : UIViewController<MKMapViewDelegate>
@property(nonatomic) NSDictionary* pointData;
@end
