//
//  SecondViewController.h
//  AVCaptureVideoDataOutput
//
//  Created by yoheimiyamoto on 4/12/15.
//  Copyright (c) 2015 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController<UIScrollViewDelegate> // デリゲート設定

@property (nonatomic) NSMutableArray* images; // 前画面から引き継ぐ値の格納先
@property (nonatomic) NSMutableArray* images2; // 前画面から引き継ぐ値の格納先
@property (nonatomic) BOOL takephotoOrientation; // 前画面から引き継ぐ値の格納先


@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
