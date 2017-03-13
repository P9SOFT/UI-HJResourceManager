//
//  UIButton+HJResourceManager.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2016. 4. 8.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>

typedef void(^HJButtonCompletionBlock)(UIImage *image, NSString *urlString, NSString *remakerName, id remakerParameter, NSString *cipherName, BOOL targetChanged);

@interface UIButton (HJResourceManager)

- (void)setImageUrl:(NSString *)urlString;
- (void)setImageUrl:(NSString *)urlString forState:(UIControlState)state;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;

- (void)setBackgroundImageUrl:(NSString *)urlString;
- (void)setBackgroundImageUrl:(NSString *)urlString forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;

- (void)cancel;

@property (nonatomic, readonly) NSUInteger hjAsyncDelivererIssuedId;
@property (nonatomic, strong) id hjButtonProgressView;

@end
