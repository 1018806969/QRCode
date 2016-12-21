//
//  CodeHelper.m
//  QRCode
//
//  Created by txx on 16/12/21.
//  Copyright © 2016年 txx. All rights reserved.
//

#import "CodeHelper.h"

@implementation CodeHelper

/**
 识别二维码
 */
-(NSString *)recognizeCodeImage:(UIImage *)image
{
    /* 这两种方式用来生成CIImage不是很好, 因为当传进来的image是基于CIImage的就会返回为nil
     * 同样的 可能返回的CGImage也为nil
     CIImage *ciImage = image.CIImage;
     CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
     */
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *cIImage = [CIImage imageWithData:imageData];
    if (!cIImage) return nil;
    // Apple提供的强大的识别功能, 可以支持多种类型的识别, 比如人脸识别
    CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}]
                                                options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    // CIFeature 返回的数组按照识别出的可信任度排序, 所以使用第一个是最精准的
    NSArray *resultArr = [qrDetector featuresInImage:cIImage];
    // 没有识别到
    if (resultArr.count == 0) return nil;
    // 第一个是最精准的
    CIQRCodeFeature *feature = resultArr[0];
    return feature.messageString;
    
}












/**
 生成二维码图像
 */
-(UIImage *)productImageWithCode:(NSString *)str length:(CGFloat)length logoImage:(UIImage *)logoImage
{
    
    //滤镜  On iOS, all input values will be set to default values. */
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    //设置输入数据
    [filter setValue:data forKey:@"inputMessage"];
    //设置错误输入等级，等级越高越容易识别，值可设置为L(Low) |  M(Medium) | Q | H(High)
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    
    //获得滤镜输出图像
    CIImage *outputImage = [filter outputImage];
    
    //直接缩放获得的图片很模糊
    //    UIImage *image = [UIImage imageWithCIImage:outputImage scale:2.0f orientation:UIImageOrientationUp];
    
    UIImage *image = [self scaleImage:outputImage Length:length];
    
    image = [self codeImage:image addBgColor:[UIColor purpleColor] fontColor:[UIColor grayColor] logoImage:logoImage];
    
    return image;
}
/**
 绘制要求大小的高清二维码图像
 */
- (UIImage *)scaleImage:(CIImage *)ciImage Length:(CGFloat)Length {
    // 开启图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(Length, Length), NO, 0.0f);
    UIImage *temp = [UIImage imageWithCIImage:ciImage];
    CGSize originalSize = temp.size;
    CGFloat scale = MIN(Length/originalSize.width, Length/originalSize.height);
    // 按比例计算缩放后的宽高
    size_t scaledWidth = originalSize.width * scale;
    size_t scaledHeight = originalSize.height * scale;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // 清晰
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    // 绘制缩放后的图片
    [temp drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
    // 取得缩放后的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束绘制
    UIGraphicsEndImageContext();
    return image;
}
/**
 设置二维码的颜色
 */
-(UIImage *)codeImage:(UIImage *)image addBgColor:(UIColor *)bgColor fontColor:(UIColor *)fontColor logoImage:(UIImage *)logoImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:                        @"inputImage",[CIImage imageWithCGImage:image.CGImage],               @"inputColor0",[CIColor colorWithCGColor:fontColor.CGColor],
                        @"inputColor1",[CIColor colorWithCGColor:bgColor.CGColor], nil];
    
    //缩放为原来的尺寸
    UIImage *image1 = [self scaleImage:filter.outputImage Length:image.size.width];
    if (logoImage) {
        image1 = [self composeQRCodeImage:image1 withImage:logoImage withImageSideLength:image.size.width/4];
    }
    return image1;
    
}
/**
 在二维码中心添加logo
 */
- (UIImage *)composeQRCodeImage:(UIImage *)codeImage withImage:(UIImage *)image withImageSideLength:(CGFloat)sideLength {
    
    UIGraphicsBeginImageContextWithOptions(codeImage.size, NO, 0.0f);
    
    CGFloat codeImageWidth = codeImage.size.width;
    CGFloat codeImageHeight = codeImage.size.height;
    // 绘制原来的codeImage
    [codeImage drawInRect:CGRectMake(0, 0, codeImageWidth, codeImageHeight)];
    // 绘制image到codeImage中心
    [image drawInRect:CGRectMake((codeImageWidth-sideLength)/2, (codeImageHeight-sideLength)/2,
                                 sideLength, sideLength)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}



@end
