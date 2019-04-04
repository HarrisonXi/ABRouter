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

const NSString *ABRouterRouteKey = @"abr_route";
const NSString *ABRouterControllerClassKey = @"abr_controllerClass";
const NSString *ABRouterControllerBlockKey = @"abr_controllerBlock";
const NSString *ABRouterActionBlockKey = @"abr_actionBlock";

@interface ABRouteModel : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, ABRouteModel *> *subRoutes;
@property (nonatomic, strong) NSString *paramName;
@property (nonatomic, strong) ABRouteModel *paramRoute;

@property (nonatomic, strong) Class controllerClass;
@property (nonatomic, copy) ABRouterControllerBlock controllerBlock;
@property (nonatomic, copy) ABRouterActionBlock actionBlock;

@end

@implementation ABRouteModel

- (NSMutableDictionary *)subRoutes
{
    if (!_subRoutes) {
        _subRoutes = [NSMutableDictionary dictionary];
    }
    return _subRoutes;
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

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass
{
    [self map:route toControllerClass:controllerClass abOption:ABRouterOptionNone];
}

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass abOption:(ABRouterOption)abOption
{
    ABRouteModel *routeModel = [self routeModelOfRoute:route];
    routeModel.controllerClass = controllerClass;
}

- (void)map:(NSString *)route toControllerBlock:(ABRouterControllerBlock)controllerBlock
{
    [self map:route toControllerBlock:controllerBlock abOption:ABRouterOptionNone];
}

- (void)map:(NSString *)route toControllerBlock:(ABRouterControllerBlock)controllerBlock abOption:(ABRouterOption)abOption
{
    ABRouteModel *routeModel = [self routeModelOfRoute:route];
    routeModel.controllerBlock = controllerBlock;
}

- (void)map:(NSString *)route toActionBlock:(ABRouterActionBlock)actionBlock
{
    [self map:route toActionBlock:actionBlock abOption:ABRouterOptionNone];
}

- (void)map:(NSString *)route toActionBlock:(ABRouterActionBlock)actionBlock abOption:(ABRouterOption)abOption
{
    ABRouteModel *routeModel = [self routeModelOfRoute:route];
    routeModel.actionBlock = actionBlock;
}

- (UIViewController *)matchController:(NSString *)route
{
    return [self matchController:route abOption:ABRouterOptionNone];
}

- (UIViewController *)matchController:(NSString *)route abOption:(ABRouterOption)abOption
{
    NSDictionary *params = [self paramsInRoute:route];
    Class controllerClass = params[ABRouterControllerClassKey];
    
    UIViewController *viewController = [[controllerClass alloc] init];
    
    if ([viewController respondsToSelector:@selector(setParams:)]) {
        [viewController performSelector:@selector(setParams:)
                             withObject:[params copy]];
    }
    return viewController;
}

- (UIViewController *)match:(NSString *)route
{
    return [self matchController:route];
}

- (ABRouterActionBlock)matchActionBlock:(NSString *)route
{
    return [self matchActionBlock:route abOption:ABRouterOptionNone];
}

- (ABRouterActionBlock)matchActionBlock:(NSString *)route abOption:(ABRouterOption)abOption
{
    NSDictionary *params = [self paramsInRoute:route];
    
    if (!params){
        return nil;
    }
    
    ABRouterActionBlock routerBlock = [params[ABRouterActionBlockKey] copy];
    ABRouterActionBlock returnBlock = ^id(NSDictionary *aParams) {
        if (routerBlock) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
            [dic addEntriesFromDictionary:aParams];
            return routerBlock([NSDictionary dictionaryWithDictionary:dic].copy);
        }
        return nil;
    };
    
    return [returnBlock copy];
}

- (id)callActionBlock:(NSString *)route
{
    return [self callActionBlock:route abOption:ABRouterOptionNone];
}

- (id)callActionBlock:(NSString *)route abOption:(ABRouterOption)abOption
{
    NSDictionary *params = [self paramsInRoute:route];
    ABRouterActionBlock routerBlock = [params[ABRouterActionBlockKey] copy];
    
    if (routerBlock) {
        return routerBlock([params copy]);
    }
    return nil;
}

- (ABRouterType)canRoute:(NSString *)route
{
    ABRouterType result = ABRouterTypeNone;
    
    NSDictionary *params = [self paramsInRoute:route];
    if (params[ABRouterControllerClassKey]) {
        result |= ABRouterTypeControllerClass;
    }
    if (params[ABRouterControllerBlockKey]) {
        result |= ABRouterTypeControllerBlock;
    }
    if (params[ABRouterActionBlockKey]) {
        result |= ABRouterTypeActionBlock;
    }
    
    return result;
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
#pragma clang diagnostic pop

#pragma mark Private

- (NSDictionary *)paramsInRoute:(NSString *)route
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
                NSString *value = [paramArr objectAtIndex:1];
                if (![params.allKeys containsObject:key]) {
                    params[key] = value;
                }
            }
        }
    }
    
    if (routeModel.controllerClass) {
        params[ABRouterControllerClassKey] = routeModel.controllerClass;
    }
    if (routeModel.controllerBlock) {
        params[ABRouterControllerBlockKey] = routeModel.controllerBlock;
    }
    if (routeModel.actionBlock) {
        params[ABRouterActionBlockKey] = routeModel.actionBlock;
    }

    return [params copy];
}

- (ABRouteModel *)routeModel
{
    if (!_routeModel) {
        _routeModel = [ABRouteModel new];
    }
    return _routeModel;
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
        if ([route hasPrefix:[NSString stringWithFormat:@"%@:", appUrlScheme]]) {
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
