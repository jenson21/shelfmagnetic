# shelfmagnetic
Architecture design
磁片架构是结合了多年开发经验并借鉴了某一线互联网公司总结而成，此框架可以快速搭建程序，以注册继承的方式将VC随意组合，大大提升了开发效率和实现一些复杂的功能。

# Installation with CocoaPods
To integrate AFNetworking into your Xcode project using CocoaPods, specify it in your Podfile:
`pod 'Shelfmagnetic', '~> 0.0.1'`

# Architecture
* MagneticContext
* MagneticsControllerProtocol
* MagneticsController

# Usage

1. MagneticContext.h
```
typedef NS_ENUM(NSInteger, MagneticType) {
MagneticTypeDemo = 1000,
};
```

1. MagneticContext.m
```
- (NSString *)parseClassName:(MagneticType)type
{
    NSString *className = nil;
    switch (type) {
        case MagneticTypeNormal:
            className = @"MagneticTypeDemo";
            break;
        default:
            break;
    }
    return className;
}
```

3. ViewController
```
@interface ViewController : MagneticsController ...

NSMutableArray *dataArr = [NSMutableArray array];
MagneticContext *context = [[MagneticContext alloc]init];
context.type = MagneticTypeDemo;
[dataArr addObject:context];

/**
 dataArr add more VC
 */
[self requestMagneticsDidSucceedWithMagneticsArray:dataArr];
```
4. MagneticDemoController

```
- (void)didFinishInitConfigurationInCardsController:(CardsController *)cardsController {
    // After completing initial monitoring, data processing, and successful interface request
}

- (NSString *)magneticRequestURLInMagneticsController:(MagneticsController *)magneticsController{
    //Request url, asynchronous request must be implemented
    return @"https://github.com/jenson21/shelfmagnetic";
}

- (NSDictionary *)magneticRequestParametersInMagneticsController:(MagneticsController *)magneticsController{
    //Requested parameters
    return nil;
}
```

# Work contact
* jenson.pitaya@outlook.com

# License
Shelfmagnetic is released under the MIT license. See [LICENSE](https://github.com/jenson21/shelfmagnetic/blob/master/LICENSE) for details.
