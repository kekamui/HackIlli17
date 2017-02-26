//
//  Session.h
//  HackIlli17
//
//  Created by Jonathan Chan on 2017-02-25.
//  Copyright © 2017 Jonathan Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Vuforia/Matrices.h>
#import <Vuforia/CameraDevice.h>
#import <Vuforia/State.h>

typedef enum : NSInteger {
    InitializingVuforia = 100,
    InitializingCamera = 110,
    StartingCamera = 111,
    StoppingCamera = 112,
    DeinitializingCamera = 113,
    InitializingTrackers = 120,
    LoadingTrackerData = 121,
    StartingTrackers = 122,
    StoppingTrackers = 123,
    UnloadingTrackerData = 124,
    DeinitializingTrackers = 125,
    CameraNotStarted = 150,
    InternalError = -1
} SessionError;


@protocol ARDelegate <NSObject>

@required
// this method is called to notify the application that the initialization (initAR) is complete
// usually the application then starts the AR through a call to startAR
- (void)onInitARDone:(NSError * _Nullable)error;

// the application must initialize its tracker(s)
- (BOOL)initializeTrackers;

// the application must initialize the data associated to its tracker(s)
- (BOOL)loadTrackerData;

// the application must starts its tracker(s)
- (BOOL)startTrackers;

// the application must stop its tracker(s)
- (BOOL)stopTrackers;

// the application must unload the data associated its tracker(s)
- (BOOL)unloadTrackerData;

// the application must deinititalize its tracker(s)
- (BOOL)deinitializeTrackers;

// the application msut handle the video background configuration
- (void)configureVideoBackgroundWithViewWidth:(CGFloat)viewWidth height:(CGFloat)viewHeight;

@optional
// optional method to handle the Vuforia callback - can be used to swap dataset for instance
- (void)onVuforiaUpdate:(Vuforia::State * _Nullable)state;

@end


@interface Session : NSObject

- (instancetype _Nonnull)initWithDelegate:(id<ARDelegate> _Nonnull)delegate;

// initialize the AR library. This is an asynchronous method. When the initialization is complete, the callback method initARDone will be called
- (void)initAR:(NSInteger)vuforiaInitFlags orientation:(UIInterfaceOrientation)orientation;

// start the AR session
- (BOOL)startAR:(Vuforia::CameraDevice::CAMERA_DIRECTION)cameraDirection error:(NSError * _Nullable * _Nullable)error;

// pause the AR session
- (BOOL)pauseAR:(NSError * _Nullable * _Nullable)error;

// resume the AR session
- (BOOL)resumeAR:(NSError * _Nullable * _Nullable)error;

// stop the AR session
- (BOOL)stopAR:(NSError * _Nullable * _Nullable)error;

// stop the camera.
// This can be used if you want to switch between the front and the back camera for instance
- (BOOL)stopCamera:(NSError * _Nullable * _Nullable)error;

@property (nonatomic) BOOL isRetinaDisplay;
//- (BOOL)isRetinaDisplay;
@property (nonatomic) BOOL cameraIsStarted;

@end
