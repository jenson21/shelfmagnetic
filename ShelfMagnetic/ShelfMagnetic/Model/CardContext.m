//
//  CardContext.m
//  YoukuiPhone
//
//  Created by yanghu on 14-7-28.
//  Copyright (c) 2014年 Youku.com inc. All rights reserved.
//

#import "CardContext.h"
@implementation CardHeaderContext
@end

@implementation CardContext

#pragma mark - Property

- (void)setType:(CardType)type
{
    if (_type != type) {
        _type = type;
        
        self.clazz = [self parseClassName:type];
    }
}

- (void)setExtensionType:(CardType)extensionType
{
    if (_extensionType != extensionType) {
        _extensionType = extensionType;
        
        self.extensionClazz = [self parseClassName:extensionType];
    }
}

- (void)setJson:(id)json
{
    if (_json != json) {
        _json = json;
        
        self.error = nil;
    }
}

- (void)setError:(NSError *)error
{
    if (_error != error) {
        _error = error;
        
        _state = error ? CardStateError : CardStateNormal;
    }
}

- (void)setHeaderContext:(CardHeaderContext *)headerContext {
    if (_headerContext != headerContext) {
        _headerContext = headerContext;
        _headerContext.cardContext = self;
    }
}

#pragma mark - Parse

- (NSString *)parseClassName:(CardType)type
{
    NSString *className = nil;
    switch (type) {
        case CardTypeHomeBanner:
            className = @"HTHomeBannerCard";
            break;
        case CardTypeHomeFive:
            className = @"HTHomeFiveCard";
            break;
        case CardTypeHomeTodayNew:
            className = @"HTTodaytNewCard";
            break;
        case CardTypeHomeYiYuanGou:
            className = @"HTOneBuyCard";
            break;
        case CardTypeHomeZhuanTi:
            className = @"HTHomeZhuantiCard";
            break;
        case CardTypeHomeSecondkill:
            className = @"HTSecondKillCard";
            break;
        case CardTypeHomeMeiZhuang:
            className = @"HTHomeVenueCard";
            break;
        case CardTypeHomeMuYing:
            className = @"HTHomeVenueCard";
            break;
        case CardTypeHomeQingShe:
            className = @"HTHomeVenueCard";
            break;
        case CardTypeHomeCaiNiXiHuan:
            className = @"HTCaiNiXiHuanCard";
            break;
        case CardTypeHomeDynamicWeb:
            className = @"HTDynamicWebCard";
            break;
        case CardTypeHomeFeatureAreaTop:
            className = @"HTHomeFeatureAreaTopCard";
            break;
        case CardTypeHomeNewUser:
            className = @"HTHomeNewUserCard";
            break;
        case CardTypeHomeGradient:
            className = @"HTHomeGradientCard";
            break;
        case CardTypeOperateCard:
            className = @"HTOperateCard";
            break;
        case CardTypeMeberCost:
            className = @"HTMeberCostCard";
            break;
        case CardTypeMeberHalf:
            className = @"HTMeberHalfCard";
            break;
        //个人中心cell
        case CardTypeMineOrder:
            className = @"HTProfileOrderCard";
            break;
        case CardTypeMineShuffling:
            className = @"HTProfileShufflingCard";
            break;
        case CardTypeMineActivity:
            className = @"HTProfileActivityCard";
            break;
        case CardTypeMineService:
            className = @"HTProfileServiceCard";
            break;
        case CardTypeMineCaiNiXiHuan:
            className = @"HTCaiNiXiHuanCard";
            break;
     
        case CardTypeGoodsDetailCard:
            className = @"HTGoodsDetailTopCard";
            break;
        case CardTypeGoodsBrandCard:
            className = @"HTGoodsDetailBrandCard";
            break;
        case CardTypeGoodsLikeCard:
            className = @"HTGoodsDetailLikeCard";
            break;
        case CardTypeGoodsDetailDesCard:
            className = @"HTGoodsDetailDesCard";
            break;
        case CardTypeGoodsDiscussCard:
            className = @"HTGoodsDetailDiscussCard";
            break;
        case CardTypeGoodsGiveCard:
            className = @"HTGoodsGiveCard";
            break;
       
        case CardTypeNonMeberDiscount:
            className = @"HTCardDiscountCard";
            break;
        case CardTypeNonMeberHalf:
            className = @"HTHalfPriceCard";
            break;
        case CardTypeNonMeberOneBuy:
            className = @"HTNonMeberOneBuyCard";
            break;
        case CardTypeNonMeberCoupon:
            className = @"HTCouponCard";
            break;
        case CardTypeNonMeberMeDay:
            className = @"HTMemberDayCard";
            break;
        case CardTypeNonMeberGift:
            className = @"HTMemberGiftCard";
            break;
        case CardTypeNonMeberExclusive:
            className = @"HTExclusiveCard";
            break;
        case CardTypeNonMeberExperience:
            className = @"HTExperienceCard";
            break;
        case CardTypeMemberTask:
            className = @"HTMemberTaskCard";
            break;            
        case CardTypeCreactArticleTitle:
            className = @"HT_G_CreateArticleTitleCard";
            break;
        case CardTypeCreactArticleContent:
            className = @"HT_G_CreateArticleContentCard";
            break;
        case CardTypeCreactArticlePhoto:
            className = @"HT_G_CreateArticlePhotoCard";
            break;
        case CardTypeCreactArticleGoods:
            className = @"HT_G_CreateArticleofGoodsCard";
            break;
        case CardTypeArticleInfoBanner:
            className = @"HT_G_ArticleofBannerCard";
            break;
        case CardTypeArticleInfoAuthor:
            className = @"HT_G_ArticleofAuthorCard";
            break;
        case CardTypeArticleInfoContent:
            className = @"HT_G_ArticleofContentCard";
        break;
        case CardTypeArticleInfoGoods:
            className = @"HT_G_ArticleofGoodsCard";
        break;
        case CardTypeArticleInfoComments:
            className = @"HT_G_ArticleofCommentsCard";
        break;
        case CardTypeArticleInfoRecommended:
            className = @"HT_G_ArticleofRecommendedCard";
        break;
        case CardTypeImageView:
            className = @"HTImageViewCard";
        break;
        case CardTypeShopCard:
            className = @"HTShoppingCartCard";
            break;
        default:
            break;
    }
    return className;
}

@end
