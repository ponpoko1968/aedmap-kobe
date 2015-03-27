//
//  AMDataManager.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/25.
//
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "CSVParser.h"
#import "AMDataManager.h"

static AMDataManager* instance = nil;

@implementation AMDataManager
{
  NSMutableArray* _AEDData;

  // CLLocationをキー、AEDデータを値とした辞書
  NSMutableDictionary* _locationDict;

  // Locationを格納した配列(longitudeをキーにソート済み)
  NSArray* _longitudeArray;

  // Locationを格納した配列(latitudeをキーにソート済み)
  NSArray* _latitudeArray;

  // Locationを格納した配列 _longitudeArray,_latitudeArrayを作るための一時配列
  NSMutableArray* _tempArray;

}

#pragma mark - For Singleton
+ (instancetype)sharedInstance
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });

  return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (instance == nil) {
      instance = [super allocWithZone:zone];
      return instance;
    }
  }
  return nil;
}

-(instancetype)init
{
  self=[super init];
  return self;
}

////////////////////////////////////////////////////////////////
// データ読み込み
////////////////////////////////////////////////////////////////
// 交付番号,管轄,管轄入り交付番号,施設名称,郵便番号,設置場所住所,大カテゴリ,小カテゴリ,緯度,経度,２４H使用可能,区,町名
-(void)loadData
{
  _AEDData = [[NSMutableArray alloc] init];
  _longitudeArray = [[NSMutableArray alloc] init];
  _latitudeArray = [[NSMutableArray alloc] init];
  _tempArray =  [[NSMutableArray alloc] init];
  _locationDict = [[NSMutableDictionary alloc] init];


  NSString *csvFile = [[NSBundle mainBundle] pathForResource:@"aed_list" ofType:@"csv"];
  NSError *err = nil;
  NSString *csvString = [NSString stringWithContentsOfFile:csvFile encoding:NSUTF8StringEncoding error:&err];

  if( !csvString ){
    Log(@"error=%@",err);
  }
  CSVParser *parser =
    [[CSVParser alloc] initWithString:csvString
			    separator:@","
			     hasHeader:NO
			    fieldNames: @[@"交付番号",
					   @"管轄",
					   @"管轄入り交付番号",
					   @"施設名称",
					   @"郵便番号",
					   @"設置場所住所",
					   @"大カテゴリ",
					   @"小カテゴリ",
					   @"緯度",
					   @"経度",
					   @"２４H使用可能",
					   @"区",
					   @"町名"
					  ]];
  [parser parseRowsForReceiver:self selector:@selector(receiveRecord:)];

  // _tempArrayを緯度、経度毎にソートする
  //

    _latitudeArray = [_tempArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
	CLLocation* loc1 = obj1;
	CLLocation* loc2 = obj2;
	if (loc1.coordinate.latitude > loc2.coordinate.latitude) {
          return (NSComparisonResult)NSOrderedDescending;
	}

	if (loc1.coordinate.latitude < loc2.coordinate.latitude) {
          return (NSComparisonResult)NSOrderedAscending;
	}
	return (NSComparisonResult)NSOrderedSame;
      }];



    Log(@"%f,%f,%f",((CLLocation*)[_latitudeArray objectAtIndex:0]).coordinate.latitude,
	((CLLocation*)[_latitudeArray objectAtIndex:[_latitudeArray count]/2]).coordinate.latitude,
	((CLLocation*)[_latitudeArray objectAtIndex:[_latitudeArray count]-1]).coordinate.latitude);

    _longitudeArray = [_tempArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
      CLLocation* loc1 = obj1;
      CLLocation* loc2 = obj2;
      if (loc1.coordinate.longitude > loc2.coordinate.longitude) {
	return (NSComparisonResult)NSOrderedDescending;
      }

      if (loc1.coordinate.longitude < loc2.coordinate.longitude) {
	return (NSComparisonResult)NSOrderedAscending;
      }
      return (NSComparisonResult)NSOrderedSame;
    }];


}

- (void)receiveRecord:(NSDictionary *)aRecord // parserからのコールバック
{

  [_AEDData addObject:aRecord];

  CLLocationDegrees longitude = [aRecord[@"経度"] doubleValue];
  CLLocationDegrees latitude = [aRecord[@"緯度"] doubleValue];
  CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude
						    longitude:longitude];

  [_locationDict setObject:aRecord forKey:
		   [NSString stringWithFormat:@"%f:%f",latitude,longitude]
		   ];
  [_tempArray addObject:location];
}

////////////////////////////////////////////////////////////////
// リージョンに含まれる点を返す
////////////////////////////////////////////////////////////////

-(NSMutableSet*) pointsInRegion:(MKCoordinateRegion) region
{

  CLLocationDegrees latitudeRangeMin = region.center.latitude - region.span.latitudeDelta/2.0;
  CLLocationDegrees latitudeRangeMax = region.center.latitude + region.span.latitudeDelta/2.0;
  Log(@"%f ~ %f",latitudeRangeMin, latitudeRangeMax);
  NSMutableSet* latitudeSet = [NSMutableSet set];
  NSInteger latitudeIndex =  [self searchCoordinates: _latitudeArray
						 start: 0
						   end: [_latitudeArray count] -1
						   val: latitudeRangeMin
					      latitude: YES
			    ];
  Log(@"latitudeIndex=%d",latitudeIndex);
  for(NSInteger i = latitudeIndex; i < [_latitudeArray count]; i++){
    CLLocation* location = [_latitudeArray objectAtIndex:i];
    if(location.coordinate.latitude > latitudeRangeMax){
      break;
    }
    [latitudeSet addObject:location];
  }


  CLLocationDegrees longitudeRangeMin = region.center.longitude - region.span.longitudeDelta/2.0;
  CLLocationDegrees longitudeRangeMax = region.center.longitude + region.span.longitudeDelta/2.0;
  Log(@"%f ~ %f",longitudeRangeMin, longitudeRangeMax);
  NSInteger longitudeIndex =  [self searchCoordinates: _longitudeArray
						  start: 0
						    end: [_longitudeArray count] -1
						    val: longitudeRangeMin
					       latitude: NO
			    ];
  Log(@"longitudeIndex=%d",longitudeIndex);

  NSMutableSet* longitudeSet = [NSMutableSet set];

  for(NSInteger i = longitudeIndex; i < [_longitudeArray count]; i++){
    CLLocation* location = [_longitudeArray objectAtIndex:i];
    if(location.coordinate.longitude > longitudeRangeMax){
      break;
    }
    [longitudeSet addObject:location];
  }
  Log(@"latitudeSet=%d,longitudeSet=%d",[latitudeSet count],[longitudeSet count]);

  [latitudeSet intersectSet:longitudeSet];
  return latitudeSet;
}

// 二分探索で再帰的に範囲に含まれる点群への最初のインデクスを返す
-(NSInteger) searchCoordinates: (NSArray*) coordinates
			 start: (NSInteger) start
			   end: (NSInteger) end
			   val: (CLLocationDegrees) val
		      latitude: (BOOL) latitude
{

  CLLocation* firstLocation = [coordinates objectAtIndex:start];
  CLLocation* mediumLocation = [coordinates objectAtIndex:start+(end - start)/2];
  CLLocation* lastLocation = [coordinates objectAtIndex:end];
  CLLocationDegrees median,first,last;


  if( latitude ){
    first = firstLocation.coordinate.latitude;
    last = lastLocation.coordinate.latitude;
    median = mediumLocation.coordinate.latitude;
  }
  else{

    first = firstLocation.coordinate.longitude;
    last = lastLocation.coordinate.longitude;
    median = mediumLocation.coordinate.longitude;
  }
  //Log(@"val = %f,start=%d(%f) medium=%d(%f) end=%d(%f)",val,start,first,start+(end - start)/2,median,end,last);
  if ( start  == end  ||  end - start  == 1 ){
    //Log(@"(%d) first = %lf val = %lf %@",start,first,val,first < val ? @"SUCCESS":@"fail");
    return start;
  }


  if ( val < first   || val > last ){
    //Log(@"out of range");
    return -1;
  }

  if( val < median ){
    //Log(@"val < median");
    return [self searchCoordinates: coordinates
			     start: start
			       end: start+(end - start)/2
			       val: val
			        latitude:latitude];

  }
  //Log(@"val >= median");
  return [self searchCoordinates: coordinates
			   start: start+(end - start)/2
			     end: end
			     val: val
			latitude: latitude];
}



-(NSArray*) allList
{
  return _AEDData;
}


-(void)activateLocationManager
{
  [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
  [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
  [self.locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  Log(@"%@",error);
  self.locationManager = nil;
  if(error) {
    int code = [error code];
    switch (code) {
      // 位置情報サービスの利用を許可されていない場合
    case kCLErrorDenied:
      // ここでエラーハンドリングを行う
      Log(@"");
      break;
    default:
      break;
    }
  }
}

-(NSDictionary*) pointDataWithLocation:(CLLocation*)location
{
  //  Log(@"location=%@,_locationDict=%d",location,[_locationDict count]);
  NSString* key = [NSString stringWithFormat:@"%f:%f",location.coordinate.latitude,location.coordinate.longitude];
  return [_locationDict objectForKey:key];
}
@end
