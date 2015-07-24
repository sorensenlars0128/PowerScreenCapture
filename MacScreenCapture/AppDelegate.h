//
//  AppDelegate.h
//  MacScreenCapture
//
//  Created by dol on 4/16/15.
//  Copyright (c) 2015 ___MrtDevTeam___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RoundWindowFrameView.h"
#import "DrawMouseBoxView.h"

@class AVCaptureSession, AVCaptureScreenInput, AVCaptureMovieFileOutput;

@interface AppDelegate : NSObject <NSApplicationDelegate>   {
    NSString * fileName;
    NSString *finalMPEGPath;
    NSString * finalGIFPath;
}

    @property (assign) IBOutlet NSWindow *window;
    @property (strong)   IBOutlet RoundWindowFrameView* frameView;
    @property (assign) IBOutlet  NSMenu  *statusMenu;
    @property (nonatomic, assign) bool is_recording;


    - (IBAction)OnClickShow:(id)sender;
    - (IBAction)OnClickHide:(id)sender;
    - (IBAction)OnClickExit:(id)sender;

    - (void)setVisible:(bool)isVisible;

    - (void)startRecording;
    - (void)stopRecording;
    - (void)setDisplayAndCropRect;
    - (void)startGeneratingGif;

@end
