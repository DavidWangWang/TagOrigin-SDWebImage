//
//  SDWebImageDownloader.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/11.
//  Copyright © 2018年 @David. All rights reserved.
//

#import "SDWebImageCompat.h"
#import "SDWebImageDownloaderDelegate.h"

extern NSString *const SDWebImageDownloadStartNotification;
extern NSString *const SDWebImageDownloadStopNotification;

@interface SDWebImageDownloader : NSObject

@property (strong,nonatomic) NSURL *url;
@property (nonatomic,weak) id<SDWebImageDownloaderDelegate> delegate;
@property (strong,nonatomic) NSURLConnection *connection;
@property (strong,nonatomic) NSMutableData *imageData;
@property (strong,nonatomic) id userInfo;
@property(assign,nonatomic) BOOL lowPriority;

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo lowPriority:(BOOL)lowPriority;
+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo;
+ (instancetype)downLoadWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate;

- (void)start;
- (void)cancel;

+ (void)setMaxConcurrentDownLoads:(NSUInteger)max __attribute__((deprecated));

@end
