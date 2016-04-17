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

@dynamic asyncDelivererIssuedId;
@dynamic hjButtonProgressView;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)asyncHttpDelivererReport:(NSNotification *)notification
{
    if( (objc_getAssociatedObject(self, &kResourceKey) == nil) || (self.asyncDelivererIssuedId == 0) || (self.hjButtonProgressView == nil) ) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    HJAsyncHttpDelivererStatus status = (HJAsyncHttpDelivererStatus)[[userInfo objectForKey:HJAsyncHttpDelivererParameterKeyStatus] integerValue];
    NSUInteger issuedId = (NSUInteger)[[userInfo objectForKey:HJAsyncHttpDelivererParameterKeyIssuedId] unsignedIntegerValue];
    if( self.asyncDelivererIssuedId != issuedId ) {
        return;
    }
    
    switch( status ) {
        case HJAsyncHttpDelivererstatusConnected :
            if( [self.hjButtonProgressView respondsToSelector:@selector(hjProgressViewConnected:contentLength:)] == YES ) {
                NSNumber *contentLengthNumber = [userInfo objectForKey:HJAsyncHttpDelivererParameterKeyContentLength];
                objc_setAssociatedObject(self, &kContentLength, contentLengthNumber, OBJC_ASSOCIATION_RETAIN);
                [self.hjButtonProgressView hjProgressViewConnected:self contentLength:[contentLengthNumber unsignedIntegerValue]];
            }
            break;
        case HJAsyncHttpDelivererStatusTransfering :
            if( [self.hjButtonProgressView respondsToSelector:@selector(hjProgressViewTransfering:transferLength:contentLength:)] == YES ) {
                NSUInteger contentLength = [objc_getAssociatedObject(self, &kContentLength) unsignedIntegerValue];
                NSUInteger tranferLength = [[userInfo objectForKey:HJAsyncHttpDelivererParameterKeyAmountTransferedLength] unsignedIntegerValue];
                if( contentLength <= 0 ) {
                    NSNumber *contentLengthNumber = [userInfo objectForKey:HJAsyncHttpDelivererParameterKeyContentLength];
                    objc_setAssociatedObject(self, &kContentLength, contentLengthNumber, OBJC_ASSOCIATION_RETAIN);
                    contentLength = [contentLengthNumber unsignedIntegerValue];
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
    
    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *resourceQuery = [userInfo objectForKey:HJResourceManagerParameterKeyResourceQuery];
    NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( [resourceKey isEqualToString:lookingResourceKey] == NO ) {
        return;
    }
    UIControlState state = (UIControlState)[[resourceQuery objectForKey:kControlStateKey] integerValue];
    HJResourceManagerRequestStatus status = (HJResourceManagerRequestStatus)[[userInfo objectForKey:HJResourceManagerParameterKeyRequestStatus] integerValue];
    
    id dataObject;
    
    switch( status ) {
        case HJResourceManagerRequestStatusDownloadStarted :
            objc_setAssociatedObject(self, &kAsyncDelivererIssuedId, [userInfo objectForKey:HJResourceManagerParameterKeyAsyncHttpDelivererIssuedId], OBJC_ASSOCIATION_RETAIN);
            break;
        case HJResourceManagerRequestStatusLoaded :
            objc_setAssociatedObject(self, &kResourceManagerObserving, @(0), OBJC_ASSOCIATION_RETAIN);
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HJResourceManagerNotification object:nil];
            dataObject = [userInfo objectForKey:HJResourceManagerParameterKeyDataObject];
            if( [dataObject isKindOfClass:[UIImage class]] == YES ) {
                if( [[resourceQuery objectForKey:kBackgroundImageKey] boolValue] == YES ) {
                    [self setBackgroundImage:(UIImage *)dataObject forState:state];
                } else {
                    [self setImage:(UIImage *)dataObject forState:state];
                }
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

- (BOOL)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state
{
    return [self setImageUrl:urlString placeholderImage:placeholderImage forState:state remakerName:nil remakerParameter:nil cipherName:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    [self setImageUrl:urlString placeholderImage:placeholderImage forState:state remakerName:nil remakerParameter:nil cipherName:nil completion:completion];
}

- (BOOL)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter
{
    return [self setImageUrl:urlString placeholderImage:placeholderImage forState:state remakerName:remakerName remakerParameter:remakerParameter cipherName:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter completion:(HJButtonCompletionBlock)completion
{
    [self setImageUrl:urlString placeholderImage:placeholderImage forState:(UIControlState)state remakerName:remakerName remakerParameter:remakerParameter cipherName:nil completion:completion];
}

- (BOOL)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName
{
    if( [urlString length] == 0 ) {
        return NO;
    }
    
    NSMutableDictionary *resourceQuery = [NSMutableDictionary new];
    if( resourceQuery == nil ) {
        return NO;
    }
    [resourceQuery setObject:urlString forKey:HJResourceQueryKeyRequestValue];
    if( [remakerName length] > 0 ) {
        [resourceQuery setObject:remakerName forKey:HJResourceQueryKeyRemakerName];
        if( remakerParameter != nil ) {
            [resourceQuery setObject:remakerParameter forKey:HJResourceQueryKeyRemakerParameter];
        }
    }
    if( [cipherName length] > 0 ) {
        [resourceQuery setObject:cipherName forKey:HJResourceQueryKeyCipherName];
    }
    [resourceQuery setObject:@(state) forKey:kControlStateKey];
    NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:[NSDictionary dictionaryWithDictionary:resourceQuery]];
    if( resourceKey == nil ) {
        [self setImage:nil forState:state];
        return NO;
    }
    objc_setAssociatedObject(self, &kResourceKey, resourceKey, OBJC_ASSOCIATION_RETAIN);
    if( placeholderImage != nil ) {
        [self setImage:placeholderImage forState:state];
    }
    
    if( [objc_getAssociatedObject(self, &kResourceManagerObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kResourceManagerObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceManagerReport:) name:HJResourceManagerNotification object:nil];
    }
    [[HJResourceManager defaultManager] resourceForQuery:resourceQuery completion:nil];
    
    return YES;
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName completion:(HJButtonCompletionBlock)completion
{
    if( [urlString length] == 0 ) {
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
    [resourceQuery setObject:urlString forKey:HJResourceQueryKeyRequestValue];
    if( [remakerName length] > 0 ) {
        [resourceQuery setObject:remakerName forKey:HJResourceQueryKeyRemakerName];
        if( remakerParameter != nil ) {
            [resourceQuery setObject:remakerParameter forKey:HJResourceQueryKeyRemakerParameter];
        }
    }
    if( [cipherName length] > 0 ) {
        [resourceQuery setObject:cipherName forKey:HJResourceQueryKeyCipherName];
    }
    [resourceQuery setObject:@(state) forKey:kControlStateKey];
    NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( resourceKey == nil ) {
        [self setImage:nil forState:state];
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
    }
    if( [objc_getAssociatedObject(self, &kResourceManagerObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kResourceManagerObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceManagerReport:) name:HJResourceManagerNotification object:nil];
    }
    [[HJResourceManager defaultManager] resourceForQuery:resourceQuery completion:^(NSDictionary *resultDict) {
        if( completion != nil ) {
            NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:[resultDict objectForKey:HJResourceManagerParameterKeyResourceQuery]];
            NSString *lookingResourceKey = objc_getAssociatedObject(self, &kResourceKey);
            BOOL stillLooking = [lookingResourceKey isEqualToString:resourceKey];
            id dataObject = [resultDict objectForKey:HJResourceManagerParameterKeyDataObject];
            UIImage *image = ([dataObject isKindOfClass:[UIImage class]] == YES) ? (UIImage *)dataObject : nil;
            completion(image, urlString, remakerName, remakerParameter, cipherName, !stillLooking);
        }
    }];
}

- (BOOL)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state
{
    return [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage forState:state remakerName:nil remakerParameter:nil cipherName:nil];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion
{
    [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage forState:state remakerName:nil remakerParameter:nil cipherName:nil completion:completion];
}

- (BOOL)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter
{
    return [self setImageUrl:urlString placeholderImage:placeholderImage forState:state remakerName:remakerName remakerParameter:remakerParameter cipherName:nil];
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter completion:(HJButtonCompletionBlock)completion
{
    [self setBackgroundImageUrl:urlString placeholderImage:placeholderImage forState:(UIControlState)state remakerName:remakerName remakerParameter:remakerParameter cipherName:nil completion:completion];
}

- (BOOL)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName
{
    if( [urlString length] == 0 ) {
        return NO;
    }
    
    NSMutableDictionary *resourceQuery = [NSMutableDictionary new];
    if( resourceQuery == nil ) {
        return NO;
    }
    [resourceQuery setObject:urlString forKey:HJResourceQueryKeyRequestValue];
    if( [remakerName length] > 0 ) {
        [resourceQuery setObject:remakerName forKey:HJResourceQueryKeyRemakerName];
        if( remakerParameter != nil ) {
            [resourceQuery setObject:remakerParameter forKey:HJResourceQueryKeyRemakerParameter];
        }
    }
    if( [cipherName length] > 0 ) {
        [resourceQuery setObject:cipherName forKey:HJResourceQueryKeyCipherName];
    }
    [resourceQuery setObject:@(state) forKey:kControlStateKey];
    [resourceQuery setObject:@(1) forKey:kBackgroundImageKey];
    NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:[NSDictionary dictionaryWithDictionary:resourceQuery]];
    if( resourceKey == nil ) {
        [self setBackgroundImage:nil forState:state];
        return NO;
    }
    objc_setAssociatedObject(self, &kResourceKey, resourceKey, OBJC_ASSOCIATION_RETAIN);
    if( placeholderImage != nil ) {
        [self setBackgroundImage:placeholderImage forState:state];
    }
    
    if( [objc_getAssociatedObject(self, &kResourceManagerObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kResourceManagerObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceManagerReport:) name:HJResourceManagerNotification object:nil];
    }
    [[HJResourceManager defaultManager] resourceForQuery:resourceQuery completion:nil];
    
    return YES;
}

- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName completion:(HJButtonCompletionBlock)completion
{
    if( [urlString length] == 0 ) {
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
    [resourceQuery setObject:urlString forKey:HJResourceQueryKeyRequestValue];
    if( [remakerName length] > 0 ) {
        [resourceQuery setObject:remakerName forKey:HJResourceQueryKeyRemakerName];
        if( remakerParameter != nil ) {
            [resourceQuery setObject:remakerParameter forKey:HJResourceQueryKeyRemakerParameter];
        }
    }
    if( [cipherName length] > 0 ) {
        [resourceQuery setObject:cipherName forKey:HJResourceQueryKeyCipherName];
    }
    [resourceQuery setObject:@(state) forKey:kControlStateKey];
    [resourceQuery setObject:@(1) forKey:kBackgroundImageKey];
    NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:resourceQuery];
    if( resourceKey == nil ) {
        [self setBackgroundImage:nil forState:state];
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
    }
    if( [objc_getAssociatedObject(self, &kResourceManagerObserving) boolValue] == NO ) {
        objc_setAssociatedObject(self, &kResourceManagerObserving, @(1), OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceManagerReport:) name:HJResourceManagerNotification object:nil];
    }
    [[HJResourceManager defaultManager] resourceForQuery:resourceQuery completion:^(NSDictionary *resultDict) {
        if( completion != nil ) {
            NSString *resourceKey = [[HJResourceManager defaultManager] resourceKeyStringFromResourceQuery:[resultDict objectForKey:HJResourceManagerParameterKeyResourceQuery]];
            NSString *lookingResourceKey = objc_getAssociatedObject(self, &kResourceKey);
            BOOL stillLooking = [lookingResourceKey isEqualToString:resourceKey];
            id dataObject = [resultDict objectForKey:HJResourceManagerParameterKeyDataObject];
            UIImage *image = ([dataObject isKindOfClass:[UIImage class]] == YES) ? (UIImage *)dataObject : nil;
            completion(image, urlString, remakerName, remakerParameter, cipherName, !stillLooking);
        }
    }];
}

- (NSUInteger)asyncDelivererIssuedId
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
