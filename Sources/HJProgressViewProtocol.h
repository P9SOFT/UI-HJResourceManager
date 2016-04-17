//
//  HJProgressViewProtocol.h
//	Hydra Jelly Box
//
//  Created by Tae Hyun Na on 2016. 4. 17.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#ifndef HJProgressViewProtocol_h
#define HJProgressViewProtocol_h

@protocol HJProgressViewProtocol

@optional
- (void)hjProgressViewConnected:(id)senderView contentLength:(NSUInteger)contentLength;
- (void)hjProgressViewTransfering:(id)senderView transferLength:(NSUInteger)transferLength contentLength:(NSUInteger)contentLength;
- (void)hjProgressViewTransferDone:(id)senderView;
- (void)hjProgressViewTransferFailed:(id)senderView;
- (void)hjProgressViewTransferCanceled:(id)senderView;

@end

#endif /* HJProgressViewProtocol_h */
