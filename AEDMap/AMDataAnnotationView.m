//
//  AMDataAnnotationView.m
//  atmos
//
//  Created by 越智 修司 on 2013/04/14.
//  Copyright (c) 2013年 越智 修司. All rights reserved.
//

#import "AMDataAnnotationView.h"

@implementation AMDataAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
  
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
