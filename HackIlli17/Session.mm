//
//  Session.mm
//  HackIlli17
//
//  Created by Jonathan Chan on 2017-02-25.
//  Copyright © 2017 Jonathan Chan. All rights reserved.
//

#import "Session.h"
//#import "SampleApplicationUtils.h"
#import <Vuforia/Vuforia.h>
#import <Vuforia/Vuforia_iOS.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/CameraDevice.h>
#import <Vuforia/VideoBackgroundConfig.h>
#import <Vuforia/UpdateCallback.h>

#import <UIKit/UIKit.h>

// class used to support the Vuforia callback mechanism
class VuforiaApplication_UpdateCallback : public Vuforia::UpdateCallback {
public:
    Session *session;
    virtual void Vuforia_onUpdate(Vuforia::State& state);
};

@interface Session ()

@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic) BOOL cameraIsActive;

// SampleApplicationControl delegate (receives callbacks in response to particular
// events, such as completion of Vuforia initialisation)
@property (strong, nonatomic) id<ARDelegate> _Nullable delegate;

- (BOOL)isRetinaDisplay;

- (NSError * _Nonnull)errorWithCode:(NSInteger)code;
- (NSError * _Nonnull)errorWithDescription:(NSString * _Nonnull)description code:(NSInteger)code;
- (NSError * _Nullable)errorWithCode:(NSInteger)code error:(NSError * _Nullable * _Nullable)error;

@property (nonatomic) NSInteger vuforiaInitFlags;

- (void)initVuforiaInBackground;
- (void)prepareAR;
//- (void)showCameraAccessWarning;

@property (nonatomic) Vuforia::CameraDevice::CAMERA_DIRECTION cameraDirection;

- (void)updateDelegateWithState:(Vuforia::State * _Nullable)state;
- (CGSize)currentARViewSize;

@property (nonatomic) VuforiaApplication_UpdateCallback vuforiaCallback;

- (void)initTracker;
- (void)loadTrackerData;
- (void)loadTrackerDataInBackground;
- (BOOL)startCameraWithDirection:(Vuforia::CameraDevice::CAMERA_DIRECTION)direction viewWidth:(CGFloat)width height:(CGFloat)height error:(NSError * _Nullable * _Nullable)error;

@end

#ifndef ERROR_DOMAIN
#define ERROR_DOMAIN @"HackIlli17"
#endif


@implementation Session

- (instancetype _Nonnull)initWithDelegate:(id<ARDelegate> _Nonnull)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)initAR:(NSInteger)vuforiaInitFlags orientation:(UIInterfaceOrientation)orientation {
    self.cameraIsActive = NO;
    self.cameraIsStarted = NO;
    self.vuforiaInitFlags = vuforiaInitFlags;
    self.isRetinaDisplay = [self isRetinaDisplay];
    self.vuforiaInitFlags = orientation;
    self.cameraDirection = Vuforia::CameraDevice::CAMERA_DIRECTION_DEFAULT;
    
    // Initialising Vuforia is a potentially lengthy operation, so perform it on a
    // background thread
    [self performSelectorInBackground:@selector(initVuforiaInBackground) withObject:nil];
}

- (BOOL)startAR:(Vuforia::CameraDevice::CAMERA_DIRECTION)cameraDirection error:(NSError * _Nullable * _Nullable)error {
    CGSize arViewBoundsSize = [self currentARViewSize];
    
    // Start the camera.  This causes Vuforia to locate our EAGLView in the view
    // hierarchy, start a render thread, and then call renderFrameVuforia on the
    // view periodically
    if (![self startCameraWithDirection:cameraDirection viewWidth:arViewBoundsSize.width height:arViewBoundsSize.height error:error]) {
        return NO;
    }
    self.cameraIsActive = YES;
    self.cameraIsStarted = YES;
    
    return YES;
}

- (BOOL)pauseAR:(NSError * _Nullable * _Nullable)error {
    if (self.cameraIsActive) {
        // Stop and deinit the camera
        if (!Vuforia::CameraDevice::getInstance().stop()) {
            [self errorWithCode:StoppingCamera error:error];
            return NO;
        }
        if (!Vuforia::CameraDevice::getInstance().deinit()) {
            [self errorWithCode:DeinitializingCamera error:error];
            return NO;
        }
        self.cameraIsActive = NO;
    }
    Vuforia::onPause();
    return YES;
}

- (BOOL)resumeAR:(NSError * _Nullable * _Nullable)error {
    Vuforia::onResume();
    
    // if the camera was previously started, but not currently active, then
    // we restart it
    if (self.cameraIsStarted && !self.cameraIsActive) {
        
        // initialize the camera
        if (!Vuforia::CameraDevice::getInstance().init(self.cameraDirection)) {
            [self errorWithCode:InitializingCamera error:error];
            return NO;
        }
        
        // start the camera
        if (!Vuforia::CameraDevice::getInstance().start()) {
            [self errorWithCode:StartingCamera error:error];
            return NO;
        }
        
        self.cameraIsActive = YES;
    }
    return YES;
}

- (BOOL)stopAR:(NSError * _Nullable * _Nullable)error {
    // Stop the camera
    if (self.cameraIsActive) {
        // Stop and deinit the camera
        Vuforia::CameraDevice::getInstance().stop();
        Vuforia::CameraDevice::getInstance().deinit();
        self.cameraIsActive = NO;
    }
    self.cameraIsStarted = NO;
    
    // ask the application to stop the trackers
    if (![self.delegate stopTrackers]) {
        [self errorWithCode:StoppingTrackers error:error];
        return NO;
    }
    
    // ask the application to unload the data associated to the trackers
    if (![self.delegate unloadTrackerData]) {
        [self errorWithCode:UnloadingTrackerData error:error];
        return NO;
    }
    
    // ask the application to deinit the trackers
    if (![self.delegate deinitializeTrackers]) {
        [self errorWithCode:DeinitializingTrackers error:error];
        return NO;
    }
    
    // Pause and deinitialise Vuforia
    Vuforia::onPause();
    Vuforia::deinit();
    
    return YES;
}

- (BOOL)stopCamera:(NSError * _Nullable * _Nullable)error {
    if (self.cameraIsActive) {
        // Stop and deinit the camera
        Vuforia::CameraDevice::getInstance().stop();
        Vuforia::CameraDevice::getInstance().deinit();
        self.cameraIsActive = NO;
    } else {
        [self errorWithCode:CameraNotStarted error:error];
        return NO;
    }
    self.cameraIsStarted = NO;
    
    // Stop the trackers
    if (![self.delegate stopTrackers]) {
        [self errorWithCode:StoppingTrackers error:error];
        return NO;
    }
    
    return YES;
}

// This is actually very shittily implemented but it's how the sample app did it
- (BOOL)isRetinaDisplay {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && 1.0 < [UIScreen mainScreen].scale);
}

- (NSError * _Nonnull)errorWithCode:(NSInteger)code {
    return [NSError errorWithDomain:ERROR_DOMAIN code:code userInfo:nil];
}

- (NSError * _Nonnull)errorWithDescription:(NSString * _Nonnull)description code:(NSInteger)code {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
    return [NSError errorWithDomain:ERROR_DOMAIN
                               code:code
                           userInfo:userInfo];
}

- (NSError * _Nullable)errorWithCode:(NSInteger)code error:(NSError * _Nullable * _Nullable)error {
    if (!error) {
        *error = [self errorWithCode:code];
        return *error;
    }
    return nil;
}

// Initialise Vuforia
// (Performed on a background thread)
- (void)initVuforiaInBackground {
    // Background thread must have its own autorelease pool
    @autoreleasepool {
        Vuforia::setInitParameters((int)self.vuforiaInitFlags, "AaXlfNn/////AAAAGd5vK01KX0uhmYKAR1MJ7mkBJpz14fy7U4JRqsncBG7gV7MHdvntlP/pxq4XPF2aDp7sw1a3JgnxfQWdaDP4ENTFDg8/74RH0418yl7THtp5Se4M8VK8AoFMbUois0ArqOmDcqzUoqNqhqj/vOp8ZVb7WrdnwFvE/95AEgqU+QyhGrl7HNu64KR1tntlewQrPCwCwKlO56+DXODlHMRXEl7dvjHplJaHjE6kelIbZFXGg/6UdwtYQJgI9SFk70UzvD+F5ycdGwkoLAGwTORuVCSD+uVK9lSrwwMrJLQz5RDDHvPBVHiMbnWIxNkoKxYxT4laAfclFoVZ/R2SVNDyXhov/k87Gf0PqATRgARF2Z8M");
        
        // Vuforia::init() will return positive numbers up to 100 as it progresses
        // towards success.  Negative numbers indicate error conditions
        NSInteger initSuccess = 0;
        do {
            initSuccess = Vuforia::init();
        } while (0 <= initSuccess && 100 > initSuccess);
        
        if (initSuccess == 100) {
            // We can now continue the initialization of Vuforia
            // (on the main thread)
            [self performSelectorOnMainThread:@selector(prepareAR) withObject:nil waitUntilDone:NO];
        } else {
            // Failed to initialise Vuforia:
            if (initSuccess == Vuforia::INIT_NO_CAMERA_ACCESS) {
                // On devices running iOS 8+, the user is required to explicitly grant
                // camera access to an App.
                // If camera access is denied, Vuforia::init will return
                // Vuforia::INIT_NO_CAMERA_ACCESS.
                // This case should be handled gracefully, e.g.
                // by warning and instructing the user on how
                // to restore the camera access for this app
                // via Device Settings > Privacy > Camera
//                [self performSelectorOnMainThread:@selector(showCameraAccessWarning) withObject:nil waitUntilDone:YES];
                // UIAlertView solution is shitty so we'll just throw
                throw [[NSException alloc] initWithName:@"Unable to continue initializing Vuforia." reason:@"Unable to access camera." userInfo:nil];
            } else {
                NSError *error;
                switch (initSuccess) {
                    case Vuforia::INIT_LICENSE_ERROR_NO_NETWORK_TRANSIENT:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_LICENSE_ERROR_NO_NETWORK_TRANSIENT", nil) code:initSuccess];
                        break;
                        
                    case Vuforia::INIT_LICENSE_ERROR_NO_NETWORK_PERMANENT:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_LICENSE_ERROR_NO_NETWORK_PERMANENT", nil) code:initSuccess];
                        break;
                        
                    case Vuforia::INIT_LICENSE_ERROR_INVALID_KEY:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_LICENSE_ERROR_INVALID_KEY", nil) code:initSuccess];
                        break;
                        
                    case Vuforia::INIT_LICENSE_ERROR_CANCELED_KEY:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_LICENSE_ERROR_CANCELED_KEY", nil) code:initSuccess];
                        break;
                        
                    case Vuforia::INIT_LICENSE_ERROR_MISSING_KEY:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_LICENSE_ERROR_MISSING_KEY", nil) code:initSuccess];
                        break;
                        
                    case Vuforia::INIT_LICENSE_ERROR_PRODUCT_TYPE_MISMATCH:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_LICENSE_ERROR_PRODUCT_TYPE_MISMATCH", nil) code:initSuccess];
                        break;
                        
                    default:
                        error = [self errorWithDescription:NSLocalizedString(@"INIT_default", nil) code:initSuccess];
                        break;
                        
                }
                // Vuforia initialization error
                [self.delegate onInitARDone:error];
            }
        }
    }
}

//- (void)showCameraAccessWarning {
//    UIViewController *presentedViewController = [[[UIApplication sharedApplication] keyWindow] subviews]
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to access camera." message:@"Please allow access in Settings." preferredStyle:UIAlertControllerStyleAlert];
//    [self ]
//}

- (void)updateDelegateWithState:(Vuforia::State * _Nullable)state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onVuforiaUpdate:)]) {
        [self.delegate onVuforiaUpdate:state];
    }
}

- (CGSize)currentARViewSize {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize viewSize = screenBounds.size;
    
    // If this device has a retina display, scale the view bounds
    // for the AR (OpenGL) view
    if (self.isRetinaDisplay) {
        viewSize.width *= [UIScreen mainScreen].nativeScale;
        viewSize.height *= [UIScreen mainScreen].nativeScale;
    }
    return viewSize;
}

- (void)prepareAR {
    _vuforiaCallback.session = self;
    // we register for the Vuforia callback
    Vuforia::registerCallback(&_vuforiaCallback);
    
    // Tell Vuforia we've created a drawing surface
    Vuforia::onSurfaceCreated();
    
    CGSize viewBoundsSize = [self currentARViewSize];
    int smallerSize = MIN(viewBoundsSize.width, viewBoundsSize.height);
    int largerSize = MAX(viewBoundsSize.width, viewBoundsSize.height);
    
    // Frames from the camera are always landscape, no matter what the
    // orientation of the device.  Tell Vuforia to rotate the video background (and
    // the projection matrix it provides to us for rendering our augmentation)
    // by the proper angle in order to match the EAGLView orientation
    if (self.orientation == UIInterfaceOrientationPortrait) {
        Vuforia::onSurfaceChanged(smallerSize, largerSize);
        Vuforia::setRotation(Vuforia::ROTATE_IOS_90);
    } else if (self.orientation == UIInterfaceOrientationPortraitUpsideDown) {
        Vuforia::onSurfaceChanged(smallerSize, largerSize);
        Vuforia::setRotation(Vuforia::ROTATE_IOS_270);
    } else if (self.orientation == UIInterfaceOrientationLandscapeLeft) {
        Vuforia::onSurfaceChanged(largerSize, smallerSize);
        Vuforia::setRotation(Vuforia::ROTATE_IOS_180);
    } else if (self.orientation == UIInterfaceOrientationLandscapeRight) {
        Vuforia::onSurfaceChanged(largerSize, smallerSize);
        Vuforia::setRotation(Vuforia::ROTATE_IOS_0);
    }
    
    [self initTracker];

}

- (void)initTracker {
    // ask the application to initialize its trackers
    if (![self.delegate initializeTrackers]) {
        [self.delegate onInitARDone:[self errorWithCode:InitializingTrackers]];
        return;
    }
    [self loadTrackerData];
}

- (void)loadTrackerData {
    // Loading tracker data is a potentially lengthy operation, so perform it on
    // a background thread
    [self performSelectorInBackground:@selector(loadTrackerDataInBackground) withObject:nil];
}

// *** Performed on a background thread ***
- (void)loadTrackerDataInBackground {
    // Background thread must have its own autorelease pool
    @autoreleasepool {
        // the application can now prepare the loading of the data
        if (![self.delegate loadTrackerData]) {
            [self.delegate onInitARDone:[self errorWithCode:LoadingTrackerData]];
            return;
        }
    }
    
    [self.delegate onInitARDone:nil];
}

- (BOOL)startCameraWithDirection:(Vuforia::CameraDevice::CAMERA_DIRECTION)direction viewWidth:(CGFloat)width height:(CGFloat)height error:(NSError * _Nullable * _Nullable)error {
    // initialize the camera
    if (!Vuforia::CameraDevice::getInstance().init(direction)) {
        [self errorWithCode:InternalError error:error];
        return NO;
    }
    
    // select the default video mode
    if (!Vuforia::CameraDevice::getInstance().selectVideoMode(Vuforia::CameraDevice::MODE_DEFAULT)) {
        [self errorWithCode:InternalError error:error];
        return NO;
    }
    
    // configure Vuforia video background
    [self.delegate configureVideoBackgroundWithViewWidth:width height:height];
    
    // set the FPS to its recommended value
    int recommendedFps = Vuforia::Renderer::getInstance().getRecommendedFps();
    Vuforia::Renderer::getInstance().setTargetFps(recommendedFps);
    
    // start the camera
    if (!Vuforia::CameraDevice::getInstance().start()) {
        [self errorWithCode:InternalError error:error];
        return NO;
    }
    
    // we keep track of the current camera to restart this
    // camera when the application comes back to the foreground
    self.cameraDirection = direction;
    
    // ask the application to start the tracker(s)
    if (![self.delegate startTrackers] ) {
        [self errorWithCode:InternalError error:error];
        return NO;
    }
    
    return YES;
}

void VuforiaApplication_UpdateCallback::Vuforia_onUpdate(Vuforia::State& state)
{
    if (session) {
        [session updateDelegateWithState:&state];
    }
}

@end
