//
//  SDWebImageDownloader.m
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageDownloader.h"


@implementation SDWebImageDownloader

+ (instancetype)downLoadWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate
{
    SDWebImageDownloader *downLoader = [[SDWebImageDownloader alloc]init];
    downLoader.url = url;
    downLoader.delegate = delegate;
    [downLoader start];
    return downLoader;
}

+ (void)setMaxConcurrentDownLoads:(NSUInteger)max
{

}

- (void)start
{
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
    // 创建connection成功和失败的情况
    if (self.connection)
    {
        self.imageData = [NSMutableData data];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
        {
            [self.delegate imageDownloader:self didFailWithError:nil];
        }
    }
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
}

#pragma mark <#a#>

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)])
    {
        [self.delegate imageDownloader:self didFailWithError:error];
    }
    self.connection = nil;
    self.imageData = nil;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    // finish 置空,防止重复下载。
    self.connection = nil;
    
    if ([self.delegate respondsToSelector:@selector(imageDownloaderDidFinish:)])
    {
        [self.delegate imageDownloaderDidFinish:self];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(imageDownLoader:didFinishWithImage:)])
    {
        UIImage *image = [UIImage imageWithData:self.imageData];
        [self.delegate imageDownLoader:self didFinishWithImage:image];
    }
    self.imageData = nil;
}



@end
