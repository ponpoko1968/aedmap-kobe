//
//  AMDataManager.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/25.
//
//
#import "CSVParser.h"
#import "AMDataManager.h"

static AMDataManager* instance = nil;

@implementation AMDataManager
{
  NSMutableArray* _AEDData;
}

#pragma mark - For Singleton
+ (instancetype)sharedClient
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
// 交付番号,管轄,管轄入り交付番号,施設名称,郵便番号,設置場所住所,大カテゴリ,小カテゴリ,緯度,経度,２４H使用可能,区,町名
-(void)loadData
{
  _AEDData = [[NSMutableArray alloc] init];

  NSString *csvFile = [[NSBundle mainBundle] pathForResource:@"calendar" ofType:@"tsv"];
  NSError *err = nil;
  NSString *csvString = [NSString stringWithContentsOfFile:csvFile encoding:NSUTF8StringEncoding error:&err];

  if( !csvString ){
    Log(@"error=%@",err);
  }
  CSVParser *parser =
    [[CSVParser alloc] initWithString:csvString
			    separator:@"\t"
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
}

- (void)receiveRecord:(NSDictionary *)aRecord // parserからのコールバック
{
  [aRecord setValue: [NSNumber numberWithInt:[[aRecord objectForKey:@"ageOfDeath"] intValue]]
	     forKey: @"ageOfDeath"];

  [_AEDData addObject:aRecord];


}

@end
