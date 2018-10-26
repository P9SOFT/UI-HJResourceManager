//
//  UIImageView+HJResourceManager.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2013. 11. 5.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <objc/runtime.h>
#import <HJAsyncHttpDeliverer/HJAsyncHttpDeliverer.h>
#import <HJResourceManager/HJResourceManager.h>
#import "HJProgressViewProtocol.h"
#import "UIImageView+HJResourceManager.h"

static char kResourceManagerObserving;
static char kAsyncHttpDelivererObserving;
static char kAsyncDelivererIssuedId;
static char kHJImageProgressView;
static char kResourceKey;
static char kContentLength;

@implementation UIImageView (HJResourceManager)

@dynamic hjAsyncDelivererIssuedId;
@dynamic hjImageProgressView;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)asyncHttpDelivererReport:(NSNotification *)notification
{
    if( (objc_getAssociatedObject(self, &kResourceKey) == nil) || (self.hjAsyncDelivererIssuedId == 0) || (self.hjImageProgressView == nil) ) {
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
            if( [self.hjImageProgressView respondsToSelector:@selector(hjProgressViewConnected:contentLength:)] == YES ) {
                NSNumber *contentLengthNumber = userInfo[HJAsyncHttpDelivererParameterKeyContentLength];
                objc_setAssociatedObject(self, &kContentLength, contentLengthNumber, OBJC_ASSOCIATION_RETAIN);
                [self.hjImageProgressView hjProgressViewConnected:self contentLength:contentLengthNumber.unsignedIntegerValue];
            }
            break;
        case HJAsyncHttpDelivererStatusTransfering :
            if( [self.hjImageProgressView respondsToSelector:@selector(hjProgressViewTransfering:transferLength:contentLength:)] == YES ) {
                NSUInteger contentLength = [objc_getAssociatedObject(self, &kContentLength) unsignedIntegerValue];
                NSUInteger tranferLength = [userInfo[HJAsyncHttpDelivererParameterKeyAmountTransferedLength] unsignedIntegerValue];
                if( contentLength <= 0 ) {
                    NSNumber *contentLengthNumber = userInfo[HJAsyncHttpDelivererParameterKeyContentLength];
                    objc_setAssociatedObject(self, &kContentLength, contentLengthNumber, OBJC_ASSOCIATION_RETAIN);
                    contentLength = contentLengthNumber.unsignedIntegerValue;
                }
                [self.hjImageProgressView hjProgressViewTransfering:self transferLength:tranferLength contentLength:contentLength];
            }
            break;
        case HJAsyncHttpDelivererStatusDone :
            if( [self.hjImageProgressView respondsToSelector:@selector(hjProgressViewTransferDone:)] == YES ) {
                [self.hjImageProgressView hjProgressViewTransferDone:self];
            }
            objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJAsyncHttpDelivererNotification object:nil];
            break;
        case HJAsyncHttpDelivererStatusFailed :
            if( [self.hjImageProgressView respondsToSelector:@selector(hjProgressViewTransferFailed:)] == YES ) {
                [self.hjImageProgressView hjProgressViewTransferFailed:self];
            }
            objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJAsyncHttpDelivererNotification object:nil];
            break;
        case HJAsyncHttpDelivererStatusCanceled :
            if( [self.hjImageProgressView respondsToSelector: @selector(hjProgressViewTransferCanceled:)] == YES ) {
                [self.hjImageProgressView hjProgressViewTransferCanceled: self];
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
                self.image = (UIImage *)dataObject;
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
    [self setImageUrl:urlString placeholderImage:nil cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil completion:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:NO remakerName:nil remakerParameter:nil cipherName:nil completion:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:nil remakerParameter:nil cipherName:nil completion:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine completion:(HJImageViewCompletionBlock)completion
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:nil remakerParameter:nil cipherName:nil completion:completion];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter completion:(HJImageViewCompletionBlock)completion
{
    [self setImageUrl:urlString placeholderImage:placeholderImage cutInLine:cutInLine remakerName:remakerName remakerParameter:remakerParameter cipherName:nil completion:completion];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName completion:(HJImageViewCompletionBlock)completion
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
    NSString *resourceKey = [[HJResourceManager defaultHJResourceManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( resourceKey == nil ) {
        self.image = nil;
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
        self.image = placeholderImage;
        [self setNeedsLayout];
    }
    resourceQuery[HJResourceQueryKeyNotifyDeliverer] = @(self.hjImageProgressView != nil);
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

- (id)hjImageProgressView
{
    return objc_getAssociatedObject(self, &kHJImageProgressView);
}

- (void)setHjImageProgressView:(id)hjImageProgressView
{
    if( [hjImageProgressView conformsToProtocol:@protocol(HJProgressViewProtocol)] == NO ) {
        return;
    }
    
    if( [objc_getAssociatedObject(self, &kAsyncHttpDelivererObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kAsyncHttpDelivererObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncHttpDelivererReport:) name:HJAsyncHttpDelivererNotification object:nil];
    }
    objc_setAssociatedObject(self, &kHJImageProgressView, hjImageProgressView, OBJC_ASSOCIATION_RETAIN);
}

@end
