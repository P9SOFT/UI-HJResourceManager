//
//  UIImageView+HJResourceManager.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2013. 11. 5.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>

typedef void(^HJImageViewCompletionBlock)(UIImage * _Nullable image, NSString * _Nullable urlString, NSString * _Nullable remakerName, id  _Nullable remakerParameter, NSString * _Nullable cipherName, BOOL targetChanged);

@interface UIImageView (HJResourceManager)

- (void)setImageUrl:(NSString * _Nullable)urlString;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine completion:(HJImageViewCompletionBlock _Nullable)completion;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString * _Nullable)remakerName remakerParameter:(id _Nullable)remakerParameter completion:(HJImageViewCompletionBlock _Nullable)completion;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString * _Nullable)remakerName remakerParameter:(id _Nullable)remakerParameter cipherName:(NSString * _Nullable)cipherName completion:(HJImageViewCompletionBlock _Nullable)completion;
- (void)cancel;

@property (nonatomic, readonly) NSUInteger hjAsyncDelivererIssuedId;
@property (nonatomic, strong) id _Nullable hjImageProgressView;

@end
