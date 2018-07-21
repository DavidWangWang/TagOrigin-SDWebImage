//
//  SDImageCacheDelegate.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/15.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageCompat.h"

@class SDImageCache;

@protocol SDImageCacheDelegate <NSObject>

@optional
- (void)imageCache:(SDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info;
- (void)imageCache:(SDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info;

@end
