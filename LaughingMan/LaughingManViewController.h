//
//  LaughingManViewController.h
//  LaughingMan
//
//  Created by theinfamousrj on 2/6/12.
//  Copyright (c) 2012 omfgp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// Step 9: Add delegation
@interface LaughingManViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@end
