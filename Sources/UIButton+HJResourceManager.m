//
//  UIButton+HJResourceManager.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2016. 4. 8
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <objc/runtime.h>
#import <HJAsyncHttpDeliverer/HJAsyncHttpDeliverer.h>
#import <HJResourceManager/HJResourceManager.h>
#import "HJProgressViewProtocol.h"
#import "UIButton+HJResourceManager.h"

#define     kControlStateKey    @"controlStateKey"
#define     kBackgroundImageKey @"backgroundImageKey"

static char kResourceManagerObserving;
static char kAsyncHttpDelivererObserving;
static char kAsyncDelivererIssuedId;
static char kHJButtonProgressView;
static char kResourceKey;
static char kContentLength;

@implementation UIButton (HJResourceManager)

@dynamic hjAsyncDelivererIssuedId;
@dynamic hjButtonProgressView;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)asyncHttpDelivererReport:(NSNotification *)notification
{
    if( (objc_getAssociatedObject(self, &kResourceKey) == nil) || (self.hjAsyncDelivererIssuedId == 0) || (self.hjButtonProgressView == nil) ) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    HJAsyncHttpDelivererStatus status = (HJAsyncHttpDelivererStatus)[userInfo[HJAsyncHttpDelivererParameterKeyStatus] integerValue];
    NSUInteger issuedId = (NSUInteger)[userInfo[HJAsyncHttpDelivererParameterKeyIssuedId] unsignedIntegerValue];
    if( self.hjAsyncDelivererIssuedId != issuedId ) {
        return;
    }
    
    switch( status ) {
        case HJAsyncHttpDelivererstatusConnected :
            if( [self.hjButtonProgressView respondsToSelector:@selector(hjProgressViewConnected:contentLength:)] == YES ) {
                NSNumber *contentLengthNumber = userInfo[HJAsyncHttpDelivererParameterKeyContentLength];
                objc_setAssociatedObject(self, &kContentLength, contentLengthNumber, OBJC_ASSOCIATION_RETAIN);
                [self.hjButtonProgressView hjProgressViewConnected:self contentLength:contentLengthNumber.unsignedIntegerValue];
            }
            break;
        case HJAsyncHttpDelivererStatusTransfering :
            if( [self.hjButtonProgressView respondsToSelector:@selector(hjProgressViewTransfering:transferLength:contentLength:)] == YES ) {
                NSUInteger contentLength = [objc_getAssociatedObject(self, &kContentLength) unsignedIntegerValue];
                NSUInteger tranferLength = [userInfo[HJAsyncHttpDelivererParameterKeyAmountTransferedLength] unsignedIntegerValue];
                if( contentLength <= 0 ) {
                    NSNumber *contentLengthNumber = userInfo[HJAsyncHttpDelivererParameterKeyContentLength];
                    objc_setAssociatedObject(self, &kContentLength, contentLengthNumber, OBJC_ASSOCIATION_RETAIN);
                    contentLength = contentLengthNumber.unsignedIntegerValue;
                }
                [self.hjButtonProgressView hjProgressViewTransfering:self transferLength:tranferLength contentLength:contentLength];
            }
            break;
        case HJAsyncHttpDelivererStatusDone :
            if( [self.hjButtonProgressView respondsToSelector:@selector(hjProgressViewTransferDone:)] == YES ) {
                [self.hjButtonProgressView hjProgressViewTransferDone:self];
            }
            objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJAsyncHttpDelivererNotification object:nil];
            break;
        case HJAsyncHttpDelivererStatusFailed :
            if( [self.hjButtonProgressView respondsToSelector:@selector(hjProgressViewTransferFailed:)] == YES ) {
                [self.hjButtonProgressView hjProgressViewTransferFailed:self];
            }
            objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJAsyncHttpDelivererNotification object:nil];
            break;
        case HJAsyncHttpDelivererStatusCanceled :
            if( [self.hjButtonProgressView respondsToSelector: @selector(hjProgressViewTransferCanceled:)] == YES ) {
                [self.hjButtonProgressView hjProgressViewTransferCanceled: self];
            }
            objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJAsyncHttpDelivererNotification object:nil];
            break;
        default :
            break;
    }
}

- (void)resourceManagerReport:(NSNotification *)notification
{
    NSString *lookingResourceKey = objc_getAssociatedObject(self, &kResourceKey);
    if( lookingResourceKey == nil ) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *resourceQuery = userInfo[HJResourceManagerParameterKeyResourceQuery];
    NSString *resourceKey = [[HJResourceManager defaultHJResourceManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( [resourceKey isEqualToString:lookingResourceKey] == NO ) {
        return;
    }
    UIControlState state = (UIControlState)[resourceQuery[kControlStateKey] integerValue];
    HJResourceManagerRequestStatus status = (HJResourceManagerRequestStatus)[userInfo[HJResourceManagerParameterKeyRequestStatus] integerValue];
    
    id dataObject;
    
    switch( status ) {
        case HJResourceManagerRequestStatusDownloadStarted :
            objc_setAssociatedObject(self, &kAsyncDelivererIssuedId, userInfo[HJResourceManagerParameterKeyAsyncHttpDelivererIssuedId], OBJC_ASSOCIATION_RETAIN);
            break;
        case HJResourceManagerRequestStatusLoaded :
            objc_setAssociatedObject(self, &kResourceManagerObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJResourceManagerNotification object:nil];
            dataObject = userInfo[HJResourceManagerParameterKeyDataObject];
            if( [dataObject isKindOfClass:[UIImage class]] == YES ) {
                if( [resourceQuery[kBackgroundImageKey] boolValue] == YES ) {
                    [self setBackgroundImage:(UIImage *)dataObject forState:state];
                } else {
                    [self setImage:(UIImage *)dataObject forState:state];
                }
                [self setNeedsLayout];
            }
            break;
        case HJResourceManagerRequestStatusLoadFailed :
        case HJResourceManagerRequestStatusUnknownError :
            objc_setAssociatedObject(self, &kResourceManagerObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJResourceManagerNotification object:nil];
            break;
        default :
            break;
    }
}

- (void)setImageUrl:(NSString *)urlString
{
    [self setImageUrl:urlString placeholderImage:nil cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil forState:UIControlStateNormal completion:nil];
}

- (void)setImageUrl:(NSString *)urlString forState:(UIControlState)state
{
    [self setImageUrl:urlString placeholderImage:nil cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:completion];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:remakerName remakerParameter:remakerParameter cipherName:nil forState:(UIControlState)state completion:completion];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    if( urlString.length == 0 ) {
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, remakerName, remakerParameter, cipherName, NO);
            });
        }
        return;
    }
    
    NSMutableDictionary *resourceQuery = [NSMutableDictionary new];
    if( resourceQuery == nil ) {
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, urlString, remakerName, remakerParameter, cipherName, NO);
            });
        }
        return;
    }
    resourceQuery[HJResourceQueryKeyRequestValue] = urlString;
    resourceQuery[HJResourceQueryKeyDataType] = @(HJResourceDataTypeImage);
    if( remakerName.length > 0 ) {
        resourceQuery[HJResourceQueryKeyRemakerName] = remakerName;
        if( remakerParameter != nil ) {
            resourceQuery[HJResourceQueryKeyRemakerParameter] = remakerParameter;
        }
    }
    if( cipherName.length > 0 ) {
        resourceQuery[HJResourceQueryKeyCipherName] = cipherName;
    }
    resourceQuery[kControlStateKey] = @(state);
    NSString *resourceKey = [[HJResourceManager defaultHJResourceManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( resourceKey == nil ) {
        [self setImage:nil forState:state];
        [self setNeedsLayout];
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, urlString, remakerName, remakerParameter, cipherName, NO);
            });
        }
        return;
    }
    objc_setAssociatedObject(self, &kResourceKey, resourceKey, OBJC_ASSOCIATION_RETAIN);
    if( placeholderImage != nil ) {
        [self setImage:placeholderImage forState:state];
        [self setNeedsLayout];
    }
    resourceQuery[HJResourceQueryKeyNotifyDeliverer] = @(self.hjButtonProgressView != nil);
    if( [objc_getAssociatedObject(self, &kResourceManagerObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kResourceManagerObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceManagerReport:) name:HJResourceManagerNotification object:nil];
    }
    [[HJResourceManager defaultHJResourceManager] resourceForQuery:resourceQuery cutInLine:cutInLine completion:^(NSDictionary *resultDict) {
        if( completion != nil ) {
            NSString *resourceKey = [[HJResourceManager defaultHJResourceManager] resourceKeyStringFromResourceQuery:resultDict[HJResourceManagerParameterKeyResourceQuery]];
            NSString *lookingResourceKey = objc_getAssociatedObject(self, &kResourceKey);
            BOOL stillLooking = [lookingResourceKey isEqualToString:resourceKey];
            id dataObject = resultDict[HJResourceManagerParameterKeyDataObject];
            UIImage *image = ([dataObject isKindOfClass:[UIImage class]] == YES) ? (UIImage *)dataObject : nil;
            completion(image, urlString, remakerName, remakerParameter, cipherName, !stillLooking);
        }
    }];
}

- (void)setBackgroundImageUrl:(NSString *)urlString
{
    [self setBackgroundImageUrl:urlString placeholderImage:nil cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil forState:UIControlStateNormal completion:nil];
}

- (void)setBackgroundImageUrl:(NSString *)urlString forState:(UIControlState)state
{
    [self setBackgroundImageUrl:urlString placeholderImage:nil cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:nil];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state
{
    [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:nil];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state
{
    [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:nil];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:nil remakerParameter:nil cipherName:nil forState:state completion:completion];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:remakerName remakerParameter:remakerParameter cipherName:nil forState:(UIControlState)state completion:completion];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    if( urlString.length == 0 ) {
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, remakerName, remakerParameter, cipherName, NO);
            });
        }
        return;
    }
    
    NSMutableDictionary *resourceQuery = [NSMutableDictionary new];
    if( resourceQuery == nil ) {
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, urlString, remakerName, remakerParameter, cipherName, NO);
            });
        }
        return;
    }
    resourceQuery[HJResourceQueryKeyRequestValue] = urlString;
    if( remakerName.length > 0 ) {
        resourceQuery[HJResourceQueryKeyRemakerName] = remakerName;
        if( remakerParameter != nil ) {
            resourceQuery[HJResourceQueryKeyRemakerParameter] = remakerParameter;
        }
    }
    if( cipherName.length > 0 ) {
        resourceQuery[HJResourceQueryKeyCipherName] = cipherName;
    }
    resourceQuery[kControlStateKey] = @(state);
    resourceQuery[kBackgroundImageKey] = @(1);
    NSString *resourceKey = [[HJResourceManager defaultHJResourceManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( resourceKey == nil ) {
        [self setBackgroundImage:nil forState:state];
        [self setNeedsLayout];
        if( completion != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, urlString, remakerName, remakerParameter, cipherName, NO);
            });
        }
        return;
    }
    objc_setAssociatedObject(self, &kResourceKey, resourceKey, OBJC_ASSOCIATION_RETAIN);
    if( placeholderImage != nil ) {
        [self setBackgroundImage:placeholderImage forState:state];
        [self setNeedsLayout];
    }
    if( [objc_getAssociatedObject(self, &kResourceManagerObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kResourceManagerObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceManagerReport:) name:HJResourceManagerNotification object:nil];
    }
    [[HJResourceManager defaultHJResourceManager] resourceForQuery:resourceQuery cutInLine:cutInLine completion:^(NSDictionary *resultDict) {
        if( completion != nil ) {
            NSString *resourceKey = [[HJResourceManager defaultHJResourceManager] resourceKeyStringFromResourceQuery:resultDict[HJResourceManagerParameterKeyResourceQuery]];
            NSString *lookingResourceKey = objc_getAssociatedObject(self, &kResourceKey);
            BOOL stillLooking = [lookingResourceKey isEqualToString:resourceKey];
            id dataObject = resultDict[HJResourceManagerParameterKeyDataObject];
            UIImage *image = ([dataObject isKindOfClass:[UIImage class]] == YES) ? (UIImage *)dataObject : nil;
            completion(image, urlString, remakerName, remakerParameter, cipherName, !stillLooking);
        }
    }];
}

- (void)cancel
{
    objc_setAssociatedObject(self, &kResourceKey, nil, OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)hjAsyncDelivererIssuedId
{
    return [objc_getAssociatedObject(self, &kAsyncDelivererIssuedId) unsignedIntegerValue];
}

- (id)hjButtonProgressView
{
    return objc_getAssociatedObject(self, &kHJButtonProgressView);
}

- (void)setHjButtonProgressView:(id)hjButtonProgressView
{
    if( [hjButtonProgressView conformsToProtocol:@protocol(HJProgressViewProtocol)] == NO ) {
        return;
    }
    
    if( [objc_getAssociatedObject(self, &kAsyncHttpDelivererObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncHttpDelivererReport:) name:HJAsyncHttpDelivererNotification object:nil];
    }
    objc_setAssociatedObject(self, &kHJButtonProgressView, hjButtonProgressView, OBJC_ASSOCIATION_RETAIN);
}

@end
