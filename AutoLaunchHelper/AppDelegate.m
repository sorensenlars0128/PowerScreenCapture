//
//  AppDelegate.m
//  AutoLaunchHelper
//
//  Created by SS on 7/15/15.
//  Copyright (c) 2015 ___MrtDevTeam___. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

#define mainAppBundleIdentifier @"com.gao.powerscreencapture"
#define mainAppName @"PowerScreenCapture"
#define terminateNotification @"TERMINATEHELPER"

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // If yes, do nothing and terminate helper app
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:mainAppBundleIdentifier]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning)
    {
        // Register Observer
        // So that main app can later notify helper to terminate
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(killApp)
                                                                name:terminateNotification // Can be any string, but shouldn't be nil
                                                              object:mainAppBundleIdentifier];
        
        // Launch main app
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:mainAppName];
        NSString *mainAppPath = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication:mainAppPath];
    }
    [self killApp];
}

-(void)killApp
{
    [NSApp terminate:nil];
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
