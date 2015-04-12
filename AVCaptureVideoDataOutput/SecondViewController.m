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
    
    // NSMutableArrya初期化
    images2 = [[NSMutableArray alloc]init];
    
    // 画面サイズ取得
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    // 画像にCGRectを追加
    for(int i = 0; i < [_images count]; i++)
    {
        UIImageView* imageView =[[UIImageView alloc]initWithImage:_images[i]];
        imageView.frame = CGRectMake(width*i, 0, width, height);
        //imageView.clipsToBounds = YES; //クリッピング
        [images2 addObject:imageView];
    }
    
    // UIScrollViewのインスタンス化
    scrollView = [[UIScrollView alloc]init];
    scrollView.frame = self.view.bounds;
    
    // 横スクロールのインジケータを非表示にする
    scrollView.showsHorizontalScrollIndicator = NO;
    
    // ページングを有効にする
    scrollView.pagingEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    _imageView.userInteractionEnabled = YES;
    
    // デリゲートを設定
    scrollView.delegate = self;
    
    // スクロールの範囲を設定
    [scrollView setContentSize:CGSizeMake(([images2 count] * width), height)];
    
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
                        ]
    ;
    
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
