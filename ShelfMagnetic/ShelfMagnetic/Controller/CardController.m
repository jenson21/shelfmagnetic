//
//  CardController.m
//  dolphinHouse
//
//  Created by lifuqing on 2018/8/31.
//  Copyright © 2018年 HTJ. All rights reserved.
//

#import "CardController.h"
#import "CardsController.h"

@interface CardController ()

/* Cache */
@property (nonatomic)           BOOL        showCardError;
@property (nonatomic)           BOOL        showCardHeader;
@property (nonatomic)           BOOL        showCardFooter;
@property (nonatomic)           BOOL        showCardSpacing;
@property (nonatomic)           NSInteger   rowCountCache;
@property (nonatomic, copy)   NSArray     *rowHeightsCache;
@property (nonatomic)           NSInteger   extensionRowIndex;
/* RequestMore */
@property (nonatomic)           BOOL        canRequestMoreData;

@end



@implementation CardController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [_jsonClient cancelAllOperations];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - Property

- (void)setCardContext:(CardContext *)cardContext
{
    _cardContext = cardContext;
}

- (void)setIsPrepared:(BOOL)isPrepared
{
    if (_isPrepared != isPrepared) {
        _isPrepared = isPrepared;
        
        [self.delegate refreshCardWithType:self.cardContext.type];
    }
}



#pragma mark - Lazy Loading

//- (NXHttpManager *)httpManager
//{
//    if (!_httpManager) {
//        _httpManager = [NXHttpManager sharedHttpManager];
//    }
//    return _httpManager;
//}



#pragma mark Card Content

//内容行数
- (NSInteger)cardsController:(CardsController *)cardsController rowCountForCardContentInTableView:(CardTableView *)tableView
{
    return 0;
}

//内容行高
- (CGFloat)cardsController:(CardsController *)cardsController rowHeightForCardContentAtIndex:(NSInteger)index
{
    return 0.0;
}

//复用内容视图
- (void)cardsController:(CardsController *)cardsController reuseCell:(UITableViewCell *)cell forCardContentAtIndex:(NSInteger)index
{
    
}

#pragma mark Card Spacing

//卡片底部间距
- (CGFloat)cardsController:(CardsController *)cardsController heightForCardSpacingInTableView:(CardTableView *)tableView
{
    return 10.0;
}

#pragma mark Card Error

//是否显示卡片错误提示
- (BOOL)cardsController:(CardsController *)cardsController shouldShowCardErrorWithCode:(CardErrorCode)errorCode
{
    return NO;
}



#pragma mark - Error

//请求错误卡片数据
- (void)requestErrorCardData
{
    CardErrorCode errorCode = _cardContext.error.code;
    if (errorCode == CardErrorCodeNetwork || errorCode == CardErrorCodeFailed) { //卡片请求失败
        //显示加载状态
        _cardContext.state = CardStateLoading;
        [self.cardsController refreshCardWithType:_cardContext.type];
        
        //重新请求数据
        [self.cardsController requestCardDataWithController:self];
    }
}


@end
