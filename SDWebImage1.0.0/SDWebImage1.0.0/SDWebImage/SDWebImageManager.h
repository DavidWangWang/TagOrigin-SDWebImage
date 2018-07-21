//
//  SDWebImageManager.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageCompat.h"
#import "SDWebImageDownloaderDelegate.h"
#import "SDWebImageManagerDelegate.h"

@interface SDWebImageManager : NSObject <SDWebImageDownloaderDelegate>

+ (id)sharedManager;
- (UIImage *)imageWithURL:(NSURL *)url;
- (void)downLoadImageWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority;
- (void)cancelForDelegate:(id<SDWebImageManagerDelegate>)delegate;
@end
