//
//  ABRouterTests.m
//  ABRouterTests
//
//  Created by Light on 2014-03-13.
//  Copyright (c) 2014 Huohua. All rights reserved.
//  Copyright (c) 2019 harrisonxi.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ABRouter/ABRouter.h>

@interface ABRouterTests : XCTestCase

@property (nonatomic, strong) ABRouter *router;

@end

@implementation ABRouterTests

- (void)setUp
{
    _router = [ABRouter new];
}

- (void)testActionBlocks
{
    XCTestExpectation *expectation = [XCTestExpectation new];
    expectation.expectedFulfillmentCount = 3;

    [_router map:@"/add/" toActionBlock:^id(NSDictionary* params) {
        XCTAssertEqualObjects(params[@"a"], @"1");
        XCTAssertEqualObjects(params[@"b"], @"2");
        [expectation fulfill];
        return nil;
    }];

    ABRouterActionBlock block = [_router matchActionBlock:@"/add/?a=1"];
    XCTAssertNotNil(block);
    block(@{@"b" : @"2"});
    
    block = [_router matchActionBlock:@"/add/?a=1&b=3"];
    XCTAssertNotNil(block);
    // params in action block invokation will override params in router if there are same keys
    block(@{@"b" : @"2"});
    
    [_router callActionBlock:@"/add/?a=1&b=2"];
    
    [self waitForExpectations:@[expectation] timeout:1];
}

- (void)testControllerClass
{
    [_router map:@"/a/:aId/" toControllerClass:[UITableViewController class]];
    [_router map:@"/b/:bId" toControllerClass:[UINavigationController class]];
    [_router map:@"/a/:aId/mine/" toControllerClass:[UITabBarController class]];

    XCTAssertEqualObjects([[_router matchController:@"/a/1/"] class],
                          [UITableViewController class]);
    XCTAssertEqualObjects([[_router matchController:@"/b/2/"] class],
                          [UINavigationController class]);
    XCTAssertEqualObjects([[_router matchController:@"/a/3/mine/"] class],
                          [UITabBarController class]);

    UIViewController *vc = [_router matchController:@"/a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
	
	vc = [_router matchController:@"/a/1?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
    
    vc = [_router matchController:@"/a/1?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertNil(vc.params[@"a"]);
    XCTAssertNil(vc.params[@"c"]);
    
    vc = [_router matchController:@"/a/1/?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertNil(vc.params[@"a"]);
    XCTAssertNil(vc.params[@"c"]);
    
    vc = [_router matchController:@"a/1?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    
    vc = [_router matchController:@"a/1/?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    
    vc = [_router matchController:@"a/1"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    
    vc = [_router matchController:@"a/1/"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
}

- (void)testControllerBlock
{
    [_router map:@"/a/:aId/" toControllerBlock:^UIViewController *(NSDictionary *params) {
        UITableViewController *vc = [UITableViewController new];
        vc.params = @{@"testKey" : @"testValue", @"b" : @"2"};
        return vc;
    }];
    
    UIViewController *vc = [_router matchController:@"/a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    // params in router will override VC params set in controller block if there are same keys
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
    XCTAssertEqualObjects(vc.params[@"testKey"], @"testValue");
    
    [_router map:@"/a/:aId/" toControllerClass:[UINavigationController class]];
    
    vc = [_router matchController:@"/a/1/?b=4&c=5"];
    // controller class has higher priority than controller block
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
    XCTAssertNil(vc.params[@"testKey"]);
    
    [_router map:@"/d/:dId/" toControllerBlock:^UIViewController *(NSDictionary *params) {
        return [UITableViewController new];
    }];
    
    vc = [_router matchController:@"/d/1/?e=4&f=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/d/1/?e=4&f=5");
    XCTAssertEqualObjects(vc.params[@"dId"], @"1");
    XCTAssertEqualObjects(vc.params[@"e"], @"4");
    XCTAssertEqualObjects(vc.params[@"f"], @"5");
}

- (void)testAppUrlScheme
{
    [_router map:@"/a/:aId/" toControllerClass:[UITableViewController class]];
    
    UIViewController *vc = [_router matchController:@"abrouter://a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
}

- (void)testDifferentParamRouter
{
    [_router map:@"/a/:aId/" toControllerClass:[UITableViewController class]];

#ifdef DEBUG
    XCTAssertThrows([_router map:@"/a/:bId/" toControllerClass:[UINavigationController class]]);
#else
    XCTAssertNoThrow([_router map:@"/a/:bId/" toControllerClass:[UINavigationController class]]);
#endif
    
    UIViewController *vc = [_router matchController:@"/a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
}

@end
