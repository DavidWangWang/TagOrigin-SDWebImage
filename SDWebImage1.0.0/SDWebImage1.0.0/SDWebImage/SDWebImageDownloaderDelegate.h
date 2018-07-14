//
//  SDWebImageDownloaderDelegate.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//
#import <UIKit/UIKit.h>

@class SDWebImageDownloader;

@protocol SDWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownLoader:(SDWebImageDownloader *)downLoader didFinishWithImage:(UIImage *)image;

@end

