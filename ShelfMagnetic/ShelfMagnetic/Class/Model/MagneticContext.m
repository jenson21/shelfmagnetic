//
//  MagneticContext.m
//  ShelfMagnetic
//
//  Created by Jenson on 2020/5/31.
//  Copyright © 2020 Jenson. All rights reserved.
//

#import "MagneticContext.h"

@implementation MagneticHeaderContext
@end

@implementation MagneticContext

- (void)setType:(MagneticType)type{
    if (_type != type) {
        _type = type;
        
        self.clazz = [self parseClassName:type];
    }
}

- (void)setExtensionType:(MagneticType)extensionType{
    if (_extensionType != extensionType) {
        _extensionType = extensionType;
        
        self.extensionClazz = [self parseClassName:extensionType];
    }
}

- (void)setJson:(id)json{
    if (_json != json) {
        _json = json;
        
        self.error = nil;
    }
}

- (void)setError:(NSError *)error{
    if (_error != error) {
        _error = error;
        
        _state = error ? MagneticStateError : MagneticStateNormal;
    }
}

- (void)setHeaderContext:(MagneticHeaderContext *)headerContext {
    if (_headerContext != headerContext) {
        _headerContext = headerContext;
        _headerContext.magneticContext = self;
    }
}

#pragma mark - Parse

- (NSString *)parseClassName:(MagneticType)type{
    NSString *className = nil;
    switch (type) {
            case MagneticTypeDemo:
            className = @"MagneticDemoController";
            break;
            case MagneticTypeDemo2:
            className = @"MagneticDemo2Controller";
            break;
            case MagneticTypeDemo3:
            className = @"MagneticDemo3Controller";
            break;
            case MagneticTypeDemo4:
            className = @"MagneticDemo4Controller";
            break;
            case MagneticTypeDemo5:
            className = @"MagneticDemo5Controller";
            break;
        default:
            break;
    }
    return className;
}

@end
