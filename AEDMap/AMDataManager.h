//
//  AMDataManager.h
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/25.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AMDataManager : NSObject<CLLocationManagerDelegate>

+ (instancetype)sharedInstance;
-(void)activateLocationManager;
-(NSMutableSet*) pointsInRegion:(MKCoordinateRegion) region;
-(NSDictionary*) pointDataWithLocation:(CLLocation*)location;
-(NSArray*) townListByWard:(NSString*)ward;
-(NSArray*) facilitiesWithZip:(NSString*)zip;

@property (strong, nonatomic) CLLocationManager *locationManager;

-(void)loadData;
-(NSArray*) allList;

@end
