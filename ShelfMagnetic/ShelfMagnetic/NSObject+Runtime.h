//
//  NSObject+Runtime.h
//  dolphinHouse
//
//  Created by lifuqing on 2018/9/1.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Runtime)

///交换方法的IMP实现
bool runtimeSwizzleMethod(Class class1, SEL selector1, Class class2, SEL selector2);

///添加方法
bool runtimeAddMethod(Class toClass, SEL selector, Class impClass, SEL impSelector);

///交换当前Class指定方法的IMP实现。建议在+load方法中调用。
+ (BOOL)runtimeSwizzleSelector:(SEL)selector1 withSelector:(SEL)selector2;

@end
