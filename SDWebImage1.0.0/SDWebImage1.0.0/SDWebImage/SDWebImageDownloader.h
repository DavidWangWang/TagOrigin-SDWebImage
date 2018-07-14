//
//  SDWebImageDownloader.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloaderDelegate.h"

@interface SDWebImageDownloader : NSOperation

@property (strong,nonatomic) NSURL *url;
@property(nonatomic,weak) id<SDWebImageDownloaderDelegate> delegate;

+ (instancetype)downLoadWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate;
+ (void)setMaxConcurrentDownLoads:(NSUInteger)max;

@end
