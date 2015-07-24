
#import "LaunchAtLoginController.h"


// This code were added by ss at 15/7/15 for autoLaunchHelper
#import <ServiceManagement/ServiceManagement.h>
#define helperAppBundleIdentifier @"com.gao.launchHelper" // added by ss at 15/07/15

//



static NSString *const StartAtLoginKey = @"launchAtLogin";

@interface LaunchAtLoginController ()
@property(assign) LSSharedFileListRef loginItems;
@end

@implementation LaunchAtLoginController
@synthesize loginItems;

#pragma mark Change Observing


void sharedFileListDidChange(LSSharedFileListRef inList, void *context)
{
    LaunchAtLoginController *self = (__bridge id) context;
    [self willChangeValueForKey:StartAtLoginKey];
    [self didChangeValueForKey:StartAtLoginKey];
}

#pragma mark Initialization

- (id) init
{
    self = [super init];
    loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListAddObserver(loginItems, CFRunLoopGetMain(),
        (CFStringRef)NSDefaultRunLoopMode, sharedFileListDidChange, (__bridge void *)(self));
    return self;
}

- (void) dealloc
{
    LSSharedFileListRemoveObserver(loginItems, CFRunLoopGetMain(),
        (CFStringRef)NSDefaultRunLoopMode, sharedFileListDidChange, (__bridge void *)(self));
    CFRelease(loginItems);
}

#pragma mark Launch List Control

- (LSSharedFileListItemRef) findItemWithURL: (NSURL*) wantedURL inFileList: (LSSharedFileListRef) fileList
{
    if (wantedURL == NULL || fileList == NULL)
        return NULL;
    UInt32 seed;
    
    NSArray *listSnapshot = (__bridge NSArray *)LSSharedFileListCopySnapshot(fileList,
                                                                    &seed);
    for (id itemObject in listSnapshot) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef) itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        if (currentItemURL && CFEqual(currentItemURL, (__bridge CFTypeRef)(wantedURL))) {
            CFRelease(currentItemURL);
            return item;
        }
        if (currentItemURL)
            CFRelease(currentItemURL);
    }

    return NULL;
}

- (BOOL) willLaunchAtLogin: (NSURL*) itemURL
{
    return !![self findItemWithURL:itemURL inFileList:loginItems];
}

- (void) setLaunchAtLogin: (BOOL) enabled forURL: (NSURL*) itemURL
{
//    LSSharedFileListItemRef appItem = [self findItemWithURL:itemURL inFileList:loginItems];
//    if (enabled && !appItem) {
//       
//        
//        LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
//            NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
//    }
//    else if (!enabled && appItem)
//    {
//        
//    }
//        LSSharedFileListItemRemove(loginItems, appItem);
    
    // added by ss at 15/07/15
    if (enabled)
    {
        if( !SMLoginItemSetEnabled ((__bridge CFStringRef)helperAppBundleIdentifier, YES) )
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't add Helper App to launch at login item list."];
            [alert runModal];
        }
    }
    else
    {
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)helperAppBundleIdentifier, NO)) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Couldn't remove Helper App from launch at login item list."];
            [alert runModal];
        }
    }
    //

}

#pragma mark Basic Interface

- (NSURL*) appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void) setLaunchAtLogin: (BOOL) enabled
{
    [self willChangeValueForKey:StartAtLoginKey];
    [self setLaunchAtLogin:enabled forURL:[self appURL]];
    [self didChangeValueForKey:StartAtLoginKey];
}

- (BOOL) launchAtLogin
{
    return [self willLaunchAtLogin:[self appURL]];
}

@end
