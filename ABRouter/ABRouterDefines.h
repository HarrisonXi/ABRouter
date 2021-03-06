// The MIT License
//
// Copyright (c) 2019-2020 harrisonxi.com
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

#ifndef ABRouterDefines_h
#define ABRouterDefines_h

typedef NS_OPTIONS(NSInteger, ABRouterOption) {
    ABRouterOptionNone = 0, // only match default option
    ABRouterOptionA = 1,    // A has the highest priority
    ABRouterOptionB = 1 << 1,
    ABRouterOptionC = 1 << 2,
    ABRouterOptionD = 1 << 3,
    ABRouterOptionAll = 0xF // match all options
};

typedef UIViewController * (^ABRouterControllerBlock)(NSDictionary *params);
typedef id (^ABRouterActionBlock)(NSDictionary *params);

extern const NSString *ABRouterRouteKey; // value is the route url passed in match method
extern const NSString *ABRouterModuleKey; // value is the route module registered in map method
extern const NSString *ABRouterOptionKey; // value is a NSNumber of matched ABRouterOption
extern const NSString *ABRouterControllerClassKey; // return controller class if the router is the specified type
extern const NSString *ABRouterControllerBlockKey; // return controller block if the router is the specified type
extern const NSString *ABRouterActionBlockKey; // return action block if the router is the specified type

#endif /* ABRouterDefines_h */
