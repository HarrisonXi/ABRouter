//
//  ABRouterTests.m
//  ABRouterTests
//
//  Created by Light on 2014-03-13.
//  Copyright (c) 2014 Huohua. All rights reserved.
//  Copyright (c) 2019 harrisonxi.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ABRouter.h"

@interface ABRouterTests : XCTestCase

@end

@implementation ABRouterTests

- (void)testBlocks
{
    XCTestExpectation *expectation = [XCTestExpectation new];
    expectation.expectedFulfillmentCount = 2;

    [[ABRouter shared] map:@"/add/"
                   toBlock:^id(NSDictionary* params) {
                       XCTAssertEqualObjects(params[@"a"], @"1");
                       XCTAssertEqualObjects(params[@"b"], @"2");
                       [expectation fulfill];
                   }];

    ABRouterBlock block = [[ABRouter shared] matchBlock:@"/add/?a=1"];
    XCTAssertNotNil(block);
    block(@{@"b" : @"2"});
    
    [[ABRouter shared] callBlock:@"/add/?a=1&b=2"];
    
    [self waitForExpectations:@[expectation] timeout:1];
}

- (void)testControllerClassAndParams
{
    [[ABRouter shared] map:@"/a/:aId/" toControllerClass:[UITableViewController class]];
    [[ABRouter shared] map:@"/b/:bId/" toControllerClass:[UINavigationController class]];
    [[ABRouter shared] map:@"/a/:aId/mine/" toControllerClass:[UITabBarController class]];

    XCTAssertEqualObjects([[[ABRouter shared] matchController:@"/a/1/"] class],
                          [UITableViewController class]);
    XCTAssertEqualObjects([[[ABRouter shared] matchController:@"/b/2/"] class],
                          [UINavigationController class]);
    XCTAssertEqualObjects([[[ABRouter shared] matchController:@"/a/3/mine/"] class],
                          [UITabBarController class]);

    UIViewController *vc = [[ABRouter shared] matchController:@"/a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"route"], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
	
	vc = [[ABRouter shared] matchController:@"/a/1?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"route"], @"/a/1?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
    
    vc = [[ABRouter shared] matchController:@"/a/1?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertNil(vc.params[@"a"]);
    XCTAssertNil(vc.params[@"c"]);
    
    vc = [[ABRouter shared] matchController:@"/a/1/?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertNil(vc.params[@"a"]);
    XCTAssertNil(vc.params[@"c"]);
    
    vc = [[ABRouter shared] matchController:@"a/1?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    
    vc = [[ABRouter shared] matchController:@"a/1/?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    
    vc = [[ABRouter shared] matchController:@"a/1"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    
    vc = [[ABRouter shared] matchController:@"a/1/"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
}

@end
