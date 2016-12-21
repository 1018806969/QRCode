//
//  CodeHelper.h
//  QRCode
//
//  Created by txx on 16/12/21.
//  Copyright © 2016年 txx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CodeHelper : NSObject
/**
 识别二维码
 */
-(NSString *)recognizeCodeImage:(UIImage *)image;


/**
 生成二维码图像
 */
-(UIImage *)productImageWithCode:(NSString *)str length:(CGFloat)length logoImage:(UIImage *)logoImage;

@end
