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

- (BOOL)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;
- (BOOL)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter completion:(HJButtonCompletionBlock)completion;
- (BOOL)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName;
- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName completion:(HJButtonCompletionBlock)completion;

- (BOOL)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state completion:(HJButtonCompletionBlock)completion;
- (BOOL)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter completion:(HJButtonCompletionBlock)completion;
- (BOOL)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName;
- (void)setBackgroundImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state remakerName:(NSString *)remakerName remakerParameter:(id)remakerParameter cipherName:(NSString *)cipherName completion:(HJButtonCompletionBlock)completion;

@property (nonatomic, readonly) NSUInteger asyncDelivererIssuedId;
@property (nonatomic, strong) id hjButtonProgressView;

@end