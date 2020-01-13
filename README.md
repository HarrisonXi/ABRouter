![GitHub](https://img.shields.io/github/license/HarrisonXi/ABRouter.svg)
![Cocoapods](https://img.shields.io/cocoapods/v/ABRouter.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/ABRouter.svg)
[![Travis (.org) branch](https://img.shields.io/travis/HarrisonXi/ABRouter/master.svg)](https://travis-ci.org/HarrisonXi/ABRouter)

# ABRouter

URL Router with ABTest feature for iOS.

# Feature

- map route to controller with class
- map route to controller with block (new)
- map route to action block
- map one route to multiple target with ABTest option (new)

# Usage

### Map route to controller

Map route to controller with class.

```
[[ABRouter shared] map:@"/list" toControllerClass:[ListViewController class]];
```

Use route to get the controller. ABRouter will create a new controller instance with the matched class.

```
UIViewController *vc = [[ABRouter shared] matchController:@"/list"];
```

If you want to do some additional actions before you get the controller. Or you are going to get a singleton controller instance.

```
[[ABRouter shared] map:@"/list" toControllerBlock:^UIViewController *(NSDictionary *params) {
    ListViewController *listVC = [ListViewController new];
    listVC.view.backgroundColor = [UIColor greenColor];
    return listVC;
}];

[[ABRouter shared] map:@"/list" toControllerBlock:^UIViewController *(NSDictionary *params) {
    return [ListViewController shared];
}];
```

Use route to get the controller as usual. ABRouter will get the controller from the return value of controller block.

```
UIViewController *vc = [[ABRouter shared] matchController:@"/list"];
```

### Get params from route

Map route to controller.

```
[[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailViewController")];
```

Use route to get the controller and params.

```
UIViewController *vc = [[ABRouter shared] matchController:@"/detail/1?optionalParam=2"];
NSLog(@"%@", vc.params);
```

The log result will be:

```
{
    ABRouterControllerClassKey = DetailViewController;
    ABRouterModuleKey = "/detail/:detailId";
    ABRouterOptionKey = 0;
    ABRouterRouteKey = "/detail/1?optionalParam=2";
    "detailId" = 1;
    "optionalParam" = 2;
}
```

The param `detailId` is a required param. `optionalParam` is a optional param. Other params are the internal params of ABRouter.

### List of internal params

```
ABRouterRouteKey: value is the route url passed in match method
ABRouterModuleKey: value is the route module registered in map method
ABRouterOptionKey: value is a NSNumber of matched ABRouterOption
ABRouterControllerClassKey: return controller class if the router is the specified type
ABRouterControllerBlockKey: return controller block if the router is the specified type
ABRouterActionBlockKey: return action block if the router is the specified type
```

### Map route to action block

An example of map route to action block:

```
__weak MainViewController *weakSelf = self;
[[ABRouter shared] map:@"/alert/:msg" toActionBlock:^id(NSDictionary *params) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:params[@"title"]
                                                                   message:params[@"msg"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [weakSelf presentViewController:alert animated:YES completion:nil];
    return @(YES);
}];
```

Call this action block.

```
[[ABRouter shared] callActionBlock:@"/alert/test message?title=test title"];
```

### ABTest feature

Map to controller classes with ab option.

```
[[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailAViewController") abOption:ABRouterOptionA];
[[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailBViewController") abOption:ABRouterOptionB];
```

Write your ABTest logic with ab option.

```
if (enableA) {
    vc = [[ABRouter shared] matchController:@"/detail/1" abOption:ABRouterOptionA];
} else {
    vc = [[ABRouter shared] matchController:@"/detail/2" abOption:ABRouterOptionB];
}
```

ABRouterOptionA has the highest priority. Follow code will get a DetailAViewController.

```
vc = [[ABRouter shared] matchController:@"/detail/1" abOption:ABRouterOptionA | ABRouterOptionB];
```

### App schemes

ABRouter will filter out your app schemes. Both `vc1` and `vc2` will get a list controller.

```
UIViewController *vc1 = [[ABRouter shared] matchController:@"/list"];
UIViewController *vc2 = [[ABRouter shared] matchController:@"abrouter://list"];
```

# Migrate from HHRouter

### Public methods

```
- (void)map:(NSString *)route toBlock:(nullable ABRouterActionBlock)block __deprecated_msg("use -map:toActionBlock: instead");
- (ABRouterActionBlock)matchBlock:(NSString *)route __deprecated_msg("use -matchActionBlock: instead");
- (id)callBlock:(NSString *)route __deprecated_msg("use -callActionBlock: instead");
- (BOOL)canRoute:(NSString *)route __deprecated_msg("use -canMapController: & -canMapAction: instead");
```

### Internal param keys

```
@"controller_class" -> ABRouterControllerClassKey or ABRouterControllerBlockKey
@"block" -> ABRouterActionBlockKey
@"route" -> ABRouterRouteKey
@"module" -> ABRouterModuleKey
```

# Installation

### CocoaPods.

1. Add `pod 'ABRouter'` to your Podfile
2. Run `pod install` or `pod update`
3. Import `<ABRouter/ABRouter.h>`

### Manually

1. Download source files and add them into your project
2. Import `"ABRouter.h"`

# 中文介绍

iOS平台上一个带ABTest功能的URL路由。从HHRouter改进而来。

# 主要功能

- 将路由映射到一个controller的class上
- 将路由映射到一个返回controller的block上（新功能）
- 将路由映射到一个进行事件操作的block上
- 将一个路由通过不同的ABTest选项映射到多个目标上（新功能）

# 使用方法

### 将路由映射到controller

将路由映射到一个controller的class上。

```
[[ABRouter shared] map:@"/list" toControllerClass:[ListViewController class]];
```

使用路由来获得controller。ABRouter将用对应的class创建一个controller的新实例。

```
UIViewController *vc = [[ABRouter shared] matchController:@"/list"];
```

如果你想要在获得controller之前做一些额外的操作。或者你要获得controller单例。

```
[[ABRouter shared] map:@"/list" toControllerBlock:^UIViewController *(NSDictionary *params) {
    ListViewController *listVC = [ListViewController new];
    listVC.view.backgroundColor = [UIColor greenColor];
    return listVC;
}];

[[ABRouter shared] map:@"/list" toControllerBlock:^UIViewController *(NSDictionary *params) {
    return [ListViewController shared];
}];
```

像往常一样使用路由来获得controller。ABRouter将使用block的返回值来获得controller。

```
UIViewController *vc = [[ABRouter shared] matchController:@"/list"];
```

### 从路由中获得参数

将路由映射到controller。

```
[[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailViewController")];
```

用路由来获得controller和参数。

```
UIViewController *vc = [[ABRouter shared] matchController:@"/detail/1?optionalParam=2"];
NSLog(@"%@", vc.params);
```

日志打印结果：

```
{
    ABRouterControllerClassKey = DetailViewController;
    ABRouterModuleKey = "/detail/:detailId";
    ABRouterOptionKey = 0;
    ABRouterRouteKey = "/detail/1?optionalParam=2";
    "detailId" = 1;
    "optionalParam" = 2;
}
```

参数`detailId`是一个必选参数。`optionalParam`是一个可选参数。其它参数是ABRouter的内部参数。

### 内部参数列表

```
ABRouterRouteKey: 传入match系列方法的路由URL
ABRouterModuleKey: 通过map系列方法注册过的路由模块
ABRouterOptionKey: 匹配到的ABRouterOption对应的NSNumber类型值
ABRouterControllerClassKey: 如果路由是指定类型，则返回对应的controller class
ABRouterControllerBlockKey: 如果路由是指定类型，则返回对应的controller block
ABRouterActionBlockKey: 如果路由是指定类型，则返回对应的action block
```

### 将路由映射到action block

一个将路由映射到action block的例子：

```
__weak MainViewController *weakSelf = self;
[[ABRouter shared] map:@"/alert/:msg" toActionBlock:^id(NSDictionary *params) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:params[@"title"]
                                                                   message:params[@"msg"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [weakSelf presentViewController:alert animated:YES completion:nil];
    return @(YES);
}];
```

调用这个action block。

```
[[ABRouter shared] callActionBlock:@"/alert/test message?title=test title"];
```

### ABTest功能

将路由带着AB选项映射到controller。

```
[[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailAViewController") abOption:ABRouterOptionA];
[[ABRouter shared] map:@"/detail/:detailId" toControllerClass:NSClassFromString(@"DetailBViewController") abOption:ABRouterOptionB];
```

利用AB选项编写你的ABTest逻辑。

```
if (enableA) {
    vc = [[ABRouter shared] matchController:@"/detail/1" abOption:ABRouterOptionA];
} else {
    vc = [[ABRouter shared] matchController:@"/detail/2" abOption:ABRouterOptionB];
}
```

ABRouterOptionA拥有最高的优先级。下面的代码将获得一个DetailAViewController。

```
vc = [[ABRouter shared] matchController:@"/detail/1" abOption:ABRouterOptionA | ABRouterOptionB];
```

### 应用scheme

ABRouter将过滤掉你应用的scheme。`vc1`和`vc2`都可以获得一个列表controller。

```
UIViewController *vc1 = [[ABRouter shared] matchController:@"/list"];
UIViewController *vc2 = [[ABRouter shared] matchController:@"abrouter://list"];
```

# 从HHRouter迁移

### 公共方法改变

```
- (void)map:(NSString *)route toBlock:(nullable ABRouterActionBlock)block __deprecated_msg("use -map:toActionBlock: instead");
- (ABRouterActionBlock)matchBlock:(NSString *)route __deprecated_msg("use -matchActionBlock: instead");
- (id)callBlock:(NSString *)route __deprecated_msg("use -callActionBlock: instead");
- (BOOL)canRoute:(NSString *)route __deprecated_msg("use -canMapController: & -canMapAction: instead");
```

### 内部参数Key值改变

```
@"controller_class" -> ABRouterControllerClassKey or ABRouterControllerBlockKey
@"block" -> ABRouterActionBlockKey
@"route" -> ABRouterRouteKey
@"module" -> ABRouterModuleKey
```

# 安装

### CocoaPods.

1. 将`pod 'ABRouter'`添加到你的Podfile
2. 运行`pod install`或者`pod update`
3. 引用`<ABRouter/ABRouter.h>`

### 人工

1. 下载源代码并添加到工程
2. 引用`"ABRouter.h"`
