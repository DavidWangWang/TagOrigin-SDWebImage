//
//  SDWebImageManager.m
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
@interface SDWebImageManager()<SDImageCacheDelegate>

@property (strong,nonatomic) NSMutableArray *downloadDelegates;
@property (strong,nonatomic) NSMutableArray *cacheDelegates;
@property (strong,nonatomic)  NSMutableArray *downloaders;
@property (strong,nonatomic) NSMutableDictionary *downloaderForURL;
@property (strong,nonatomic) NSMutableArray *failedURLs;

@end

static SDWebImageManager *instance;

@implementation SDWebImageManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _downloadDelegates = [[NSMutableArray alloc] init];
        _cacheDelegates = [[NSMutableArray alloc] init];
        _downloaders = [[NSMutableArray alloc] init];
        _downloaderForURL = [[NSMutableDictionary alloc] init];
        _failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}


+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[SDWebImageManager alloc] init];
    }
    
    return instance;
}

- (UIImage *)imageWithURL:(NSURL *)url
{
    return [[SDImageCache sharedImageCache] imageFromKey:url.absoluteString];
}

- (void)downLoadImageWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate
{
    // 1.对传入的数据进行防御 2.根据URL去获取download 3.如果不存在则创建并写入字典 4.delegate数组添加。downLoad数组添加
    [self downloadWithURL:url delegate:delegate retryFailed:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed
{
    [self downloadWithURL:url delegate:delegate retryFailed:retryFailed lowPriority:NO];
   
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority
{
    if (!url || !delegate || (!retryFailed  && [self.failedURLs containsObject:url]))
    {
        return;
    }
    if ([url isKindOfClass:[NSString class]])
    {
        url = [NSURL URLWithString:(NSString *)url];
    }
    [self.cacheDelegates addObject:delegate];
    NSMutableDictionary *arguments = @{}.mutableCopy;
    arguments[@"delegate"] = delegate;
    arguments[@"key"] = url.absoluteString;
    arguments[@"lowPriority"] = @(lowPriority);
    [[SDImageCache sharedImageCache] quaryDiskForKey:url.absoluteString delegate:self userInfo:arguments];
}


- (void)cancelForDelegate:(id<SDWebImageManagerDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    [self.cacheDelegates removeObjectIdenticalTo:delegate];
    //1.根据delegate找到idx 2.根据id找到downLoader 3.在delegate数组移除，downloader数组移除 3.执行cancale 4.字典移除
    NSInteger idx = [self.downloadDelegates indexOfObjectIdenticalTo:delegate];
    if (idx == NSNotFound || idx < 0 || idx >= self.downloaders.count)
    {
        return;
    }
    SDWebImageDownloader *downLoader = self.downloaders[idx];
    [self.downloadDelegates removeObjectAtIndex:idx];
    [self.downloaders removeObjectAtIndex:idx];
    if (![self.downloaders containsObject:downLoader])
    {
        [downLoader cancel];
        [self.downloaderForURL removeObjectForKey:downLoader.url];
    }
}

#pragma mark SDImageCacheDelegate

- (void)imageCache:(SDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info
{
    id<SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
    NSUInteger idx = [self.cacheDelegates indexOfObjectIdenticalTo:delegate];
    if (idx == NSNotFound)
    {
        return;
    }
    if ([delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
    {
        [delegate webImageManager:self didFinishWithImage:info[@"image"]];
    }
    [self.cacheDelegates removeObjectAtIndex:idx];
}

- (void)imageCache:(SDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info
{
    NSURL *url = [info objectForKey:@"url"];
    id <SDWebImageManagerDelegate> delegate = info[@"delegate"];
    BOOL lowPriority = info[@"lowPriority"];
    NSUInteger idx = [self.cacheDelegates indexOfObjectIdenticalTo:delegate];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }
    [self.cacheDelegates removeObjectAtIndex:idx];

    SDWebImageDownloader *downLoader = [self.downloaderForURL valueForKey:key];
    if (!downLoader)
    {
        downLoader = [SDWebImageDownloader downloaderWithURL:url delegate:self userInfo:nil lowPriority:lowPriority];
        self.downloaderForURL[url] = downLoader;
    }
    if (!lowPriority && downLoader.lowPriority)
    {
        downLoader.lowPriority = NO;
    }
    
    [self.downloadDelegates addObject:delegate];
    [self.downloaders addObject:downLoader];
}


- (void)imageDownLoader:(SDWebImageDownloader *)downLoader didFinishWithImage:(UIImage *)image
{
   
    for (NSInteger i=_downloaders.count - 1; i >= 0; i--)
    {
        NSUInteger uidx = (NSUInteger)i;
        SDWebImageDownloader *innerDownLoader = _downloaders[uidx];
        if (innerDownLoader == downLoader)
        {
            id <SDWebImageManagerDelegate> delegate = self.downloadDelegates[uidx];
            if (delegate && [delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
            {
                [delegate webImageManager:self didFinishWithImage:image];
            }
            else
            {
                if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:)])
                {
                    [delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:nil];
                }
            }
            [self.downloadDelegates removeObject:delegate];
            [self.downloaders removeObject:innerDownLoader];
            
        }
    }

    if (image)
    {
        // 传递过去的是data,data直接从downLoader拿过来的,相比之前优化的地方是节省image转data的开销了。
        [[SDImageCache sharedImageCache] storeImage:image data:downLoader.imageData forKey:downLoader.url.absoluteString toDisk:YES];
    }
    else
    {
        [self.failedURLs addObject:downLoader.url];
    }
    [self.downloaderForURL removeObjectForKey:downLoader.url];
}

// 下载失败在delegate移除。downLoader中移除。 Dictionary中移除;failedURLs中添加
- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
{
    
    for (NSInteger i=_downloaders.count - 1; i >= 0; i--)
    {
        NSUInteger uidx = (NSUInteger)i;
        SDWebImageDownloader *innerDownLoader = _downloaders[uidx];
        if (innerDownLoader == downloader)
        {
            id <SDWebImageManagerDelegate> delegate = self.downloadDelegates[uidx];
            
            if ([delegate respondsToSelector:@selector(webImageManager:didFailWithError:)])
            {
                [delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:nil];
            }
            [self.downloadDelegates removeObject:delegate];
            [self.downloaders removeObject:innerDownLoader];
            
        }
    }
    [self.downloaderForURL removeObjectForKey:downloader.url];
    [self.failedURLs addObject:downloader.url];
}



@end
