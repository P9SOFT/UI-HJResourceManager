//
//  UIButton+HJResourceManager.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2016. 4. 8.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import <UIKit/UIKit.h>

typedef void(^HJButtonCompletionBlock)(UIImage * _Nullable image, NSString * _Nullable urlString, NSString * _Nullable remakerName, id _Nullable remakerParameter, NSString * _Nullable cipherName, BOOL targetChanged);

@interface UIButton (HJResourceManager)

- (void)setImageUrl:(NSString * _Nullable)urlString;
- (void)setImageUrl:(NSString * _Nullable)urlString forState:(UIControlState)state;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage forState:(UIControlState)state;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state completion:(HJButtonCompletionBlock _Nullable)completion;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString * _Nullable)remakerName remakerParameter:(id _Nullable)remakerParameter forState:(UIControlState)state completion:(HJButtonCompletionBlock _Nullable)completion;
- (void)setImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString * _Nullable)remakerName remakerParameter:(id _Nullable)remakerParameter cipherName:(NSString * _Nullable)cipherName forState:(UIControlState)state completion:(HJButtonCompletionBlock _Nullable)completion;

- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString;
- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine forState:(UIControlState)state completion:(HJButtonCompletionBlock _Nullable)completion;
- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString * _Nullable)remakerName remakerParameter:(id _Nullable)remakerParameter forState:(UIControlState)state completion:(HJButtonCompletionBlock _Nullable)completion;
- (void)setBackgroundImageUrl:(NSString * _Nullable)urlString placeholderImage:(UIImage * _Nullable)placeholderImage cutInLine:(BOOL)cutInLine remakerName:(NSString * _Nullable)remakerName remakerParameter:(id _Nullable)remakerParameter cipherName:(NSString * _Nullable)cipherName forState:(UIControlState)state completion:(HJButtonCompletionBlock _Nullable)completion;

- (void)cancel;

@property (nonatomic, readonly) NSUInteger hjAsyncDelivererIssuedId;
@property (nonatomic, strong) id _Nullable hjButtonProgressView;

@end
