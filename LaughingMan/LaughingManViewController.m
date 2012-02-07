//
//  LaughingManViewController.m
//  LaughingMan
//
//  Created by theinfamousrj on 2/6/12.
//  Copyright (c) 2012 omfgp.com. All rights reserved.
//

#import "LaughingManViewController.h"

@interface LaughingManViewController()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *frameOutput;

// Step 12: Add UIImageView to storyboard
// Step 13: Add outlet for UIImageView
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

// Step 15: Create CoreImageContext
@property (nonatomic, strong) CIContext *context;
@end


@implementation LaughingManViewController
@synthesize session = _session;
@synthesize videoDevice = _videoDevice;
@synthesize videoInput = _videoInput;
@synthesize frameOutput = _frameOutput;
@synthesize imageView = _imageView;
@synthesize context = _context;

// Step 16: Lazy instantiation of CIContext context for initialization
- (CIContext *)context
{
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Step 1: Allocate a session
    self.session = [[AVCaptureSession alloc] init];
    
    // Step 2: Set a session preset (resolution)
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    
    // Step 3: Create video device
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Step 4: Create video input (in a real app  you'd want to pass an error object instead of nil)
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    
    // Step 5: Create frame output that will take session data
    self.frameOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // Step 6: Set up pixel format for output
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // Step 7: Wire it all together
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.frameOutput];
    
    // Step 11: Tell output that AVDemoViewController is the delegate for the output
    // Dispatch queue runs on a different thread other than the UI thread
    [self.frameOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    // Step 8: Gets the device to take camera info and send it
    [self.session startRunning];
    
    // Step 9 is in the header
}

// Step 10: Implement delegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Can't set image property in the delegate if you run on anything but the main queue
    // We wouldn't be able to modify the UI from a different thread
    
    // Step 14: Creating a reference to the sample buffer in a format that we can pass to coreImage (boilerplate code)
    // coreImage is optimized for doing transformations, UIImage is NOT!
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pb];
    
    // Optional steps for filtering
    // Step 19: Create a filter
    // Filters are in an NSDictionary type setup and are called by a key in the form of an NSString eg: @"CIHueAdjust"
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
    
    // Step 20: Set the defaults for the filter
    [filter setDefaults];
    
    // Step 21: Send the filter an image
    [filter setValue:ciImage forKey:@"inputImage"];
    
    // Step 22: Set the angle
    [filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputAngle"];
    
    // Step 23: Send the result of the filtered image back
    CIImage *result = [filter valueForKey:@"outputImage"];
    
    // Step 17: Turn CoreImage into CGImage which can be used in UIImage
    // Step 24: Change createCGImage:ciImage to createCGImage:result
    CGImageRef ref = [self.context createCGImage:result fromRect:ciImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];
    
    // Step 18: Release the reference
    CGImageRelease(ref);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
