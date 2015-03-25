//
//  AMDataManager.h
//  AEDMap
//
//  Created by 越智 修司 on 2015/03/25.
//
//

#import <Foundation/Foundation.h>

@interface AMDataManager : NSObject

+ (instancetype)sharedClient;


-(void)loadData;
-(NSArray*) allList;

@end
