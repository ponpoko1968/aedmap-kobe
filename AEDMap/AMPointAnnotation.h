//
//  AMPointAnnotaion.h
//  atmos
//
//  Created by 越智 修司 on 2013/04/07.
//  Copyright (c) 2013年 越智 修司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AMPointAnnotation : NSObject<MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSDictionary *pointData;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
-(id)initWithCoodinate:(CLLocationCoordinate2D)_coordinate pointData:(NSDictionary*)_pointData;


@end
