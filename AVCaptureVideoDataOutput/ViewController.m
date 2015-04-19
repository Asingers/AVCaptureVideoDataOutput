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
    UIImage * image;
    UIImageView * imageView;
    NSMutableArray * images;
    NSTimer * timer;
    int count;
    BOOL buttonStatus;
    BOOL takephotoOrientation;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // カメラセットアップ
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
    
    // セッション開始
    [session startRunning];
    
    // 変数初期化
    images = [NSMutableArray array]; //NSMutableArray初期化
    buttonStatus = NO;
    
    // プレビュー画面生成
    imageView = [[UIImageView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    
    // プレビューを画面に貼り付け
    [self.view addSubview:imageView];
    
    // 背面に移動
    [self.view sendSubviewToBack:imageView];
}


// デリゲートメソッド
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // キャプチャしたフレームからCGImageを作成
    image = [self imageFromSampleBuffer:sampleBuffer];
    
    // 画像を画面に表示
    dispatch_async(dispatch_get_main_queue(), ^
    {
        imageView.image = image;
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
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(cgImage);
    
    return uiImage;
}



// 撮影ボタンメソッド
- (IBAction)takeButton:(UIButton *)sender
{
    // アルバムに画像を保存
    //UIImageWriteToSavedPhotosAlbum(previewImage.image, self, nil, nil);
    
    // 撮影停止中の場合、撮影開始
    if(buttonStatus == NO)
    {
        buttonStatus = YES;
        [self timerStart];
        
        // 撮影時の端末の向きを確認
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        takephotoOrientation = orientation;
        NSLog(@"takephotoOrientation:%d",orientation);
        
    // 撮影中の場合、撮影停止
    }else{
        buttonStatus = NO;
        
        // タイマー停止
        [timer invalidate];
        
        // サムネイルページに遷移
        [self performSegueWithIdentifier:@"mySegue" sender:self];
    }
}


// タイマーを作成してスタート
-(void)timerStart
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(takePhoto:)
                                            userInfo:nil
                                             repeats:YES];
    count = 0;
}


-(IBAction)takePhoto:(id)Sender
{
    // 画像をArrayに保存
    [images addObject:image];
    
    // カウントアップ
    count = count+1;
    _countLabel.text = [NSString stringWithFormat:@"%d", count];
}


// Blur生成メソッド
-(void)blurViewSet
{
    // 元画像生成
    UIImageView * blurImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    blurImage.image = image;
    [self.view addSubview:blurImage];
    
    //ブラースタイルの決定
    UIVisualEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    //VisualEffectViewにVisualEffectを設定
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    //VisualEffectViewを_blurViewと同じサイズに設定
    effectView.frame = blurImage.bounds;
    
    // blurViewにVisualEffectViewを追加
    [blurImage addSubview:effectView];
    
    // ローディングを表示
    [self loadingSet];
}


// ローディング生成メソッド
-(void)loadingSet
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    [self.view addSubview:indicator];
    //[self.view bringSubviewToFront:indicator];
    indicator.frame = CGRectMake(self.view.bounds.size.width/2 - 10, self.view.bounds.size.height/2 -10, 20, 20);
    [indicator startAnimating];
}


// 画面遷移が行われる度に呼び出されるメソッド
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"images:%d",[images count]);
    
    if ([segue.identifier isEqualToString:@"mySegue"])
    {
        SecondViewController *viewCon = segue.destinationViewController;
        viewCon.images = images;
        viewCon.takephotoOrientation = takephotoOrientation;
    }
}


// 前ページに戻るためのメソッド
-(IBAction)goback:(UIStoryboardSegue *)mySegue
{
    // imagesを初期化
    [images removeAllObjects];
    
    // countを初期化
    _countLabel.text = @" ";
}


// 画面回転固定
- (BOOL)shouldAutorotate
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
