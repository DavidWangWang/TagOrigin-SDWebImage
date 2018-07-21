//
//  UIButton+WebCache.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/21.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageCompat.h"
#import "SDWebImageManagerDelegate.h"

@interface UIButton (WebCache) <SDWebImageManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)cancelCurrentImageLoad;

@end
