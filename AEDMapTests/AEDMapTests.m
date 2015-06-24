//
//  AEDMapTests.m
//  AEDMapTests
//
//  Created by 越智 修司 on 2015/03/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AMDataManager.h"

@interface AEDMapTests : XCTestCase

@end

@implementation AEDMapTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReadData {
    // This is an example of a functional test case.
  AMDataManager* manager = [AMDataManager sharedInstance];
  [manager loadData];
  NSInteger count = [[manager allList] count];
  XCTAssert( count == 1937, @"件数は1937個であるべきところ、%ld個でした",count);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
