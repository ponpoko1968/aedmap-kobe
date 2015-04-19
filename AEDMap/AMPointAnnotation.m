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
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize pointData;


-(id)initWithCoodinate:(CLLocationCoordinate2D)_coordinate pointData:(NSDictionary*)_pointData
{
  if( (self = [[AMPointAnnotation alloc] init]) != nil ){
    coordinate = _coordinate;
    pointData = _pointData;
    title = [_pointData objectForKey:@"施設名称"];
    subtitle = [_pointData objectForKey:@"設置場所住所"];
    // Log(@"title:\"%@\"",title);
    // Log(@"subtitle:\"%@\"",subtitle);

  }
  return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
  coordinate = newCoordinate;
}


@end
