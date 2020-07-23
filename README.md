# shelfmagnetic
Shelfmagnetic architecture is a combination of years of development experience

# Background
During the development process, you will encounter a page that displays a variety of different styles of content, or dynamically displays a certain section. If you put them in VC, then VC will be very bloated and inconvenient to manage. Then this framework came into being to solve this problem.
This framework includes multi-page integration and matching, network requests, data buried points, asynchronous UI rendering, etc. Easy to use, just use VC inheritance.

# Installation with CocoaPods
To integrate Shelfmagnetic into your Xcode project using CocoaPods, specify it in your Podfile:
`pod 'Shelfmagnetic', '~> 0.0.3'`

# Architecture
- Model
  - MagneticContext
- View
  - MagneticTableView
  - MagneticErrorCell
  - JEBaseLoadingView
  - MagneticTableFooterView
  - JEBaseEmptyView
- Controller
  - MagneticController
  - MagneticsController
  - MagneticsControllerProtocol

# Image
![image](https://github.com/jenson21/shelfmagnetic/blob/master/shelfmagenticGuide.png)

# Usage
- Register the controller
   - MagneticContext.h
   ```
   typedef NS_ENUM(NSInteger, MagneticType) {
   MagneticTypeDemo = 1000,
   };
   ```

   - MagneticContext.m
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

- ViewController inherit MagneticsController And implement some functions. Can contain multiple MagneticDemoController.
   - ViewController
   ```
   @interface ViewController : MagneticsController

   NSMutableArray *dataArr = [NSMutableArray array];
   MagneticContext *context = [[MagneticContext alloc]init];
   context.type = MagneticTypeDemo;
   [dataArr addObject:context];

   /**
    dataArr add more VC
    */
   [self requestMagneticsDidSucceedWithMagneticsArray:dataArr];
   ```

- MagneticDemoController inherit MagneticController And implement some functions.
   - MagneticDemoController

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

# contact
* jenson.pitaya@outlook.com

# License
Shelfmagnetic is released under the MIT license. See [LICENSE](https://github.com/jenson21/shelfmagnetic/blob/master/LICENSE) for details.
