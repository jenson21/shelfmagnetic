//
//  NSObject+Runtime.m
//  ShelfMagnetic
//
//  Created by Jian Dong on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "NSObject+Runtime.h"
#import <objc/runtime.h>

@implementation NSObject (Runtime)
//添加方法
bool runtimeAddMethod(Class toClass, SEL selector, Class impClass, SEL impSelector)
{
    Method impMethod = class_getInstanceMethod(impClass, impSelector);
    return class_addMethod(toClass, selector, method_getImplementation(impMethod), method_getTypeEncoding(impMethod));
}

//交换方法的IMP实现
bool runtimeSwizzleMethod(Class class1, SEL selector1, Class class2, SEL selector2)
{
    Method method1 = class_getInstanceMethod(class1, selector1);
    Method method2 = class_getInstanceMethod(class2, selector2);
    if (!method1 || !method2) {
        return false;
    }

    //为class添加方法，否则有可能交换父类IMP
    class_addMethod(class1, selector1, method_getImplementation(method1), method_getTypeEncoding(method1));
    class_addMethod(class2, selector2, method_getImplementation(method2), method_getTypeEncoding(method2));

    //重新获取添加后的method，并交换IMP
    method_exchangeImplementations(class_getInstanceMethod(class1, selector1), class_getInstanceMethod(class2, selector2));

    return true;
}

//交换方法的IMP实现
+ (BOOL)runtimeSwizzleSelector:(SEL)selector1 withSelector:(SEL)selector2
{
    return runtimeSwizzleMethod(self, selector1, self, selector2);
}
@end
