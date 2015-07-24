//
//  AppDelegate.m
//  PowerScreenCapture
//
//  Created by dol on 4/16/15.
//  Copyright (c) 2015 ___MrtDevTeam___. All rights reserved.
//

#import "AppDelegate.h"
#import "LNGIFConverter.h"
#import <AVFoundation/AVFoundation.h>

#import "FolderLazyCollection.h"
#import "VideoLazyCollection.h"
#import "GifExporter.h"
#import "NSAlert+Popover.h"
#import "AspectRatio.h"
#import "GrantAccess.h"
#import "Helper.h"


#define STATUS_ITEM_VIEW_WIDTH 18.0
#define POPUP_HEIGHT 472
#define PANEL_WIDTH 400
#define ARROW_WIDTH 12
#define ARROW_HEIGHT 8
#define OPEN_DURATION .25

#define MAX_FRAMECOUNT 600
#define FRAME_RATE 5.0





@interface AppDelegate () <AVCaptureFileOutputDelegate,AVCaptureFileOutputRecordingDelegate,DrawMouseBoxViewDelegate,GifExporterDelegate, NSMenuDelegate>

@property (strong, nonatomic) NSStatusItem*statusItem;
@property (strong) AVCaptureSession *captureSession;
@property (strong) AVCaptureScreenInput *captureScreenInput;

//    @property (nonatomic, strong) GifExporter *currentExporter;
@end

@implementation AppDelegate
{
    CGDirectDisplayID           display;
    AVCaptureMovieFileOutput    *captureMovieFileOutput;
    NSMutableArray              *shadeWindows;
    
    NSURL *mp4_fileURL;
    bool visible;
    NSTimer*timerScanning, *timerPosAdjust;
    CGRect cg_cropRect;
    NSMutableArray *gifFrameArray;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /*  Grant Access */
    NSString * savePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SavePath"];
    if( savePath != nil )
        [[GrantAccess sharedInstance] startAccessingToPath:savePath];
    
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"icon record_x16.png"];
    //    [_statusItem.image setTemplate:YES];
    
    _statusItem.highlightMode = YES;
    _statusItem.toolTip = @"PowerScreenCapture";
    
    //    [_statusItem setDoubleAction:@selector(itemClicked:)];
    [_statusItem setAction:@selector(itemClicked:)];
    //    [_statusItem setMenu:_statusMenu];
    
    visible = false;
    //Set theme and update listeners
    /* CFPreferencesSetValue((CFStringRef)@"AppleInterfaceStyle", @"Dark", kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
     dispatch_async(dispatch_get_main_queue(), ^{
     CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)@"AppleInterfaceThemeChangedNotification", NULL, NULL, YES);
     
     });
     */
    NSError*outError;
    [self createCaptureSession:&outError];
    [self.captureSession startRunning];
    
    
    [_frameView loadSavedData];
    self.is_recording = false;
    gifFrameArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustIconPos) name:NSWindowDidResizeNotification object:nil];
    [self.window setLevel:NSPopUpMenuWindowLevel];
    
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[GrantAccess sharedInstance] stopAccessingToAll];
}

#pragma mark Capture

- (BOOL)createCaptureSession:(NSError **)outError
{
    /* Create a capture session. */
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
    {
        /* Specifies capture settings suitable for high quality video and audio output. */
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    /* Add the main display as a capture input. */
    display = CGMainDisplayID();
    self.captureScreenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:display];
    if ([self.captureSession canAddInput:self.captureScreenInput])
    {
        [self.captureSession addInput:self.captureScreenInput];
    }
    else
    {
        return NO;
    }
    
    /* Add a movie file output + delegate. */
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [captureMovieFileOutput setDelegate:self];
    if ([self.captureSession canAddOutput:captureMovieFileOutput])
    {
        [self.captureSession addOutput:captureMovieFileOutput];
    }
    else
    {
        return NO;
    }
    
    /* Register for notifications of errors during the capture session so we can display an alert. */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionRuntimeErrorDidOccur:) name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
    
    return YES;
}

- (void)captureSessionRuntimeErrorDidOccur:(NSNotification *)notification
{
    NSError *error = [notification userInfo][AVCaptureSessionErrorKey];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:[error localizedDescription]];
    NSString *informativeText = [error localizedRecoverySuggestion];
    informativeText = informativeText ? informativeText : [error localizedFailureReason]; // No recovery suggestion, then at least tell the user why it failed.
    [alert setInformativeText:informativeText];
    
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:NULL];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    // Do nothing
}
- (float)maximumScreenInputFramerate
{
    Float64 minimumVideoFrameInterval = CMTimeGetSeconds([self.captureScreenInput minFrameDuration]);
    return minimumVideoFrameInterval > 0.0f ? 1.0f/minimumVideoFrameInterval : 0.0;
}

/* Set the screen input maximum frame rate. */
- (void)setMaximumScreenInputFramerate:(float)maximumFramerate
{
    CMTime minimumFrameDuration = CMTimeMake(1, (int32_t)maximumFramerate);
    /* Set the screen input's minimum frame duration. */
    [self.captureScreenInput setMinFrameDuration:minimumFrameDuration];
}


-(void)addDisplayInputToCaptureSession:(CGDirectDisplayID)newDisplay cropRect:(CGRect)cropRect
{
    /* Indicates the start of a set of configuration changes to be made atomically. */
    [self.captureSession beginConfiguration];
    
    /* Is this display the current capture input? */
    if ( newDisplay != display )
    {
        /* Display is not the current input, so remove it. */
        [self.captureSession removeInput:self.captureScreenInput];
        AVCaptureScreenInput *newScreenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:newDisplay];
        
        self.captureScreenInput = newScreenInput;
        if ( [self.captureSession canAddInput:self.captureScreenInput] )
        {
            /* Add the new display capture input. */
            [self.captureSession addInput:self.captureScreenInput];
        }
        [self setMaximumScreenInputFramerate:[self maximumScreenInputFramerate]];
    }
    display = newDisplay;
    /* Set the bounding rectangle of the screen area to be captured, in pixels. */
    [self.captureScreenInput setCropRect:cropRect];
    
    /* Commits the configuration changes. */
    [self.captureSession commitConfiguration];
}
/* Informs the delegate when all pending data has been written to the output file. */
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    
    //   [[NSWorkspace sharedWorkspace] openURL:outputFileURL];
    
    NSLog(@"Did finish recording to %@ due to error %@", [outputFileURL description], [error description]);
    
    if([[_frameView getFormatText] isEqualToString:@"MPEG 4"]){
        
    }
    /*    else{
     [self ConvertMp4ToGif:mp4_fileURL];
     }
     */
}

- (NSURL *)inputMPEG4: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:[defaultValue substringToIndex:[defaultValue length]-4]];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        NSError * error;
        NSString * tempPath = finalMPEGPath;
        NSString * oldPath = [[tempPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:defaultValue];
        NSString * newPath = [[tempPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[input stringValue]]];
        NSURL * newURL = [NSURL fileURLWithPath:newPath];
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
        
        NSLog(@"%@", error);
        
        if (!error) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[newURL]];
            [self.frameView updateHistory];
        }
        
    } else if (button == NSAlertAlternateReturn) {
        [self.frameView updateHistory];
    } else {
        return nil;
    }
    return nil;
}

- (BOOL)captureOutputShouldProvideSampleAccurateRecordingStart:(AVCaptureOutput *)captureOutput
{
    // We don't require frame accurate start when we start a recording. If we answer YES, the capture output
    // applies outputSettings immediately when the session starts previewing, resulting in higher CPU usage
    // and shorter battery life.
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
}



- (IBAction)OnClickShow:(id)sender
{
    //    [[_statusMenu itemAtIndex:0] setEnabled:NO];
    //    [[_statusMenu itemAtIndex:1] setEnabled:YES];
    visible = true;
    [self setWindowPos];
    //   --------------show window----------------
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)setVisible:(bool)isVisible  {
    visible = isVisible;
}

- (IBAction)OnClickHide:(id)sender
{
    visible = false;
    [self.window orderOut:nil];
    //    [[NSApplication sharedApplication] hide:self];
    //    [[_statusMenu itemAtIndex:0] setEnabled:YES];
    //    [[_statusMenu itemAtIndex:1] setEnabled:NO];
    
}
- (IBAction)OnClickExit:(id)sender
{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults removeObjectForKey:@"StartatLogin"];
    
    [[NSApplication sharedApplication] terminate:self];
}

- (void)itemClicked:(id)sender {
    /*
     [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
     [[_statusMenu itemAtIndex:0] setEnabled:NO];
     [[_statusMenu itemAtIndex:1] setEnabled:YES];
     */
    if(self.is_recording){
        [self stopRecording];
        
        [self.frameView.btn_pause setHidden:YES];
        [self.frameView.btn_record setHidden:NO];
        [self performSelector:@selector(updateData:) withObject:nil afterDelay:2.0f];
        
        _statusItem.image = [NSImage imageNamed:@"icon record_x16.png"];
        
        return;
    }
    bool active_visible = [[NSApplication sharedApplication] isActive];
    if(!visible || !active_visible){
        [self OnClickShow:nil];
        timerPosAdjust = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(adjustIconPos) userInfo:self repeats:YES];
        
    }else{
        [self OnClickHide:nil];
        [timerPosAdjust invalidate];
        timerPosAdjust = nil;
        
    }
}

- (void)updateData:(id)sender    {
    if([[_frameView getFormatText] isEqualToString:@"MPEG 4"])
        [self inputMPEG4:@"Do you want to rename this file" defaultValue:fileName];
}

-(void) adjustIconPos
{
    NSWindow *panel = [self window];
    
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    
    NSWindow *window = [self window];
    [window setFrame:panelRect display:YES animate:YES];
    
    /*
     NSPoint pos;
     pos.x = [[NSScreen mainScreen] visibleFrame].origin.x + [[NSScreen mainScreen] visibleFrame].size.width - panelRect.size.width;
     pos.y = [[NSScreen mainScreen] visibleFrame].origin.y + [[NSScreen mainScreen] visibleFrame].size.height - panelRect.size.height;
     
     [window setFrameOrigin:pos];
     */
    
}
- (void)applicationDidResignActive:(NSNotification *)notification
{
    /*
     if (!self.is_recording){
     [self stopRecording];
     }
     */
    [timerPosAdjust invalidate];
    timerPosAdjust = nil;
}

/* Draws a crop rect on the display. */
- (void)drawMouseBoxView:(DrawMouseBoxView*)view didSelectRect:(NSRect)rect BackingScaleFactor:(float)scale
{
    /* Map point into global coordinates. */
    NSRect globalRect = rect;
    NSRect windowRect = [[view window] frame];
    globalRect = NSOffsetRect(globalRect, windowRect.origin.x, windowRect.origin.y);
    globalRect.origin.y = CGDisplayPixelsHigh(CGMainDisplayID()) - globalRect.origin.y;
    CGDirectDisplayID displayID = display;
    uint32_t matchingDisplayCount = 0;
    /* Get a list of online displays with bounds that include the specified point. */
    CGError e = CGGetDisplaysWithPoint(NSPointToCGPoint(globalRect.origin), 1, &displayID, &matchingDisplayCount);
    if ((e == kCGErrorSuccess) && (1 == matchingDisplayCount))
    {
        
        /* Add the display as a capture input. */
    }
    
    for (NSWindow* w in [NSApp windows])
    {
        if ([w level] == kShadyWindowLevel)
        {
            [w close];
        }
    }
    [[NSCursor currentCursor] pop];
    
    for(NSInteger i=[shadeWindows count]-1; i>=0; i--){
        NSWindow*temp = (NSWindow*)[shadeWindows objectAtIndex:i];
        if([temp level] != kRecordingShadyWindowLevel){
            [shadeWindows removeObjectAtIndex:i];
        }
    }
    self.is_recording = true;
    _statusItem.image = [NSImage imageNamed:@"icon_pause_menubar.png"];
    
    
    if([[_frameView getFormatText] isEqualToString:@"MPEG 4"]){
        cg_cropRect = NSRectToCGRect(rect);
        
        [self addDisplayInputToCaptureSession:displayID cropRect:cg_cropRect];
        [self startRecording];
    }else{
        cg_cropRect = CGRectMake(rect.origin.x,
                                 windowRect.size.height*scale - rect.origin.y - rect.size.height,
                                 rect.size.width,
                                 rect.size.height);
        
        display = displayID;
        [self startGeneratingGif];
    }
    
}

- (void)startGeneratingGif
{
    if(!self.is_recording){
        return;
    }
    
    [gifFrameArray removeAllObjects];
    
    [timerScanning invalidate];
    timerScanning = nil;
    timerScanning = [NSTimer scheduledTimerWithTimeInterval:1.0/FRAME_RATE target:self selector:@selector(addFrameToGif) userInfo:self repeats:YES];
    
    
}

- (NSImage *)scaleImage:(NSImage *)image
{
    CGSize format = [image size];
    float rate = format.width / 640.0;
    if(rate < format.height / 480.0){
        rate = format.height / 480.0;
    }
    format.width = format.width / rate;
    format.height = format.height / rate;
    
    NSImage *smallImage = [[NSImage alloc] initWithSize:format];
    [smallImage lockFocus];
    [image setSize: format];
    
    NSInteger level = [self.frameView getQualityLevel];
    if(level == 1){
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
    }else if(level == 2){
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationMedium];
    }else if(level == 3){
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    }
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, format.width, format.height) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    
    return smallImage;
}
-(void) stopMakingGif
{
    [timerScanning invalidate];
    timerScanning = nil;
    
    if([gifFrameArray count] == 0){
        return;
    }
    NSLog(@"Frame Count : %lu",(unsigned long)[gifFrameArray count]);
    
    [self input:@"Do you want to rename this file?" defaultValue:[self captureTemporaryFilePath]];
    
}

- (void)makeGIF:(NSURL *)fileUrl {
    dispatch_queue_t queue = dispatch_queue_create("com.ziofrtiz.exporter", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileUrl,
                                                                            kUTTypeGIF,
                                                                            [gifFrameArray count],
                                                                            NULL);
        
        float frameLength = 1.0/FRAME_RATE;
        
        NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFDelayTime : @(frameLength)}};
        
        
        NSImage *image;
        //        NSSize imgSize;
        
        for(NSInteger i = 0 ; i<[gifFrameArray count]; i++){
            image = [gifFrameArray objectAtIndex:i];
            /*
             if(i == 0){
             imgSize = [image size];
             }
             if(imgSize.width * imgSize.height > 640*480){
             image = [self scaleImage:image];
             }
             */
            
            NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
            NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:10.0] forKey:NSImageCompressionFactor];
            NSData *compressedData = [imageRep representationUsingType:NSJPEGFileType properties:options];
            CFDataRef data = (__bridge CFDataRef)compressedData;
            
            
            //   CFDataRef data = (__bridge CFDataRef)[image TIFFRepresentation];
            CGImageSourceRef source = CGImageSourceCreateWithData(data, NULL);
            CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)frameProperties);
            
            CFRelease(source);
        }
        
        NSDictionary *gifProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFLoopCount : @0}};
        
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        [gifFrameArray removeAllObjects];
        [self.frameView updateHistory];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileUrl]];
        
    });
}

- (NSURL *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:[defaultValue substringToIndex:[defaultValue length]-4]];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        NSString * oldPath = [self getSaveLocation];
        NSString * newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",[input stringValue]]];
        
        [self makeGIF:[NSURL fileURLWithPath:newPath]];
        return nil;
    } else if (button == NSAlertAlternateReturn) {
        NSString * newPath = [[[self getSaveLocation] stringByDeletingLastPathComponent] stringByAppendingPathComponent:defaultValue];
        [self makeGIF:[NSURL fileURLWithPath:newPath]];
        return nil;
    } else {
        return nil;
    }
    return nil;
}

- (void) addFrameToGif
{
    if(!self.is_recording){
        if([gifFrameArray count] != 0){
            [timerScanning invalidate];
            timerScanning = nil;
            return;
        }
    }
    
    CGImageRef dispCGImage = CGDisplayCreateImage(display);
    CGImageRef dispCroppedCGImage = CGImageCreateWithImageInRect(dispCGImage, cg_cropRect);
    CGImageRelease(dispCGImage);
    
    NSImage *image = [[NSImage alloc] initWithCGImage:dispCroppedCGImage size:NSZeroSize];
    [gifFrameArray addObject:image];
    CGImageRelease(dispCroppedCGImage);
    
}

- (void)setDisplayAndCropRect
{
    
    if(!shadeWindows) {
        shadeWindows = [NSMutableArray array];
    }
    
    for (NSScreen* screen in [NSScreen screens])
    {
        float dispScale=[screen backingScaleFactor];
        
        NSRect frame = [screen frame];
        BorderlessWindow * window = [[BorderlessWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
        [window setBackgroundColor:[NSColor blackColor]];
        [window setAlphaValue:.5];
        [window setLevel:kShadyWindowLevel];
        [window setReleasedWhenClosed:NO];
        [window setOpaque:YES];
        
        DrawMouseBoxView* drawMouseBoxView = [[DrawMouseBoxView alloc] initWithFrame:frame];
        drawMouseBoxView.delegate = self;
        [drawMouseBoxView setBackingScaleFactorValue:dispScale];
        [window makeFirstResponder:drawMouseBoxView];
        [window setContentView:drawMouseBoxView];
        [window makeKeyAndOrderFront:self];
        [shadeWindows addObject:window];
    }
}
-(NSString*) getSaveLocation
{
    NSString *savePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SavePath"];
    if( savePath == nil )
        savePath = [[Helper realHomeDirectory] stringByAppendingPathComponent:@"Movies"];
//
    NSString * tempFileName = [self captureTemporaryFilePath];
    NSString *filePath = [savePath stringByAppendingPathComponent:tempFileName];
//
    
    // Delete any existing movie file first
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFileName])
    {
        NSError *err;
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&err])
        {
            NSLog(@"Error deleting existing movie %@",[err localizedDescription]);
        }
    }
    NSLog(@"Recording to: %@",filePath);
    
    return filePath;

//    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
//    
//    return  fileUrl;
   
}
- (void)startRecording
{
    
    switch ([_frameView getQualityLevel]) {
        case 1:
            self.captureSession.sessionPreset = AVCaptureSessionPreset320x240;
            break;
        case 2:
            self.captureSession.sessionPreset = AVCaptureSessionPreset352x288;
            break;
        case 3:
            self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
            break;
        case 4:
            self.captureSession.sessionPreset = AVCaptureSessionPreset960x540;
            break;
        case 5:
            self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
            break;
        default:
            break;
    }
    
    NSString *filepath = [self getSaveLocation];
    finalMPEGPath = filepath;
    [captureMovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filepath] recordingDelegate:self];
}

/* Called when the user presses the 'Stop' button to stop a recording. */
- (void)stopRecording
{
    for (NSWindow* w in [NSApp windows])
    {
        if ([w level] == kRecordingShadyWindowLevel)
        {
            [w close];
        }
    }
    [shadeWindows removeAllObjects];
    
    self.is_recording= false;
    if([[_frameView getFormatText] isEqualToString:@"MPEG 4"]){
        [captureMovieFileOutput stopRecording];
        mp4_fileURL = captureMovieFileOutput.outputFileURL;
     }else{
        [self stopMakingGif];
    }
    [self performSelector:@selector(savingStopped) withObject:nil afterDelay:4];

}

- (void)savingStopped
{
    NSString * filepath = finalMPEGPath;
    if (finalMPEGPath == nil) {
        filepath = [self getSaveLocation];
    }
}

#pragma mark Private helpers

- (NSString*)captureTemporaryFilePath
{
    static NSDateFormatter* dateFormatter = nil;
    static NSDateFormatter* timeFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    if (timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
    }
    
    NSDate* now = [NSDate date];
    NSString* date = [dateFormatter stringFromDate:now];
    NSString* time = [timeFormatter stringFromDate:now];
    
    if([[_frameView getFormatText] isEqualToString:@"MPEG 4"]){
        fileName = [NSString stringWithFormat:@"%@ %@.%@",  date, time, @"mp4"];
    }else{
        fileName = [NSString stringWithFormat:@"%@ %@.%@",  date, time, @"gif"];
    }
    return fileName;
}

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    if (_statusItem)
    {
        statusRect = [[_statusItem valueForKey:@"window"] frame];
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}
-(void) setWindowPos
{
    NSWindow *panel = [self window];
    
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    //-------------Set Window Pos ----------------------
    //    NSWindow *window = [self window];
    //    [window setFrame:panelRect display:YES animate:YES];
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
}
- (GifExporter *)defaultExporterWithLazyCollection:(AbstractLazyCollection *)lazyCollection
{
    GifExporter *exporter = [[GifExporter alloc] initWithImagesEnumerator:lazyCollection];
    exporter.delegate = self;
    exporter.frameRate = 10;
    
    return exporter;
}
- (void) ConvertMp4ToGif:(NSURL*) url
{
    AbstractLazyCollection *images = [[VideoLazyCollection alloc] initWithVideoURL:url framesPerSecond:10];
    if (!images) {
        return;
    }
    GifExporter *currentExporter =  [[GifExporter alloc] init];
    [currentExporter cancel];
    currentExporter = [self defaultExporterWithLazyCollection:images];
    
    NSString* mp4_filename = [url path];
    NSString* temp_path = [mp4_filename substringToIndex:[mp4_filename length]-4];
    NSString *gif_fileName = [NSString stringWithFormat:@"%@.gif", temp_path];
    NSURL *saveURL = [NSURL fileURLWithPath:gif_fileName];
    
    currentExporter.saveLocation = saveURL;
    [currentExporter execute];
}
#pragma mark - exporter∫

- (void)gifExporter:(GifExporter *)exporter processedImage:(NSImage *)image index:(NSUInteger)index outOfTotal:(NSUInteger)total
{
    
}

- (void)gifExporterFinished:(GifExporter *)exporter
{
    NSError *err=nil;
  	 
    
    NSString *gif_path = [exporter.saveLocation path];
    NSString* temp_path = [gif_path substringToIndex:[gif_path length]-4];
    NSString *mp4_fileName = [NSString stringWithFormat:@"%@.mp4", temp_path];
    
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:mp4_fileName] error:&err];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:gif_path]){
        NSAlert*alert=[NSAlert alertWithMessageText:@"File conversion to GIF Image Failed" defaultButton:@"Ok" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Error!"];
        [alert runModal];
    }else{
        [[NSWorkspace sharedWorkspace] openURL:exporter.saveLocation];
    }
}

- (void)gifExporterIsProcessing:(GifExporter *)exporter
{
}
@end
