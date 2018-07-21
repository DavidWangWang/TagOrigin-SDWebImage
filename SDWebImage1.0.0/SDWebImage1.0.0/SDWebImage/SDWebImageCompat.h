//
//  SDWebImageCompat.h
//  SDWebImage1.0.0
//
//  Created by 王宁 on 2018/7/21.
//  Copyright © 2018年 @David. All rights reserved.
//

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#ifndef UIImage
#define UIImage NSImage
#endif
#ifndef UIImageView
#define UIImageView NSImageView
#endif
#else
#import <UIKit/UIKit.h>
#endif
