//
//  SDWebImageManagerDelegate.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageCompat.h"

@class SDWebImageManager;

@protocol SDWebImageManagerDelegate <NSObject>

@optional

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error;
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image;

@end

