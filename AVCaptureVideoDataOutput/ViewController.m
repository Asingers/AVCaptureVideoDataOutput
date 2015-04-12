//
//  ViewController.m
//  AVCaptureVideoDataOutput
//
//  Created by yoheimiyamoto on 4/12/15.
//  Copyright (c) 2015 mycompany. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    AVCaptureSession* session;
    AVCaptureVideoDataOutput * videoDataOutput;
    UIImageView * previewImage;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self AVCaptureSetup];
    
}


// AVCaputureSetup
- (void)AVCaptureSetup
{
    // セッション作成
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;  // セッション画質設定
    
    // デバイス取得
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 入力作成
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    [session addInput:deviceInput];  // セッションに追加
    
    // 出力作成
    videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:videoDataOutput];
    
    // ビデオ出力のキャプチャの画像情報のキューを設定
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:TRUE];
    [videoDataOutput setSampleBufferDelegate:self queue:queue];
    
    // ビデオへの出力の画像は、BGRAで出力
    videoDataOutput.videoSettings = @{
                                           (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                           };
    
    // ビデオ入力のAVCaptureConnectionを取得
    AVCaptureConnection *videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 1秒あたり4回画像をキャプチャ
    videoConnection.videoMinFrameDuration = CMTimeMake(1, 30);
    

    // プレビュー設定
    previewImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:previewImage];
    
    // セッション開始
    [session startRunning];
}



// デリゲートメソッド
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // キャプチャしたフレームからCGImageを作成
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    // 画像を画面に表示
    dispatch_async(dispatch_get_main_queue(), ^{
        previewImage.image = image;
    });
}


// サンプルバッファのデータからCGImageRefを生成する
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // ピクセルバッファのベースアドレスをロックする
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get information of the image
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // RGBの色空間
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width,
                                                    height,
                                                    8,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(cgImage);
    
    return image;
}



// 撮影ボタンメソッド
- (IBAction)takeButton:(UIButton *)sender
{
    
    // アルバムに画像を保存
    UIImageWriteToSavedPhotosAlbum(previewImage.image, self, nil, nil);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
