//
//  ViewController.h
//  AVCaptureVideoDataOutput
//
//  Created by yoheimiyamoto on 4/12/15.
//  Copyright (c) 2015 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> // デリゲート設定
- (IBAction)takeButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end

