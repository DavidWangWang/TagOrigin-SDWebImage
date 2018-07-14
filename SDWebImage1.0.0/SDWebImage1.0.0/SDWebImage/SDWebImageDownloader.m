//
//  SDWebImageDownloader.m
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageDownloader.h"

static NSOperationQueue *downloadQueue;

@implementation SDWebImageDownloader

+ (instancetype)downLoadWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate
{
    SDWebImageDownloader *downLoader = [[SDWebImageDownloader alloc]init];
    downLoader.url = url;
    downLoader.delegate = delegate;
    if (downloadQueue == nil)
    {
        downloadQueue = [[NSOperationQueue alloc]init];
        [downloadQueue setMaxConcurrentOperationCount:8];
    }
    [downloadQueue addOperation:downLoader];
    return downLoader;
}

+ (void)setMaxConcurrentDownLoads:(NSUInteger)max
{
    if (downloadQueue == nil)
    {
        downloadQueue = [[NSOperationQueue alloc]init];
    }
    [downloadQueue setMaxConcurrentOperationCount:max];
}

- (void)main
{
    NSData *data = [NSData dataWithContentsOfURL:self.url];
    UIImage *image = [UIImage imageWithData:data];
    if (!self.isCancelled && [self.delegate respondsToSelector:@selector(imageDownLoader:didFinishWithImage:)]){
        [self.delegate imageDownLoader:self didFinishWithImage:image];
    }
}

@end
