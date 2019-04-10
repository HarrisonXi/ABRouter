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
        XCTAssertEqualObjects(params[ABRouterModuleKey], @"/add/");
        XCTAssertNotNil(params[ABRouterActionBlockKey]);
        if (params[@"r"]) {
            XCTAssertEqualObjects(params[@"r"], params[ABRouterRouteKey]);
        } else {
            XCTAssertEqualObjects(@"/add/?a=1&b=2", params[ABRouterRouteKey]);
        }
        XCTAssertEqualObjects(params[@"a"], @"1");
        XCTAssertEqualObjects(params[@"b"], @"2");
        [expectation fulfill];
        return nil;
    }];

    XCTAssertTrue([_router canMapAction:@"/add/?a=1"]);
    XCTAssertTrue([_router canMapAction:@"/add/?a=1&b=3"]);
    XCTAssertTrue([_router canMapAction:@"/add/?a=1&b=2"]);
    
    ABRouterActionBlock block = [_router matchActionBlock:@"/add/?a=1"];
    XCTAssertNotNil(block);
    block(@{@"b" : @"2", @"r" : @"/add/?a=1"});
    
    block = [_router matchActionBlock:@"/add/?a=1&b=3"];
    XCTAssertNotNil(block);
    // params in action block invokation will override params in router if there are same keys
    block(@{@"b" : @"2", @"r" : @"/add/?a=1&b=3"});
    
    [_router callActionBlock:@"/add/?a=1&b=2"];
    
    [self waitForExpectations:@[expectation] timeout:1];
}

- (void)testControllerClass
{
    [_router map:@"/a/:aId/" toControllerClass:[UITableViewController class]];
    [_router map:@"/b/:bId" toControllerClass:[UINavigationController class]];
    [_router map:@"/a/:aId/mine/" toControllerClass:[UITabBarController class]];

    XCTAssertFalse([_router canMapController:@"/a/"]);
    XCTAssertTrue([_router canMapController:@"/a/1/"]);
    XCTAssertTrue([_router canMapController:@"/b/2/"]);
    XCTAssertTrue([_router canMapController:@"/a/3/mine/"]);
    
    XCTAssertEqualObjects([[_router matchController:@"/a/1/"] class],
                          [UITableViewController class]);
    XCTAssertEqualObjects([[_router matchController:@"/b/2/"] class],
                          [UINavigationController class]);
    XCTAssertEqualObjects([[_router matchController:@"/a/3/mine/"] class],
                          [UITabBarController class]);

    UIViewController *vc = [_router matchController:@"/a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[ABRouterModuleKey], @"/a/:aId/");
    XCTAssertEqualObjects(vc.params[ABRouterControllerClassKey], [UITableViewController class]);
    XCTAssertNil(vc.params[ABRouterControllerBlockKey]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
	
	vc = [_router matchController:@"/b/2?c=6&d=7"];
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/b/2?c=6&d=7");
    XCTAssertEqualObjects(vc.params[ABRouterModuleKey], @"/b/:bId");
    XCTAssertEqualObjects(vc.params[ABRouterControllerClassKey], [UINavigationController class]);
    XCTAssertNil(vc.params[ABRouterControllerBlockKey]);
    XCTAssertEqualObjects(vc.params[@"bId"], @"2");
    XCTAssertEqualObjects(vc.params[@"c"], @"6");
    XCTAssertEqualObjects(vc.params[@"d"], @"7");
    
    vc = [_router matchController:@"/a/1?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertNil(vc.params[@"b"]);
    XCTAssertNil(vc.params[@"c"]);
    
    vc = [_router matchController:@"/a/1/?"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertNil(vc.params[@"b"]);
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
    
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5"]);
    
    UIViewController *vc = [_router matchController:@"/a/1/?b=4&c=5"];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[ABRouterModuleKey], @"/a/:aId/");
    XCTAssertNotNil(vc.params[ABRouterControllerBlockKey]);
    XCTAssertNil(vc.params[ABRouterControllerClassKey]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    // params in router will override VC params set in controller block if there are same keys
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
    XCTAssertEqualObjects(vc.params[@"testKey"], @"testValue");
    
    [_router map:@"/a/:aId/" toControllerClass:[UINavigationController class]];
    
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5"]);

    vc = [_router matchController:@"/a/1/?b=4&c=5"];
    // controller class and controller block are mutually exclusive
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/a/1/?b=4&c=5");
    XCTAssertEqualObjects(vc.params[ABRouterModuleKey], @"/a/:aId/");
    XCTAssertNil(vc.params[ABRouterControllerBlockKey]);
    XCTAssertNotNil(vc.params[ABRouterControllerClassKey]);
    XCTAssertEqualObjects(vc.params[@"aId"], @"1");
    XCTAssertEqualObjects(vc.params[@"b"], @"4");
    XCTAssertEqualObjects(vc.params[@"c"], @"5");
    XCTAssertNil(vc.params[@"testKey"]);
    
    [_router map:@"/d/:dId/" toControllerBlock:^UIViewController *(NSDictionary *params) {
        return [UITabBarController new];
    }];
    
    XCTAssertTrue([_router canMapController:@"/d/1/?e=4&f=5"]);

    vc = [_router matchController:@"/d/1/?e=4&f=5"];
    XCTAssertEqualObjects([vc class], [UITabBarController class]);
    XCTAssertEqualObjects(vc.params[ABRouterRouteKey], @"/d/1/?e=4&f=5");
    XCTAssertEqualObjects(vc.params[ABRouterModuleKey], @"/d/:dId/");
    XCTAssertNotNil(vc.params[ABRouterControllerBlockKey]);
    XCTAssertNil(vc.params[ABRouterControllerClassKey]);
    XCTAssertEqualObjects(vc.params[@"dId"], @"1");
    XCTAssertEqualObjects(vc.params[@"e"], @"4");
    XCTAssertEqualObjects(vc.params[@"f"], @"5");
}

- (void)testAB1
{
    [_router map:@"/a/:aId/" toControllerClass:[UITableViewController class] abOption:ABRouterOptionNone];
    [_router map:@"/a/:aId/" toControllerClass:[UITabBarController class] abOption:ABRouterOptionA];
    [_router map:@"/a/:aId/" toControllerClass:[UINavigationController class] abOption:ABRouterOptionB];
    [_router map:@"/a/:aId/" toControllerClass:[UISplitViewController class] abOption:ABRouterOptionC];
    [_router map:@"/a/:aId/" toControllerClass:[UICollectionViewController class] abOption:ABRouterOptionD];
    
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionNone]);
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA]);
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionB]);
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionC]);
    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionD]);
    
    UIViewController *vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionNone];
    XCTAssertEqualObjects([vc class], [UITableViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionNone));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA];
    XCTAssertEqualObjects([vc class], [UITabBarController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionA));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionB];
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionB));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionC];
    XCTAssertEqualObjects([vc class], [UISplitViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionC));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionD];
    XCTAssertEqualObjects([vc class], [UICollectionViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionD));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionAll];
    XCTAssertEqualObjects([vc class], [UITabBarController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionA));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA | ABRouterOptionB];
    XCTAssertEqualObjects([vc class], [UITabBarController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionA));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionC | ABRouterOptionB];
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionB));
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionC | ABRouterOptionD];
    XCTAssertEqualObjects([vc class], [UISplitViewController class]);
    XCTAssertEqualObjects(vc.params[ABRouterOptionKey], @(ABRouterOptionC));
    
    // test remove route
    [_router map:@"/a/:aId/" toControllerClass:NULL abOption:ABRouterOptionA];
    
    XCTAssertFalse([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA]);
    
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionAll];
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA | ABRouterOptionB];
    XCTAssertEqualObjects([vc class], [UINavigationController class]);
    
    // setting controller block will not reset controller class route
    [_router map:@"/a/:aId/" toControllerBlock:^UIViewController *(NSDictionary *params) {
        return [UITabBarController new];
    } abOption:ABRouterOptionA];

    XCTAssertTrue([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA]);
    
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionAll];
    XCTAssertEqualObjects([vc class], [UITabBarController class]);
    vc = [_router matchController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA | ABRouterOptionB];
    XCTAssertEqualObjects([vc class], [UITabBarController class]);
    
    // setting action block will reset controller route
    [_router map:@"/a/:aId/" toActionBlock:^id(NSDictionary *params) {
        return nil;
    } abOption:ABRouterOptionB];
    
    XCTAssertFalse([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionNone]);
    XCTAssertFalse([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA]);
    XCTAssertFalse([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionB]);
    XCTAssertFalse([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionC]);
    XCTAssertFalse([_router canMapController:@"/a/1/?b=4&c=5" abOption:ABRouterOptionD]);
    XCTAssertFalse([_router canMapAction:@"/a/1/?b=4&c=5" abOption:ABRouterOptionNone]);
    XCTAssertFalse([_router canMapAction:@"/a/1/?b=4&c=5" abOption:ABRouterOptionA]);
    XCTAssertTrue([_router canMapAction:@"/a/1/?b=4&c=5" abOption:ABRouterOptionB]);
    XCTAssertFalse([_router canMapAction:@"/a/1/?b=4&c=5" abOption:ABRouterOptionC]);
    XCTAssertFalse([_router canMapAction:@"/a/1/?b=4&c=5" abOption:ABRouterOptionD]);
}

- (void)testAB2
{
    [_router map:@"/b/:bId/" toActionBlock:^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[ABRouterOptionKey], @(ABRouterOptionNone));
        return @(0);
    } abOption:ABRouterOptionNone];
    [_router map:@"/b/:bId/" toActionBlock:^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[ABRouterOptionKey], @(ABRouterOptionA));
        return @(1);
    } abOption:ABRouterOptionA];
    [_router map:@"/b/:bId/" toActionBlock:^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[ABRouterOptionKey], @(ABRouterOptionB));
        return @(2);
    } abOption:ABRouterOptionB];
    [_router map:@"/b/:bId/" toActionBlock:^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[ABRouterOptionKey], @(ABRouterOptionC));
        return @(3);
    } abOption:ABRouterOptionC];
    [_router map:@"/b/:bId/" toActionBlock:^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[ABRouterOptionKey], @(ABRouterOptionD));
        return @(4);
    } abOption:ABRouterOptionD];
    
    XCTAssertTrue([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionNone]);
    XCTAssertTrue([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA]);
    XCTAssertTrue([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionB]);
    XCTAssertTrue([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionC]);
    XCTAssertTrue([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionD]);
    
    ABRouterActionBlock block = [_router matchActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionNone];
    NSNumber *value = block(nil);
    XCTAssertEqualObjects(value, @(0));
    block = [_router matchActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA];
    value = block(nil);
    XCTAssertEqualObjects(value, @(1));
    block = [_router matchActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionB];
    value = block(nil);
    XCTAssertEqualObjects(value, @(2));
    block = [_router matchActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionC];
    value = block(nil);
    XCTAssertEqualObjects(value, @(3));
    block = [_router matchActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionD];
    value = block(nil);
    XCTAssertEqualObjects(value, @(4));
    value = [_router callActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionAll];
    XCTAssertEqualObjects(value, @(1));
    value = [_router callActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA | ABRouterOptionB];
    XCTAssertEqualObjects(value, @(1));
    value = [_router callActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionC | ABRouterOptionB];
    XCTAssertEqualObjects(value, @(2));
    value = [_router callActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionC | ABRouterOptionD];
    XCTAssertEqualObjects(value, @(3));
    
    // test remove route
    [_router map:@"/b/:bId/" toActionBlock:nil abOption:ABRouterOptionA];
    
    XCTAssertFalse([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA]);
    
    value = [_router callActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionAll];
    XCTAssertEqualObjects(value, @(2));
    value = [_router callActionBlock:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA | ABRouterOptionB];
    XCTAssertEqualObjects(value, @(2));

    // setting controller class or block will reset action route
    [_router map:@"/b/:bId/" toControllerClass:[UITableViewController class] abOption:ABRouterOptionB];
    
    XCTAssertFalse([_router canMapController:@"/b/1/?d=4&e=5" abOption:ABRouterOptionNone]);
    XCTAssertFalse([_router canMapController:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA]);
    XCTAssertTrue([_router canMapController:@"/b/1/?d=4&e=5" abOption:ABRouterOptionB]);
    XCTAssertFalse([_router canMapController:@"/b/1/?d=4&e=5" abOption:ABRouterOptionC]);
    XCTAssertFalse([_router canMapController:@"/b/1/?d=4&e=5" abOption:ABRouterOptionD]);
    XCTAssertFalse([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionNone]);
    XCTAssertFalse([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionA]);
    XCTAssertFalse([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionB]);
    XCTAssertFalse([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionC]);
    XCTAssertFalse([_router canMapAction:@"/b/1/?d=4&e=5" abOption:ABRouterOptionD]);
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
