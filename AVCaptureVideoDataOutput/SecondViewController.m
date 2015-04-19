//
//  SecondViewController.m
//  AVCaptureVideoDataOutput
//
//  Created by yoheimiyamoto on 4/12/15.
//  Copyright (c) 2015 mycompany. All rights reserved.
//

#import "SecondViewController.h"

@implementation SecondViewController
{
    UIScrollView * scrollView;
    UIPageControl * pageControl;
    NSString * currentPage;
    int angle;
    int width, height;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // スライド生成
    [self slideSet];

    NSLog(@"_images:%d",[_images count]);
    NSLog(@"_images2:%d",[_images2 count]);
    
}


//スライド生成メソッド
- (void)slideSet
{
    // NSMutableArrya初期化
    //images2 = [[NSMutableArray alloc]init];
    
    // 既存のスクロールビューを削除
    [scrollView removeFromSuperview];
    
    //最適なアングル、画像サイズを取得
    [self getAngleSize];
    
    // UIScrollView生成
    scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(0,0,width,height); // サイズ指定
    
    [scrollView setContentSize:CGSizeMake(([_images2 count] * width), height)]; // スクロールの範囲を設定
    
    scrollView.showsHorizontalScrollIndicator = NO; // 横スクロールのインジケータを非表示にする
    
    // ページングを有効にする
    scrollView.pagingEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    _imageView.userInteractionEnabled = YES;
    
    scrollView.delegate = self;  // デリゲートを設定
    
    // スクロールビューを貼付ける
    [_imageView addSubview:scrollView];
    //[self.view sendSubviewToBack:scrollView]; // 最背面に移動
    
    // スクロールビューに画像貼り付け
    for (int i = 0; i < [_images2 count]; i++)
    {
        [scrollView addSubview:_images2[i]];
    }
    
    // indexLabelの初期値設定
    _indexLabel.text = [
                        @"1"
                        stringByAppendingString:
                        [
                         @" / " stringByAppendingString:
                         [NSString stringWithFormat:@"%d",[_images2 count]]
                         ]
                        ];
}


// スクロールされた時のデリゲート
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    if ((NSInteger)fmod(scrollView.contentOffset.x , pageWidth) == 0)
    {
        // ページコントロールに現在のページを設定
        
        
        currentPage = [
                       [NSString stringWithFormat:@"%0.f",(scrollView.contentOffset.x / pageWidth)+1]
                       stringByAppendingString:
                       [
                        @" / " stringByAppendingString:
                        [NSString stringWithFormat:@"%d",[_images2 count]]
                        ]
                       ]
        ;
        
        _indexLabel.text = currentPage;
    }
}


// 最適なアングルサイズ取得メソッド
- (void)getAngleSize
{
    switch (_takephotoOrientation) {
            
        case UIDeviceOrientationPortrait:
            // iPhoneを縦にして、ホームボタンが下にある状態
            angle =  360;
            width = self.view.bounds.size.width;
            height = self.view.bounds.size.height;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            // iPhoneを縦にして、ホームボタンが上にある状態
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            // iPhoneを横にして、ホームボタンが右にある状態
            angle = 0;
            width = self.view.bounds.size.height;
            height = self.view.bounds.size.width;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            // iPhoneを横にして、ホームボタンが左にある状態
            angle = 180;
            width = self.view.bounds.size.height;
            height = self.view.bounds.size.width;
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
- (UIImage*)rotateImage:(UIImage*)image angle:(int)myangle
{
    if(myangle != 360)
    {
        CGSize imgSize = {image.size.width, image.size.height};
        UIGraphicsBeginImageContext(imgSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, image.size.width/2, image.size.height/2); // 回転の中心点を移動
        CGContextScaleCTM(context, 1.0, -1.0); // Y軸方向を補正
        
        float radian = myangle * M_PI / 180; // 45°回転させたい場合
        CGContextRotateCTM(context, radian);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-image.size.width/2, -image.size.height/2, image.size.width, image.size.height), image.CGImage);
        
        UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // UIImageViewに回転後の画像を設定
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = rotatedImage;
        
        return rotatedImage;
    }else{
        return  image;
    }
}


- (IBAction)saveButton:(UIBarButtonItem *)sender
{
    // 画像保存完了時のセレクタ指定
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    
    // カメラロールに保存
    UIImageWriteToSavedPhotosAlbum(_images[currentPage.integerValue], self, selector, NULL);
    NSLog(@"savedFrame:%@",currentPage);
}


// 画像保存完了時のセレクタ
- (void)onCompleteCapture:(UIImage *)screenImage
 didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"SAVED!";
    if (error) message = @"画像の保存に失敗しました";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}


// 画面回転固定
- (BOOL)shouldAutorotate
{
    return NO;
}


@end
