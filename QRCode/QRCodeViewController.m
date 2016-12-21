//
//  QRCodeViewController.m
//  QRCode
//
//  Created by txx on 16/12/20.
//  Copyright © 2016年 txx. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,CAAnimationDelegate>

@property(nonatomic,strong)AVCaptureSession *captureSession;

@property(nonatomic,strong)AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic,copy)TScanSuccessedHandle handle;

/**
 扫描框边长
 */
@property(nonatomic,assign)CGFloat interestLength;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startScanSetting];
    [self createUI];

}
-(void)scanSuccessed:(TScanSuccessedHandle)handle
{
    _handle = [handle copy];
}
-(void)scanSuccess:(NSString *)result
{
    //shock
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if (_handle) {
        _handle(result);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //没有扫出数据
    if ([metadataObjects count] <= 0) {
        return;
    }
    //停止扫描
    [_captureSession stopRunning];
    _captureSession = nil ;
    
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
    NSString *resultStr = [metadataObj stringValue];
    //如果是放在主队列就不需要回到主线程
//    [self performSelectorOnMainThread:@selector(scanSuccess:) withObject:resultStr waitUntilDone:NO];
    [self scanSuccess:resultStr];
}

#pragma mark - **************** private method ****************

-(void)startScanSetting
{
    NSError *error = nil ;
    
    //1.初始化捕捉设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.根据捕捉的设备创建输入流
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!captureDeviceInput) {
        NSLog(@"%@",[error localizedDescription]);
        return ;
    }
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc]init];
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    //4.1.将输入流添加到会话
    [_captureSession addInput:captureDeviceInput];
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:metadataOutput];
    //5.创建串行队列，并加媒体输出流添加到队列当中,也可以直接使用主队列
//    dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //5.2.设置输出媒体数据类型为QRCode
    NSArray * types = [[NSArray alloc]initWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode,nil];
    [metadataOutput setMetadataObjectTypes:types];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:self.view.bounds];
    //9.将图层添加到预览view的图层上
    [self.view.layer addSublayer:_videoPreviewLayer];
    //10.设置扫描范围
    metadataOutput.rectOfInterest = [self rectOfInterest];

    [_captureSession startRunning];

}
/**
 *  设置扫描的有效区域
 *  这里需要注意 , rectOfInterest的 x, y, width, height的范围都是 0---1
 *  默认为(0,0,1,1) 代表 x和y都为0, 宽高都为previewLayer的宽高
 *  如果设置为 (0.5,0.5,0.5,0.5) 则表示居中显示, 宽高均为previewLayer的一半
 *  所以设置的时候, 需要和相应的 宽高求比例
 *  另外注意的是, 可以理解为系统处理图片的时候都是横着的, 当iPhone的屏幕确是竖着的
 *  时候应该 x = y/height;  y = x/height ...
 */
-(CGRect)rectOfInterest
{
    CGRect rect = CGRectZero ;
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    NSLog(@"---%f--%f",width,height);
    if (self.view.bounds.size.width < self.view.bounds.size.height) {//竖屏
        //扫描区的长度
        _interestLength = self.view.bounds.size.width * 2/3;
        CGFloat x = (height - _interestLength)/2/height;
        CGFloat y = (width - _interestLength)/2/width;
        rect = CGRectMake(x, y, _interestLength/height, _interestLength/width);
    }else
    {
        _interestLength = self.view.bounds.size.height * 2/3;
        CGFloat x = (width -_interestLength)/2/width;
        CGFloat y = (height - _interestLength)/2/height;
        rect = CGRectMake(x, y, _interestLength/width, _interestLength/height);
    }
    return rect ;
}
-(void)createUI
{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    UIColor *color = [[UIColor blackColor]colorWithAlphaComponent:.5];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width,(height-_interestLength)/2)];
    topView.backgroundColor = color;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake((width-_interestLength)/2+_interestLength, (height-_interestLength)/2, (width-_interestLength)/2, _interestLength)];
    rightView.backgroundColor = color;
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, (height-_interestLength)/2, (width-_interestLength)/2, _interestLength)];
    leftView.backgroundColor = color;
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, (height-_interestLength)/2+_interestLength, width, (height-_interestLength)/2)];
    downView.backgroundColor = color;
    [self.view addSubview:topView];
    [self.view addSubview:rightView];
    [self.view addSubview:downView];
    [self.view addSubview:leftView];
    
    UIImageView *bgImgView = [[UIImageView alloc]initWithFrame:CGRectMake((width-_interestLength)/2, (height-_interestLength)/2, _interestLength, _interestLength)];
    bgImgView.image = [UIImage imageNamed:@"bgImg"];
    [self.view addSubview:bgImgView];
    
    UIImageView *lineImgView = [[UIImageView alloc]initWithFrame:CGRectMake((width-_interestLength)/2, (height-_interestLength)/2, _interestLength, 10)];
    lineImgView.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:lineImgView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.toValue = [NSNumber numberWithFloat:(height-_interestLength)/2+_interestLength];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.autoreverses = YES;
    animation.repeatCount = MAXFLOAT;
    animation.duration = 2;
    animation.delegate = self ;
    [lineImgView.layer addAnimation:animation forKey:@"linemove"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
