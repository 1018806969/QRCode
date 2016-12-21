//
//  ViewController.m
//  QRCode
//
//  Created by txx on 16/12/20.
//  Copyright © 2016年 txx. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import "CodeHelper.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)scanCode:(UIButton *)sender {
    QRCodeViewController *qrCodeVc = [[QRCodeViewController alloc]init];
    [qrCodeVc scanSuccessed:^(NSString *result) {
        NSLog(@"结果是：%@",result);
    }];
    [self.navigationController pushViewController:qrCodeVc animated:YES];
}
- (IBAction)recognizeCode:(UIButton *)sender {
    CodeHelper *helper = [[CodeHelper alloc]init];
    
    UIImage *image = [UIImage imageNamed:@"code"];
    NSString *result = [helper recognizeCodeImage:image];
    NSLog(@"识别出的结果是：%@",result);
}

- (IBAction)productCode:(UIButton *)sender {
    CodeHelper *helper = [[CodeHelper alloc]init];

   _imageView.image = [helper productImageWithCode:@"tangxuanxuan" length:100 logoImage:nil];
}
- (IBAction)productCodeWithHeadImg:(UIButton *)sender {
    CodeHelper *helper = [[CodeHelper alloc]init];

    _imageView.image = [helper productImageWithCode:@"tangxuanxuan" length:100 logoImage:[UIImage imageNamed:@"head"]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
