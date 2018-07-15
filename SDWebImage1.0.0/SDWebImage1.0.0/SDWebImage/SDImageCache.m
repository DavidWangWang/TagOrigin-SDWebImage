//
//  SDWebImageCache.m
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/12.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDImageCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface SDImageCache()

@property (strong,nonatomic) NSMutableDictionary *memoryCache;
@property (strong,nonatomic) NSMutableDictionary *imageDataCache;
@property (nonatomic, copy) NSString *diskCachePath;
@property (strong,nonatomic) NSOperationQueue *cacheInQueue;

@end

static SDImageCache *instance;
static NSInteger cacheMaxCacheAge = 60*60*24*7; // 1 week

@implementation SDImageCache

- (void)didReceiveMemoryWarning:(void *)object
{
    [self clearMemory];
}
// 清除1周上的沙盒内容
- (void)willTerminate
{
    [self cleanDisk];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.memoryCache = [NSMutableDictionary dictionary];
        self.imageDataCache = [NSMutableDictionary dictionary];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath attributes:nil];
        }
        // Init the operation queue
        self.cacheInQueue = [[NSOperationQueue alloc] init];
        self.cacheInQueue.maxConcurrentOperationCount = 2;

        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTerminate)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        UIDevice *device = [UIDevice currentDevice];
         if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
         {
             // When in background, clean memory in order to have less chance to be killed
             [[NSNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(clearMemory)
                                                          name:UIApplicationDidEnterBackgroundNotification
                                                        object:nil];
         }
    }
    return self;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (SDImageCache *)sharedImageCache
{
    if (instance == nil)
    {
        instance = [[SDImageCache alloc] init];
    }
    
    return instance;
}

- (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return [self.diskCachePath stringByAppendingPathComponent:filename];
}



- (void)storeKeyToDisk:(NSString *)key
{
    if (!key || key.length == 0) return;
    
    NSData *data = [self.imageDataCache objectForKey:key];
    NSString *path  = [self cachePathForKey:key];
    // can not user default manager in another thread
    NSFileManager *manager = [[NSFileManager alloc]init];
    if (data)
    {
         [manager createFileAtPath:path contents:data attributes:nil];
         @synchronized (self.imageDataCache)
         {
             [self.imageDataCache removeObjectForKey:key];
         }
    }
    else
    {
        UIImage *image = [self imageFromKey:key toDisk:YES];
        if (image != nil)
        {
            [manager createFileAtPath:path contents:UIImageJPEGRepresentation(image, (CGFloat)1.0) attributes:nil];
        }
    }
}


- (void)storeImage:(UIImage *)image forKey:(NSString *)key
{
    [self storeImage:image forKey:key toDisk:YES];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    [self storeImage:image data:nil forKey:key toDisk:toDisk];
}

- (void)storeImage:(UIImage *)image data:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (image == nil || key == nil)
    {
        return;
    }
    if (!data && toDisk)
    {
        return;
    }
    [self.memoryCache setObject:image forKey:key];
    if (toDisk)
    {
        [self.imageDataCache setObject:data forKey:key];
        [self.cacheInQueue addOperation:[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(storeKeyToDisk:) object:key]];
    }
}



- (UIImage *)imageFromKey:(NSString *)key
{
    return [self imageFromKey:key toDisk:YES];
}

- (UIImage *)imageFromKey:(NSString *)key toDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return nil;
    }
    UIImage *image = [self.memoryCache objectForKey:key];
    if (!image && fromDisk)
    {
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[self cachePathForKey:key]]];
        if (image != nil)
        {
            [self.memoryCache setObject:image forKey:key];
        }
    }
    return image;
}

- (void)removeImageForKey:(NSString *)key
{
    if (key == nil)
    {
        return ;
    }
    [self.memoryCache removeObjectForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
}

- (void)clearMemory
{
    [self.memoryCache removeAllObjects];
    [self.cacheInQueue cancelAllOperations];
}

- (void)clearDisk
{
    [self.cacheInQueue cancelAllOperations];
    [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath attributes:nil];
}
/// 超出日期的清空
- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager]enumeratorAtPath:_diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [_diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}


@end
