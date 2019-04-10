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

#import "ABRouter.h"
#import <objc/runtime.h>
#import "ABRouteMap.h"

const NSString *ABRouterRouteKey = @"abr_route";
const NSString *ABRouterModuleKey = @"abr_module";
const NSString *ABRouterOptionKey = @"abr_option";
const NSString *ABRouterControllerClassKey = @"abr_controllerClass";
const NSString *ABRouterControllerBlockKey = @"abr_controllerBlock";
const NSString *ABRouterActionBlockKey = @"abr_actionBlock";

@interface ABRouteModel : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, ABRouteModel *> *subRoutes;
@property (nonatomic, strong) NSString *paramName;
@property (nonatomic, strong) ABRouteModel *paramRoute;

@property (nonatomic, strong) NSString *module;
@property (nonatomic, strong) ABRouteMap *map;

@end

@implementation ABRouteModel

- (NSMutableDictionary *)subRoutes
{
    if (!_subRoutes) {
        _subRoutes = [NSMutableDictionary dictionary];
    }
    return _subRoutes;
}

- (ABRouteMap *)map
{
    if (!_map) {
        _map = [ABRouteMap new];
    }
    return _map;
}

@end

// ################################################################
#pragma mark -

@interface ABRouter ()

@property (nonatomic, strong) ABRouteModel *routeModel;

@end

@implementation ABRouter

+ (instancetype)shared
{
    static ABRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [ABRouter new];
    });
    return router;
}

+ (NSInteger)optionCount
{
    static NSInteger optionCount = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger optionAll = ABRouterOptionAll;
        while (optionAll) {
            optionAll >>= 1;
            optionCount++;
        }
    });
    return optionCount;
}

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass
{
    [self map:route toControllerClass:controllerClass abOption:ABRouterOptionNone];
}

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass abOption:(ABRouterOption)abOption
{
#ifdef DEBUG
    NSParameterAssert(route && route.length > 0);
#else
    if (!route || route.length == 0) {
        return;
    }
#endif
    ABRouteModel *routeModel = [self routeModelOfRoute:route];
    [routeModel.map setControllerClass:controllerClass withAbOption:abOption];
    routeModel.module = route;
}

- (void)map:(NSString *)route toControllerBlock:(ABRouterControllerBlock)controllerBlock
{
    [self map:route toControllerBlock:controllerBlock abOption:ABRouterOptionNone];
}

- (void)map:(NSString *)route toControllerBlock:(ABRouterControllerBlock)controllerBlock abOption:(ABRouterOption)abOption
{
#ifdef DEBUG
    NSParameterAssert(route && route.length > 0);
#else
    if (!route || route.length == 0) {
        return;
    }
#endif
    ABRouteModel *routeModel = [self routeModelOfRoute:route];
    [routeModel.map setControllerBlock:controllerBlock withAbOption:abOption];
    routeModel.module = route;
}

- (void)map:(NSString *)route toActionBlock:(ABRouterActionBlock)actionBlock
{
    [self map:route toActionBlock:actionBlock abOption:ABRouterOptionNone];
}

- (void)map:(NSString *)route toActionBlock:(ABRouterActionBlock)actionBlock abOption:(ABRouterOption)abOption
{
#ifdef DEBUG
    NSParameterAssert(route && route.length > 0);
#else
    if (!route || route.length == 0) {
        return;
    }
#endif
    ABRouteModel *routeModel = [self routeModelOfRoute:route];
    [routeModel.map setActionBlock:actionBlock withAbOption:abOption];
    routeModel.module = route;
}

- (UIViewController *)matchController:(NSString *)route
{
    return [self matchController:route abOption:ABRouterOptionNone];
}

- (UIViewController *)matchController:(NSString *)route abOption:(ABRouterOption)abOption
{
    if (route && route.length > 0) {
        NSDictionary *params = [self paramsInRoute:route abOption:abOption];
        if (params) {
            UIViewController *viewController = nil;
            Class controllerClass = params[ABRouterControllerClassKey];
            if (controllerClass) {
                viewController = [controllerClass new];
                if ([viewController respondsToSelector:@selector(setParams:)]) {
                    [viewController setParams:params];
                }
            } else {
                ABRouterControllerBlock controllerBlock = params[ABRouterControllerBlockKey];
                if (controllerBlock) {
                    viewController = controllerBlock(params);
                }
                if ([viewController respondsToSelector:@selector(setParams:)]
                    && [viewController respondsToSelector:@selector(params)]) {
                    NSDictionary *aParams = [viewController params];
                    if (!aParams) {
                        [viewController setParams:params];
                    } else {
                        NSMutableDictionary *cParams = [NSMutableDictionary dictionaryWithDictionary:aParams];
                        [cParams addEntriesFromDictionary:params];
                        [viewController setParams:[cParams copy]];
                    }
                }
            }
            return viewController;
        }
    }
    return nil;
}

- (ABRouterActionBlock)matchActionBlock:(NSString *)route
{
    return [self matchActionBlock:route abOption:ABRouterOptionNone];
}

- (ABRouterActionBlock)matchActionBlock:(NSString *)route abOption:(ABRouterOption)abOption
{
    if (route && route.length > 0) {
        NSDictionary *params = [self paramsInRoute:route abOption:abOption];
        if (params) {
            ABRouterActionBlock actionBlock = params[ABRouterActionBlockKey];
            if (actionBlock) {
                ABRouterActionBlock returnBlock = ^id(NSDictionary *aParams) {
                    NSMutableDictionary *cParams = [NSMutableDictionary dictionaryWithDictionary:params];
                    [cParams addEntriesFromDictionary:aParams];
                    return actionBlock([cParams copy]);
                };
                return [returnBlock copy];
            }
        }
    }
    return nil;
}

- (id)callActionBlock:(NSString *)route
{
    return [self callActionBlock:route abOption:ABRouterOptionNone];
}

- (id)callActionBlock:(NSString *)route abOption:(ABRouterOption)abOption
{
    if (route && route.length > 0) {
        NSDictionary *params = [self paramsInRoute:route abOption:abOption];
        if (params) {
            ABRouterActionBlock actionBlock = params[ABRouterActionBlockKey];
            if (actionBlock) {
                return actionBlock(params);
            }
        }
    }
    return nil;
}

- (BOOL)canMapController:(NSString *)route
{
    return [self canMapController:route abOption:ABRouterOptionNone];
}

- (BOOL)canMapController:(NSString *)route abOption:(ABRouterOption)abOption
{
    if (route && route.length > 0) {
        NSDictionary *params = [self paramsInRoute:route abOption:abOption];
        if (params && (params[ABRouterControllerClassKey] || params[ABRouterControllerBlockKey])) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canMapAction:(NSString *)route
{
    return [self canMapAction:route abOption:ABRouterOptionNone];
}

- (BOOL)canMapAction:(NSString *)route abOption:(ABRouterOption)abOption
{
    if (route && route.length > 0) {
        NSDictionary *params = [self paramsInRoute:route abOption:abOption];
        if (params && params[ABRouterActionBlockKey]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark Deprecated

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)map:(NSString *)route toBlock:(ABRouterActionBlock)block
{
    [self map:route toActionBlock:block];
}

- (ABRouterActionBlock)matchBlock:(NSString *)route
{
    return [self matchActionBlock:route];
}

- (id)callBlock:(NSString *)route
{
    return [self callActionBlock:route];
}

- (BOOL)canRoute:(NSString *)route
{
    if ([self canMapController:route]) {
        return YES;
    } else if ([self canMapAction:route]) {
        return YES;
    }
    return NO;
}
#pragma clang diagnostic pop

#pragma mark Private

- (ABRouteModel *)routeModel
{
    if (!_routeModel) {
        _routeModel = [ABRouteModel new];
    }
    return _routeModel;
}

- (NSDictionary *)paramsInRoute:(NSString *)route abOption:(ABRouterOption)abOption
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[ABRouterRouteKey] = [self routeWithoutAppUrlScheme:route];

    // extract params in route path
    ABRouteModel *routeModel = self.routeModel;
    NSArray *pathComponents = [self pathComponentsOfRoute:params[ABRouterRouteKey]];
    for (NSString *pathComponent in pathComponents) {
        if ([routeModel.subRoutes.allKeys containsObject:pathComponent]) {
            routeModel = routeModel.subRoutes[pathComponent];
        } else if (routeModel.paramRoute) {
            params[routeModel.paramName] = pathComponent;
            routeModel = routeModel.paramRoute;
        } else {
            return nil;
        }
    }

    // extract params in route query
    NSRange range = [route rangeOfString:@"?"];
    if (range.location != NSNotFound && route.length > range.location + range.length) {
        NSString *paramsStr = [route substringFromIndex:range.location + range.length];
        NSArray *paramStrArr = [paramsStr componentsSeparatedByString:@"&"];
        for (NSString *paramStr in paramStrArr) {
            NSArray *paramArr = [paramStr componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [paramArr objectAtIndex:0];
                if (![params.allKeys containsObject:key]) {
                    NSString *value = [paramArr objectAtIndex:1];
                    params[key] = value;
                }
            }
        }
    }
    
    params[ABRouterModuleKey] = routeModel.module;
    [params addEntriesFromDictionary:[routeModel.map paramsWithAbOption:abOption]];
    
    return [params copy];
}

- (NSArray *)pathComponentsOfRoute:(NSString *)route
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    
    NSRange range = [route rangeOfString:@"?"];
    NSString *routeWithoutParams = range.location == NSNotFound ? route : [route substringToIndex:range.location];
    for (NSString *pathComponent in routeWithoutParams.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        [pathComponents addObject:pathComponent];
    }
    
    return [pathComponents copy];
}

- (NSString *)routeWithoutAppUrlScheme:(NSString *)route
{
    // filter out the app URL scheme.
    for (NSString *appUrlScheme in [self appUrlSchemes]) {
        if ([route hasPrefix:[NSString stringWithFormat:@"%@:", appUrlScheme]] && route.length > appUrlScheme.length + 2) {
            return [route substringFromIndex:appUrlScheme.length + 2];
        }
    }

    return route;
}

- (NSArray *)appUrlSchemes
{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (infoDictionary.count == 0) {
        infoDictionary = [[NSBundle bundleForClass:[self class]] infoDictionary];
    }
    for (NSDictionary *dict in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dict[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }

    return [appUrlSchemes copy];
}

- (ABRouteModel *)routeModelOfRoute:(NSString *)route
{
    ABRouteModel *routeModel = self.routeModel;

    for (NSString *pathComponent in [self pathComponentsOfRoute:route]) {
        if ([pathComponent hasPrefix:@":"]) {
            if (!routeModel.paramRoute) {
                routeModel.paramName = [pathComponent substringFromIndex:1];
                routeModel.paramRoute = [ABRouteModel new];
#ifdef DEBUG
            } else {
                NSAssert([routeModel.paramName isEqualToString:[pathComponent substringFromIndex:1]],
                         @"[ABRouter] already has a different param router");
#endif
            }
            routeModel = routeModel.paramRoute;
        } else {
            if (![routeModel.subRoutes objectForKey:pathComponent]) {
                routeModel.subRoutes[pathComponent] = [ABRouteModel new];
            }
            routeModel = routeModel.subRoutes[pathComponent];
        }
    };
    
    return routeModel;
}

@end

// ################################################################
#pragma mark -

@implementation UIViewController (ABRouter)

static void *ABRouterParamsKey = &ABRouterParamsKey;

- (void)setParams:(NSDictionary *)paramsDictionary
{
    objc_setAssociatedObject(self, ABRouterParamsKey, paramsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, ABRouterParamsKey);
}

@end
