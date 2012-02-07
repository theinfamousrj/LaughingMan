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

// Step 25: Create a CIDetector property for lazy instation later
@property (nonatomic, strong) CIDetector *faceDetector;

// Step 31: Create a UIImageView property for laughingMan
@property (nonatomic, strong) UIImageView *laughingMan;
@end


@implementation LaughingManViewController
@synthesize session = _session;
@synthesize videoDevice = _videoDevice;
@synthesize videoInput = _videoInput;
@synthesize frameOutput = _frameOutput;
@synthesize imageView = _imageView;
@synthesize context = _context;
@synthesize faceDetector = _faceDetector;
@synthesize laughingMan = _laughingMan;

// Step 26: Lazy instantiation of CIDetector faceDetector for initialization (low accuracy)
- (CIDetector *)faceDetector
{
    if (!_faceDetector) {
        NSDictionary *detectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyLow,CIDetectorAccuracy,nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return _faceDetector;
}


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
    
    // Step 32: Add laughingMan to the image
    self.laughingMan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"h4x.png"]];
    [self.laughingMan setHidden:YES];
    [self.view addSubview:self.laughingMan];
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
    // All filter steps are commented out with '///'
    // To re-do the filter, remove the '///' and follow step 24
    // Step 19: Create a filter
    // Filters are in an NSDictionary type setup and are called by a key in the form of an NSString eg: @"CIHueAdjust"
    ///CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
    
    // Step 20: Set the defaults for the filter
    ///[filter setDefaults];
    
    // Step 21: Send the filter an image
    ///[filter setValue:ciImage forKey:@"inputImage"];
    
    // Step 22: Set the angle
    ///[filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputAngle"];
    
    // Step 23: Send the result of the filtered image back
    ///CIImage *result = [filter valueForKey:@"outputImage"];
    
    // Step 27: Create an array of features and loop through it
    NSArray *features = [self.faceDetector featuresInImage:ciImage];
    bool faceFound = false;
    for (CIFaceFeature *face in features) {
        if (face.hasLeftEyePosition && face.hasRightEyePosition) {
            CGPoint eyeCenter = CGPointMake(face.leftEyePosition.x*0.5+face.rightEyePosition.x*0.5, face.leftEyePosition.y*0.5+face.rightEyePosition.y*0.5);
            
            // Step 28: Set the position of the laughingMan based on mouth position 
            double scalex = self.imageView.bounds.size.height/ciImage.extent.size.width;
            double scaley = self.imageView.bounds.size.width/ciImage.extent.size.height;
            self.laughingMan.center = CGPointMake(scaley*(eyeCenter.y-self.laughingMan.bounds.size.height/24.0), scalex*(eyeCenter.x));
            
            // Step 29: Set the angle of the laughingMan using eye deltas
            double deltax = face.leftEyePosition.x-face.rightEyePosition.x;
            double deltay = face.leftEyePosition.y-face.rightEyePosition.y;
            double angle = atan2(deltax, deltay);
            self.laughingMan.transform = CGAffineTransformMakeRotation(angle+M_PI);
            
            // Step 30: Set the size based on the dist between the eyes
            double scale = 12.0*sqrt((deltax*deltax)+(deltay+deltay));
            self.laughingMan.bounds = CGRectMake(0, 0, scale, scale);
            faceFound = true;
        }
    }
    
    // Step 33: If the face is found, apply the image to the face
    if (faceFound) {
        [self.laughingMan setHidden:NO];
    } else {
        [self.laughingMan setHidden:YES];
    }
    
    // Step 17: Turn CoreImage into CGImage which can be used in UIImage
    // Step 24: Change createCGImage:ciImage to createCGImage:result
    CGImageRef ref = [self.context createCGImage:ciImage fromRect:ciImage.extent];
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
