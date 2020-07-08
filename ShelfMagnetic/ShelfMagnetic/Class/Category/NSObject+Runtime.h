//
//  NSObject+Runtime.h
//  ShelfMagnetic
//
//  Created by Jenson on 2020/7/5.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Runtime)
///交换方法的IMP实现
bool runtimeSwizzleMethod(Class class1, SEL selector1, Class class2, SEL selector2);

///添加方法
bool runtimeAddMethod(Class toClass, SEL selector, Class impClass, SEL impSelector);

///交换当前Class指定方法的IMP实现。建议在+load方法中调用。
+ (BOOL)runtimeSwizzleSelector:(SEL)selector1 withSelector:(SEL)selector2;
@end

NS_ASSUME_NONNULL_END
