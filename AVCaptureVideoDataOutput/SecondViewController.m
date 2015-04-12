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
    NSMutableArray * images2;
    NSString * currentPage;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // スライド生成
    [self slideSet];

}


//スライド生成メソッド
- (void)slideSet
{
    // NSMutableArrya初期化
    images2 = [[NSMutableArray alloc]init];
    
    // 既存のスクロールビューを削除
    [scrollView removeFromSuperview];
    
    // 画面サイズ取得
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = rect.size.width;
    CGFloat screenHeight = rect.size.height;
    
    // 画像サイズ取得
    UIImage * image = _images[0];
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    // スライド画像サイズ
    CGFloat slideimageWidth;
    CGFloat slideimageHeight;
    
    // スライド位置
    CGFloat slideimageX;
    CGFloat slideimageY;
    
    // スライド回転角度
    int slideimageAngle;
    
    // タテ画像の場合
    if(imageHeight > imageWidth)
    {
        if(screenHeight > screenWidth)
        {
            slideimageWidth = screenWidth;
            slideimageHeight = screenHeight;
            slideimageX = 0;
            slideimageY = 0;
            slideimageAngle = 0;
            
        } else{
            slideimageWidth = imageWidth*(screenHeight/imageHeight);
            slideimageHeight = screenHeight;
            slideimageX = screenWidth/2 - slideimageWidth/2;
            slideimageY = 0;
        }
    }
    
    // ヨコ画像の場合
    if(imageHeight < imageWidth)
    {
        if(screenHeight < screenWidth)
        {
            slideimageWidth = screenWidth;
            slideimageHeight = screenHeight;
            slideimageX = 0;
            slideimageY = 0;
            
        } else{
            slideimageWidth = screenWidth;
            slideimageHeight = imageHeight*(screenHeight/imageHeight);
            slideimageX = 0;
            slideimageY = screenHeight/2 - slideimageHeight/2;;
            
        }
    }
    
    
    // 画像にレイアウト情報追加
    NSLog(@"takePhotoPortrait:%d",_takephotoPortrait);
    
    for(int i = 0; i < [_images count]; i++)
    {
        // Landscapeモードで撮影されたものであれば画像回転
        if(_takephotoPortrait == NO)
        {
            [self rotateImage:_images[i] angle:90];
        }
        
        UIImageView* imageView =[[UIImageView alloc]initWithImage:_images[i]];
        imageView.frame = CGRectMake(slideimageWidth*i, 0, slideimageWidth, slideimageHeight);
        //imageView.frame = CGRectMake(screenWidth*i, 0, screenWidth, screenHeight);
        
        //imageView.clipsToBounds = YES; //クリッピング
        [images2 addObject:imageView];
    }
    
    // UIScrollViewのインスタンス化
    scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(slideimageX, slideimageY, slideimageWidth, slideimageHeight);
    
    // 横スクロールのインジケータを非表示にする
    scrollView.showsHorizontalScrollIndicator = NO;
    
    // ページングを有効にする
    scrollView.pagingEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    _imageView.userInteractionEnabled = YES;
    
    // デリゲートを設定
    scrollView.delegate = self;
    
    // スクロールの範囲を設定
    [scrollView setContentSize:CGSizeMake(([images2 count] * slideimageWidth), slideimageHeight)];
    
    // スクロールビューを貼付ける
    [_imageView addSubview:scrollView];
    //[self.view sendSubviewToBack:scrollView]; // 最背面に移動
    
    // スクロールビューに画像貼り付け
    for (int i = 0; i < [images2 count]; i++)
    {
        [scrollView addSubview:images2[i]];
    }
    
    // indexLabelの初期値設定
    _indexLabel.text = [
                        @"1"
                        stringByAppendingString:
                        [
                         @" / " stringByAppendingString:
                         [NSString stringWithFormat:@"%d",[images2 count]]
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
                        [NSString stringWithFormat:@"%d",[images2 count]]
                        ]
                       ]
        ;
        
        _indexLabel.text = currentPage;
    }
}


// 端末回転時のスライド調整
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {
    if(FromInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        // 横向き
        [self slideSet];
    } else {
        // 縦向き
        [self slideSet];
    }
}


// 画像回転メソッド
- (UIImage*)rotateImage:(UIImage*)image angle:(int)angle
{
    CGSize imgSize = {image.size.width, image.size.height};
    UIGraphicsBeginImageContext(imgSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, image.size.width/2, image.size.height/2); // 回転の中心点を移動
    CGContextScaleCTM(context, 1.0, -1.0); // Y軸方向を補正
    
    float radian = angle * M_PI / 180; // 45°回転させたい場合
    CGContextRotateCTM(context, radian);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-image.size.width/2, -image.size.height/2, image.size.width, image.size.height), image.CGImage);
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotatedImage;
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


@end
