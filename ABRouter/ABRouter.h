// The MIT License
//
// Copyright (c) 2014 LIGHT lightory@gmail.com
// Copyright (c) 2019 harrisonxi.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, ABRouterOption) {
    ABRouterOptionNone = 0, // only match default option
    ABRouterOptionA = 1,
    ABRouterOptionB = 1 << 1,
    ABRouterOptionC = 1 << 2,
    ABRouterOptionD = 1 << 3,
    ABRouterOptionAll = 0xF // match all options
};

typedef UIViewController * (^ABRouterControllerBlock)(NSDictionary *params);
typedef id (^ABRouterActionBlock)(NSDictionary *params);

extern const NSString *ABRouterRouteKey;
extern const NSString *ABRouterModuleKey;
extern const NSString *ABRouterControllerClassKey;
extern const NSString *ABRouterControllerBlockKey;
extern const NSString *ABRouterActionBlockKey;

// ################################################################
#pragma mark -

@interface ABRouter : NSObject

+ (instancetype)shared;

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass abOption:(ABRouterOption)abOption;

- (void)map:(NSString *)route toControllerBlock:(ABRouterControllerBlock)controllerBlock;
- (void)map:(NSString *)route toControllerBlock:(ABRouterControllerBlock)controllerBlock abOption:(ABRouterOption)abOption;

// controller class has higher priority than controller block
// params in router will override VC params set in controller block if there are same keys
- (UIViewController *)matchController:(NSString *)route;
- (UIViewController *)matchController:(NSString *)route abOption:(ABRouterOption)abOption;

- (void)map:(NSString *)route toActionBlock:(ABRouterActionBlock)actionBlock;
- (void)map:(NSString *)route toActionBlock:(ABRouterActionBlock)actionBlock abOption:(ABRouterOption)abOption;

// params in action block invokation will override params in router if there are same keys
- (ABRouterActionBlock)matchActionBlock:(NSString *)route;
- (ABRouterActionBlock)matchActionBlock:(NSString *)route abOption:(ABRouterOption)abOption;

- (id)callActionBlock:(NSString *)route;
- (id)callActionBlock:(NSString *)route abOption:(ABRouterOption)abOption;

- (BOOL)canMapController:(NSString *)route;
- (BOOL)canMapController:(NSString *)route abOption:(ABRouterOption)abOption;

- (BOOL)canMapAction:(NSString *)route;
- (BOOL)canMapAction:(NSString *)route abOption:(ABRouterOption)abOption;

@end

// ################################################################
#pragma mark -

@interface ABRouter (Deprecated)

- (void)map:(NSString *)route toBlock:(ABRouterActionBlock)block __deprecated_msg("use -map:toActionBlock: instead");
- (ABRouterActionBlock)matchBlock:(NSString *)route __deprecated_msg("use -matchActionBlock: instead");
- (id)callBlock:(NSString *)route __deprecated_msg("use -callActionBlock: instead");
- (BOOL)canRoute:(NSString *)route __deprecated_msg("use -canMapController: & -canMapAction: instead");

@end

// ################################################################
#pragma mark -

@interface UIViewController (ABRouter)

@property (nonatomic, strong) NSDictionary *params;

@end
