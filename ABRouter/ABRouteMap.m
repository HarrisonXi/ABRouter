// The MIT License
//
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

#import "ABRouteMap.h"
#import "ABRouter.h"

typedef NS_ENUM(NSInteger, ABRouteMapType) {
    ABRouteMapTypeNone = 0,
    ABRouteMapTypeController = 1,
    ABRouteMapTypeAction = 2
};

@interface ABRouteMapItem : NSObject

@property (nonatomic, strong) Class controllerClass;
@property (nonatomic, copy) ABRouterControllerBlock controllerBlock;
@property (nonatomic, copy) ABRouterActionBlock actionBlock;
@property (nonatomic, assign) ABRouteMapType type;

@end

@implementation ABRouteMapItem

- (void)setControllerClass:(Class)controllerClass
{
    if (controllerClass != _controllerClass) {
        _controllerClass = controllerClass;
        _controllerBlock = nil;
        _actionBlock = nil;
        _type = controllerClass ? ABRouteMapTypeController : ABRouteMapTypeNone;
    }
}

- (void)setControllerBlock:(ABRouterControllerBlock)controllerBlock
{
    if (controllerBlock != _controllerBlock) {
        _controllerBlock = controllerBlock;
        _controllerClass = NULL;
        _actionBlock = nil;
        _type = controllerBlock ? ABRouteMapTypeController : ABRouteMapTypeNone;
    }
}

- (void)setActionBlock:(ABRouterActionBlock)actionBlock
{
    if (actionBlock != _actionBlock) {
        _actionBlock = actionBlock;
        _controllerClass = NULL;
        _controllerBlock = nil;
        _type = actionBlock ? ABRouteMapTypeAction : ABRouteMapTypeNone;
    }
}

@end

// ################################################################
#pragma mark -

@interface ABRouteMap ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ABRouteMapItem *> *subMaps;

@end

@implementation ABRouteMap

- (NSMutableDictionary<NSNumber *,ABRouteMapItem *> *)subMaps
{
    if (!_subMaps) {
        _subMaps = [NSMutableDictionary dictionary];
    }
    return _subMaps;
}

- (void)setControllerClass:(Class)controllerClass withAbOption:(ABRouterOption)abOption
{
    if (controllerClass) {
        ABRouteMapItem *item = [ABRouteMapItem new];
        item.controllerClass = controllerClass;
        [self runBlock:^(NSNumber *key) {
            [self.subMaps setObject:item forKey:key];
        } withAbOption:abOption];
        [self filterSubMaps:item.type];
    } else {
        [self runBlock:^(NSNumber *key) {
            [self.subMaps removeObjectForKey:key];
        } withAbOption:abOption];
    }
}

- (void)setControllerBlock:(ABRouterControllerBlock)controllerBlock withAbOption:(ABRouterOption)abOption
{
    if (controllerBlock) {
        ABRouteMapItem *item = [ABRouteMapItem new];
        item.controllerBlock = controllerBlock;
        [self runBlock:^(NSNumber *key) {
            [self.subMaps setObject:item forKey:key];
        } withAbOption:abOption];
        [self filterSubMaps:item.type];
    } else {
        [self runBlock:^(NSNumber *key) {
            [self.subMaps removeObjectForKey:key];
        } withAbOption:abOption];
    }
}

- (void)setActionBlock:(ABRouterActionBlock)actionBlock withAbOption:(ABRouterOption)abOption
{
    if (actionBlock) {
        ABRouteMapItem *item = [ABRouteMapItem new];
        item.actionBlock = actionBlock;
        [self runBlock:^(NSNumber *key) {
            [self.subMaps setObject:item forKey:key];
        } withAbOption:abOption];
        [self filterSubMaps:item.type];
    } else {
        [self runBlock:^(NSNumber *key) {
            [self.subMaps removeObjectForKey:key];
        } withAbOption:abOption];
    }
}

- (void)runBlock:(void(^)(NSNumber *key))block withAbOption:(ABRouterOption)abOption
{
    if (abOption == ABRouterOptionNone) {
        block(@(0));
    } else {
        for (NSInteger index = 0; index < [ABRouter optionCount]; index++) {
            if (abOption & (1 << index)) {
                block(@(index + 1));
            }
        }
    }
}

- (void)filterSubMaps:(ABRouteMapType)type
{
    NSArray *keys = self.subMaps.allKeys;
    for (NSNumber *key in keys) {
        ABRouteMapItem *item = [self.subMaps objectForKey:key];
        if (item.type != type) {
            [self.subMaps removeObjectForKey:key];
        }
    }
}

- (NSDictionary *)paramsWithAbOption:(ABRouterOption)abOption
{
    ABRouteMapItem *item = nil;
    if (abOption == ABRouterOptionNone) {
        item = [self.subMaps objectForKey:@(0)];
    } else {
        for (NSInteger index = 0; index < [ABRouter optionCount]; index++) {
            if ((abOption & (1 << index)) && [self.subMaps objectForKey:@(index + 1)]) {
                item = [self.subMaps objectForKey:@(index + 1)];
                break;
            }
        }
    }
    if (item) {
        if (item.controllerClass) {
            return @{ABRouterControllerClassKey : item.controllerClass};
        } else if (item.controllerBlock) {
            return @{ABRouterControllerBlockKey : item.controllerBlock};
        } else if (item.actionBlock) {
            return @{ABRouterActionBlockKey : item.actionBlock};
        }
    }
    return nil;
}

@end
