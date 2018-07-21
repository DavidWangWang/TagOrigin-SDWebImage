//
//  SDWebImageDownloader.m
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageDownloader.h"

NSString *const SDWebImageDownloadStartNotification = @"SDWebImageDownloadStartNotification";
NSString *const SDWebImageDownloadStopNotification = @"SDWebImageDownloadStopNotification";

@implementation SDWebImageDownloader

+ (instancetype)downLoadWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate
{
    return  [self downloaderWithURL:url delegate:delegate userInfo:nil lowPriority:NO];
}

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo
{
    return  [self downloaderWithURL:url delegate:delegate userInfo:userInfo lowPriority:NO];
}

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo lowPriority:(BOOL)lowPriority
{
    if (NSClassFromString(@"SDNetworkActivityIndicator"))
    {
        id activityIndicator = [(NSClassFromString(@"SDNetworkActivityIndicator")) performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator selector:NSSelectorFromString(@"startActivity") name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebImageDownloadStopNotification object:nil];
    }
    SDWebImageDownloader *downLoader = [[SDWebImageDownloader alloc]init];
    downLoader.url = url;
    downLoader.delegate = delegate;
    downLoader.userInfo = userInfo;
    downLoader.lowPriority = lowPriority;
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
    if (!self.lowPriority)
    {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    [self.connection start];
    // 创建connection成功和失败的情况
    if (self.connection)
    {
        self.imageData = [NSMutableData data];
         [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:nil];
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
    if (self.connection)
    {
        [self.connection cancel];
        self.connection = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:nil];
    }
}

#pragma mark <#a#>

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:nil];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:nil];
    
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
