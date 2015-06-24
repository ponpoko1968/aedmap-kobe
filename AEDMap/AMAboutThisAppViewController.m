//
//  AMAboutThisAppViewController.m
//  AEDMap
//
//  Created by 越智 修司 on 2015/06/22.
//  Copyright (c) 2015年 越智 修司. All rights reserved.
//

#import "AMAboutThisAppViewController.h"
#import <UIWebView-Markdown/UIWebView+Markdown.h>

@interface AMAboutThisAppViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AMAboutThisAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  NSString* path  = [[NSBundle mainBundle] pathForResource:@"AboutThisApp" ofType:@"md"];

  NSString* markdown = [NSString stringWithContentsOfFile:path
						 encoding:NSUTF8StringEncoding
						    error: nil];
  Log1(markdown);
  [self.webView loadMarkdownString:markdown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
