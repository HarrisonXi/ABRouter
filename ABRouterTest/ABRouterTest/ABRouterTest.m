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
#import "UserViewController.h"
#import "StoryViewController.h"
#import "StoryListViewController.h"
#define TIME_OUT 5

@interface ABRouterTests : XCTestCase

@end

@implementation ABRouterTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShared
{
    XCTAssertTrue([[ABRouter shared] isKindOfClass:[ABRouter class]]);
    XCTAssertTrue([[ABRouter shared] isEqual:[ABRouter shared]]);
}

- (void)testRouteBlocks
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [[ABRouter shared] map:@"/user/add/"
                   toBlock:^id(NSDictionary* params) {
                       XCTAssertEqualObjects(params[@"a"], @"1");
                       XCTAssertEqualObjects(params[@"b"], @"2");
                       dispatch_semaphore_signal(semaphore);
                   }];

    ABRouterBlock block = [[ABRouter shared] matchBlock:@"/user/add/?a=1&b=2"];
    XCTAssertNotNil(block);
    block(nil);
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop]
               runMode:NSDefaultRunLoopMode
            beforeDate:[NSDate dateWithTimeIntervalSinceNow:TIME_OUT]];
    }
    [[ABRouter shared] callBlock:@"/user/add/?a=1&b=2"];
}

- (void)testRoute
{
    [[ABRouter shared] map:@"/user/:userId/"
         toControllerClass:[UserViewController class]];
    [[ABRouter shared] map:@"/story/:storyId/"
         toControllerClass:[StoryViewController class]];
    [[ABRouter shared] map:@"/user/:userId/story/"
         toControllerClass:[StoryListViewController class]];

    XCTAssertEqualObjects(
        [[[ABRouter shared] matchController:@"/story/2/"] class],
        [StoryViewController class]);
    XCTAssertEqualObjects(
        [[[ABRouter shared] matchController:@"/user/1/story/"] class],
        [StoryListViewController class]);

//    XCTAssertEqualObjects(
//        [[[ABRouter shared] matchController:@"ABRouter://user/1/"] class],
//        [UserViewController class]);

    UserViewController* userViewController = (UserViewController*)
        [[ABRouter shared] matchController:@"/user/1/?a=b&c=d"];
    XCTAssertEqualObjects(userViewController.params[@"route"],
                          @"/user/1/?a=b&c=d");
    XCTAssertEqualObjects(userViewController.params[@"userId"], @"1");
    XCTAssertEqualObjects(userViewController.params[@"a"], @"b");
    XCTAssertEqualObjects(userViewController.params[@"c"], @"d");
	
	
	
	[[ABRouter shared] map:@"/test/:someId/"
         toControllerClass:[StoryListViewController class]];
	
	
	
	UserViewController* userViewController1 = (UserViewController*)
	[[ABRouter shared] matchController:@"/test/7777777?aa=11&bb=22"];
	NSLog(@"%@", userViewController1.params);
	
	
	UserViewController* userViewController2 = (UserViewController*)
	[[ABRouter shared] matchController:@"/test/7777777"];
	NSLog(@"%@", userViewController2.params);
	
	UserViewController* userViewController3 = (UserViewController*)
	[[ABRouter shared] matchController:@"/test/7777777/?aa=11&bb=22"];
	NSLog(@"%@", userViewController3.params);

	
}

@end
