//
//  DetailAViewController.m
//  ABRouterDemo
//
//  Created by HarrisonXi on 2019/4/9.
//  Copyright (c) 2019-2020 harrisonxi.com. All rights reserved.
//

#import "DetailAViewController.h"
#import <ABRouter/ABRouter.h>

@interface DetailAViewController ()

@end

@implementation DetailAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"detailA:%@", self.params[@"detailId"]];
    self.view.backgroundColor = [UIColor redColor];
}

@end
