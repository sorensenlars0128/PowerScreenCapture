//
//  NSURL+FileAccess.m
//  Duplicate Photo Cleaner
//
//  Created by Ditriol Wei on 27/5/15.

#import "NSURL+FileAccess.h"

@interface RootSelectOpenPanelDelegate : NSObject<NSOpenSavePanelDelegate>
- (id)initWithFileURL:(NSURL *)fileUrl;
@end

@implementation NSURL (FileAccess)

- (NSString *)bookmarkDataKey
{
    return [NSString stringWithFormat:@"bm_acess:%@", [self absoluteString]];
}

- (void)setBookmarkData
{
    NSError * error = nil;
    NSData *bookmarkData = [self bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                          includingResourceValuesForKeys:nil
                                           relativeToURL:nil
                                                   error:&error];
    if( error != nil || bookmarkData == nil )
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:bookmarkData forKey:[self bookmarkDataKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeBookmarkData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self bookmarkDataKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData *)bookmarkData
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self bookmarkDataKey]];
}

- (NSURL *)URLByResolvingBookmarkData
{
    NSData * bookmarkData = [self bookmarkData];
    if( bookmarkData == nil )
    {
        RootSelectOpenPanelDelegate * openPanelDelegate = [[RootSelectOpenPanelDelegate alloc] initWithFileURL:self];
#if !__has_feature(objc_arc)
        [openPanelDelegate autorelease];
#endif
        
        dispatch_block_t displayOpenPanelBlock = ^{
            NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            [openPanel setMessage:@"The app needs to access this location to scan for. Click Allow to continue."];
            [openPanel setCanCreateDirectories:NO];
            [openPanel setCanChooseFiles:YES];
            [openPanel setCanChooseDirectories:YES];
            [openPanel setAllowsMultipleSelection:NO];
            [openPanel setPrompt:@"Allow"];
            [openPanel setTitle:@"Allow access"];
            [openPanel setShowsHiddenFiles:NO];
            [openPanel setExtensionHidden:NO];
            [openPanel setDirectoryURL:self];
            [openPanel setDelegate:openPanelDelegate];
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            NSInteger openPanelButtonPressed = [openPanel runModal];
            if( openPanelButtonPressed == NSFileHandlingPanelOKButton )
            {
                [self setBookmarkData];
            }
        };
        
        if ([NSThread isMainThread]) {
            displayOpenPanelBlock();
        } else {
            dispatch_sync(dispatch_get_main_queue(), displayOpenPanelBlock);
        }
    }

    bookmarkData = [self bookmarkData];
    if( bookmarkData == nil )
        return nil;
    
    return [NSURL URLByResolvingBookmarkData:bookmarkData
                                     options:NSURLBookmarkResolutionWithSecurityScope
                               relativeToURL:nil
                         bookmarkDataIsStale:nil
                                       error:nil];
}

- (BOOL)startAccessing
{
    NSURL * allowedURL = [self URLByResolvingBookmarkData];
    if( allowedURL != nil )
    {
        return [[self URLByResolvingBookmarkData] startAccessingSecurityScopedResource];
    }
    
    return NO;
}

- (void)stopAccessing
{
    [[self URLByResolvingBookmarkData] stopAccessingSecurityScopedResource];
}

@end


@interface RootSelectOpenPanelDelegate ()

@property (retain) NSURL *url;
@property (retain) NSArray *urlPath;

@end

@implementation RootSelectOpenPanelDelegate

- (id)initWithFileURL:(NSURL *)fileUrl {
    self = [super init];
    if (self) {
        self.url = fileUrl;
        self.urlPath = [self.url pathComponents];
    }
    return self;
}

#pragma mark -- NSOpenSavePanelDelegate

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSArray *urlPath = [url pathComponents];
    
    // if the url passed in has more components, it could not be a parent path or a exact same path
    if (urlPath.count > self.urlPath.count) {
        return NO;
    }
    
    // check that each path component in url, is the same as each corresponding component in self.url
    for (int i = 0; i < urlPath.count; ++i) {
        NSString *comp1 = urlPath[i];
        NSString *comp2 = self.urlPath[i];
        // not the same, therefore url is not a parent or exact match to self.url
        if (![comp1 isEqualToString:comp2]) {
            return NO;
        }
    }
    
    // there were no mismatches (or no components meaning url is root)
    return YES;
}

@end
