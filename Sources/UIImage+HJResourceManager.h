//
//  UIImage+HJResourceManager.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2013. 11. 5.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>

typedef void(^HJImageViewCompletionBlock)(UIImage *image, NSString *urlString, NSString *remakerName, id remakerParameter, NSString *cipherName, BOOL targetChanged);

@interface UIImageView (HJResourceManager)

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine completion:(HJImageViewCompletionBlock)completion;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter completion:(HJImageViewCompletionBlock)completion;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName completion:(HJImageViewCompletionBlock)completion;

@property (nonatomic, readonly) NSUInteger hjAsyncDelivererIssuedId;
@property (nonatomic, strong) id hjImageProgressView;

@end