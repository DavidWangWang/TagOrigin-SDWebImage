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
@interface SDWebImageManager()

@property (strong,nonatomic) NSMutableArray *delegates;
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
        _delegates = [[NSMutableArray alloc] init];
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
    if (!url || [self.failedURLs containsObject:url])
    {
        return;
    }
    SDWebImageDownloader *downLoader = [self.downloaderForURL valueForKey:url.absoluteString];
    if (!downLoader)
    {
        downLoader = [SDWebImageDownloader downLoadWithURL:url delegate:self];
        self.downloaderForURL[url] = downLoader;
    }
    [self.delegates addObject:delegate];
    [self.downloaders addObject:downLoader];
}

- (void)cancelForDelegate:(id<SDWebImageManagerDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    //1.根据delegate找到idx 2.根据id找到downLoader 3.在delegate数组移除，downloader数组移除 3.执行cancale 4.字典移除
    NSInteger idx = [self.delegates indexOfObjectIdenticalTo:delegate];
    if (idx == NSNotFound || idx < 0 || idx >= self.downloaders.count)
    {
        return;
    }
    SDWebImageDownloader *downLoader = self.downloaders[idx];
    [self.delegates removeObjectAtIndex:idx];
    [self.downloaders removeObjectAtIndex:idx];
    if (![self.downloaders containsObject:downLoader])
    {
        [downLoader cancel];
        [self.downloaderForURL removeObjectForKey:downLoader.url];
    }
}

- (void)imageDownLoader:(SDWebImageDownloader *)downLoader didFinishWithImage:(UIImage *)image
{
   
    for (NSInteger i=_downloaders.count - 1; i >= 0; i--)
    {
        SDWebImageDownloader *innerDownLoader = _downloaders[i];
        if (innerDownLoader == downLoader)
        {
            id <SDWebImageManagerDelegate> delegate = self.delegates[i];
            if (delegate && [delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:)])
            {
                [delegate webImageManager:self didFinishWithImage:image];
            }
            [self.delegates removeObject:delegate];
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





@end
