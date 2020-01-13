//
//  DetailBViewController.m
//  ABRouterDemo
//
//  Created by HarrisonXi on 2019/4/9.
//  Copyright (c) 2019-2020 harrisonxi.com. All rights reserved.
//

#import "DetailBViewController.h"
#import <ABRouter/ABRouter.h>

@interface DetailBViewController ()

@end

@implementation DetailBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"detailB:%@", self.params[@"detailId"]];
    self.view.backgroundColor = [UIColor blueColor];
}

@end
