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
    UIImageView * preView;
    NSMutableArray * images;
    NSTimer * timer;
    int count;
    BOOL buttonStatus;
    BOOL takephotoOrientation;
    
    UIScrollView * scrollView;
    UIPageControl * pageControl;
    NSMutableArray * images2;
    NSString * currentPage;
    int imageAngle;
    int imageWidth, imageHeight;
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
    images2 = [NSMutableArray array];
    
    buttonStatus = NO;
    
    // プレビュー画面生成
    preView = [[UIImageView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    
    // プレビューを画面に貼り付け
    [self.view addSubview:preView];
    
    // 背面に移動
    [self.view sendSubviewToBack:preView];
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
        preView.image = image;
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
    //
    
    
    // タイマー設定
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
    //[images addObject:image];
    
    // 画像をリサイズ
    //[self imagesResizeRotation];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
        [self imageResizeRotation:image myCount:count];
    }];
    
    
    
    // カウントアップ
    count = count+1;
    _countLabel.text = [NSString stringWithFormat:@"%d", count];
}


//スライド用に画像をリサイズ及び回転するメソッド
- (void)imagesResizeRotation
{
    // NSMutableArrya初期化
    images2 = [[NSMutableArray alloc]init];
    
    //最適なアングル、画像サイズを取得
    [self getAngleSize];
    
    // 画像を回転リサイズしてarrayに挿入
    for(int i = 0; i < [images count]; i++)
    {
        // imageViewを生成
        UIImageView* previewImage =[[UIImageView alloc]init];
        
        // 画像を回転リサイズ
        previewImage.image = [self rotateImage:images[i] angle:imageAngle];
        
        // 画像をリサイズ位置変更
        previewImage.frame = CGRectMake(imageWidth*i, 0, imageWidth, imageHeight);
        
        [images2 addObject:previewImage];
    }
}


//スライド用に画像をリサイズ及び回転するメソッド
- (void)imageResizeRotation:(UIImage*)myImage myCount:(int)myCount
{
    //最適なアングル、画像サイズを取得
    [self getAngleSize];

    // imageViewを生成
    UIImageView* previewImage =[[UIImageView alloc]init];
    
    // 画像を回転リサイズ
    previewImage.image = [self rotateImage:myImage angle:imageAngle];
    
    // 画像をリサイズ位置変更
    previewImage.frame = CGRectMake(imageWidth * myCount, 0, imageWidth, imageHeight);
    
    [images2 addObject:previewImage];
}



// 最適なアングルサイズ取得メソッド
- (void)getAngleSize
{
    switch (takephotoOrientation)
    {
            
        case UIDeviceOrientationPortrait:
            // iPhoneを縦にして、ホームボタンが下にある状態
            imageAngle =  360;
            imageWidth = self.view.bounds.size.width;
            imageHeight = self.view.bounds.size.height;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            // iPhoneを縦にして、ホームボタンが上にある状態
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            // iPhoneを横にして、ホームボタンが右にある状態
            imageAngle = 0;
            imageWidth = self.view.bounds.size.height;
            imageHeight = self.view.bounds.size.width;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            // iPhoneを横にして、ホームボタンが左にある状態
            imageAngle = 180;
            imageWidth = self.view.bounds.size.height;
            imageHeight = self.view.bounds.size.width;
            break;
            
        case UIDeviceOrientationFaceUp:
            // iPhoneの液晶面を天に向けた状態
            break;
            
        case UIDeviceOrientationFaceDown:
            // iPhoneの液晶面を地に向けた状態
            break;
            
        case UIDeviceOrientationUnknown:
        default:
            // 向きが分からない状態
            break;
    }
}


    
// 画像回転メソッド
- (UIImage*)rotateImage:(UIImage*)myImage angle:(int)myAngle
{
    if(myAngle != 360)
    {
        CGSize imgSize = {myImage.size.width, image.size.height};
        UIGraphicsBeginImageContext(imgSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, myImage.size.width/2, myImage.size.height/2); // 回転の中心点を移動
        CGContextScaleCTM(context, 1.0, -1.0); // Y軸方向を補正
        
        float radian = myAngle * M_PI / 180; // 45°回転させたい場合
        CGContextRotateCTM(context, radian);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-myImage.size.width/2, -myImage.size.height/2, myImage.size.width, myImage.size.height), myImage.CGImage);
        
        UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // UIImageViewに回転後の画像を設定
        
        return rotatedImage;
    }else{
        return  myImage;
    }
}


// 画面遷移が行われる度に呼び出されるメソッド
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"images:%d",[images count]);
    
    if ([segue.identifier isEqualToString:@"mySegue"])
    {
        SecondViewController *viewCon = segue.destinationViewController;
        viewCon.images = images;
        viewCon.images2 = images2;
        viewCon.takephotoOrientation = takephotoOrientation;
    }
}


// 前ページに戻るためのメソッド
-(IBAction)goback:(UIStoryboardSegue *)mySegue
{
    // imagesを初期化
    [images removeAllObjects];
    [images2 removeAllObjects];
    
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
