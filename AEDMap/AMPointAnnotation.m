//
//  AMPointAnnotaion.m
//  atmos
//
//  Created by 越智 修司 on 2013/04/07.
//  Copyright (c) 2013年 越智 修司. All rights reserved.
//

#import <ADClusterMapView/ADClusterMapView.h>
#import "AMPointAnnotation.h"

@implementation AMPointAnnotation


-(id)initWithCoodinate:(CLLocationCoordinate2D)xcoordinate pointData:(NSDictionary*)xpointData
{
  if( (self = [[AMPointAnnotation alloc] init]) != nil ){
    _coordinate = xcoordinate;
    _pointData = xpointData;
    _title = [_pointData objectForKey:@"施設名称"];
    _subtitle = [_pointData objectForKey:@"設置場所住所"];

  }
  return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
  _coordinate = newCoordinate;
}


@end
