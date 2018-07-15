//
//  SDWebImageCache.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/12.
//  Copyright © 2018年 @David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageCacheDelegate.h"
@interface SDImageCache : NSObject

+ (SDImageCache *)sharedImageCache;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;
- (void)storeImage:(UIImage *)image data:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk;

- (UIImage *)imageFromKey:(NSString *)key;
- (UIImage *)imageFromKey:(NSString *)key toDisk:(BOOL)toDisk;
- (void)quaryDiskForKey:(NSString *)key delegate:(id<SDImageCacheDelegate>)delegate userInfo:(NSDictionary *)userInfo;

- (void)removeImageForKey:(NSString *)key;
- (void)clearMemory;
- (void)clearDisk;
- (void)cleanDisk;
@end
