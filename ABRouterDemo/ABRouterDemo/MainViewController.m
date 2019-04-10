//
//  MainViewController.m
//  ABRouterDemo
//
//  Created by HarrisonXi on 2019/4/3.
//  Copyright (c) 2019 harrisonxi.com. All rights reserved.
//

#import "MainViewController.h"
#import <ABRouter/ABRouter.h>
#import "ListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = @"ABRouterDemo";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // map to a controller block
    [[ABRouter shared] map:@"/list" toControllerBlock:^UIViewController *(NSDictionary *params) {
        // do some addtional things here
        return [ListViewController new];
    }];
    
    // map to controller classes with ab option
    [[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailAViewController") abOption:ABRouterOptionA];
    [[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailBViewController") abOption:ABRouterOptionB];
    
    // map to action block
    __weak MainViewController *weakSelf = self;
    [[ABRouter shared] map:@"/alert/:msg" toActionBlock:^id(NSDictionary *params) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:params[@"title"]
                                                                       message:params[@"msg"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
        return @(YES);
    }];
    
    // add buttons
    CGFloat width = self.view.bounds.size.width - 40;
    CGFloat offsetY = 20;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, offsetY, width, 40)];
    [button setTitle:@"go to list" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    offsetY += 40 + 10;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(20, offsetY, width, 40)];
    [button setTitle:@"go to detail with option A" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoDetailA:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    offsetY += 40 + 10;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(20, offsetY, width, 40)];
    [button setTitle:@"go to detail with option B" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoDetailB:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    offsetY += 40 + 10;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(20, offsetY, width, 40)];
    [button setTitle:@"show alert" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showAlert:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    offsetY += 40 + 10;
}

- (void)gotoList:(id)sender {
    UIViewController *vc = [[ABRouter shared] matchController:@"/list"];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)gotoDetailA:(id)sender {
    UIViewController *vc = [[ABRouter shared] matchController:@"/detail/1" abOption:ABRouterOptionA];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)gotoDetailB:(id)sender {
    UIViewController *vc = [[ABRouter shared] matchController:@"/detail/2" abOption:ABRouterOptionB];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showAlert:(id)sender {
    [[ABRouter shared] callActionBlock:@"/alert/test message?title=test title"];
}

@end
