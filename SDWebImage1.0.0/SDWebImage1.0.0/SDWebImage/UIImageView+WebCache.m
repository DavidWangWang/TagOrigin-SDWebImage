//
//  UIImageView+WebCache.m
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    // 1.取消当前URL的下载  2.在manager的缓存中去取. 有直接返回 3.没有则设置placeHodler走下载
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelForDelegate:self];
    UIImage *image = [manager imageWithURL:url];
    if (image)
    {
        self.image = image;
    }
    else
    {
        if (placeholder)
        {
            self.image = placeholder;
        }
        [manager downLoadImageWithURL:url delegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    self.image = image;
}



@end
