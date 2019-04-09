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
#import "ABRouterDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface ABRouter : NSObject

+ (instancetype)shared;
+ (NSInteger)optionCount;

- (void)map:(NSString *)route toControllerClass:(nullable Class)controllerClass;
- (void)map:(NSString *)route toControllerClass:(nullable Class)controllerClass abOption:(ABRouterOption)abOption;

- (void)map:(NSString *)route toControllerBlock:(nullable ABRouterControllerBlock)controllerBlock;
- (void)map:(NSString *)route toControllerBlock:(nullable ABRouterControllerBlock)controllerBlock abOption:(ABRouterOption)abOption;

// controller class and controller block are mutually exclusive
// params in router will override VC params set in controller block if there are same keys
- (nullable UIViewController *)matchController:(NSString *)route;
- (nullable UIViewController *)matchController:(NSString *)route abOption:(ABRouterOption)abOption;

- (void)map:(NSString *)route toActionBlock:(nullable ABRouterActionBlock)actionBlock;
- (void)map:(NSString *)route toActionBlock:(nullable ABRouterActionBlock)actionBlock abOption:(ABRouterOption)abOption;

// params in action block invokation will override params in router if there are same keys
- (nullable ABRouterActionBlock)matchActionBlock:(NSString *)route;
- (nullable ABRouterActionBlock)matchActionBlock:(NSString *)route abOption:(ABRouterOption)abOption;

- (nullable id)callActionBlock:(NSString *)route;
- (nullable id)callActionBlock:(NSString *)route abOption:(ABRouterOption)abOption;

- (BOOL)canMapController:(NSString *)route;
- (BOOL)canMapController:(NSString *)route abOption:(ABRouterOption)abOption;

- (BOOL)canMapAction:(NSString *)route;
- (BOOL)canMapAction:(NSString *)route abOption:(ABRouterOption)abOption;

@end

// ################################################################
#pragma mark -

@interface ABRouter (Deprecated)

- (void)map:(NSString *)route toBlock:(nullable ABRouterActionBlock)block __deprecated_msg("use -map:toActionBlock: instead");
- (ABRouterActionBlock)matchBlock:(NSString *)route __deprecated_msg("use -matchActionBlock: instead");
- (id)callBlock:(NSString *)route __deprecated_msg("use -callActionBlock: instead");
- (BOOL)canRoute:(NSString *)route __deprecated_msg("use -canMapController: & -canMapAction: instead");

@end

// ################################################################
#pragma mark -

@interface UIViewController (ABRouter)

@property (nonatomic, strong, nullable) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
