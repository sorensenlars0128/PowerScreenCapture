//
//  GrantAccess.m
//  Duplicate Photo Cleaner
//
//  Created by Ditriol Wei on 9/7/15.
//  Copyright (c) 2015 Computer House. All rights reserved.
//

#import "GrantAccess.h"
#import "NSURL+FileAccess.h"
#import <pwd.h>

@interface GrantAccess ()
@property (strong, nonatomic) NSMutableDictionary * accessTable;
@end

@implementation GrantAccess

+ (GrantAccess *)sharedInstance
{
    static dispatch_once_t onceToken;
    static GrantAccess * grantAcessSharedInstance;
    
    dispatch_once(&onceToken, ^{
        grantAcessSharedInstance = [[GrantAccess alloc] init];
    });
    return grantAcessSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if( self != nil )
    {
        self.accessTable = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (BOOL)startAccessingToPath:(NSString *)path
{
    struct passwd * pw;
    if( (pw = getpwuid( getuid() )) == NULL )
        return NO;
    NSString * homeDir = [NSString stringWithUTF8String:pw->pw_dir];
    NSString * moveDir = [homeDir stringByAppendingPathComponent:@"Movies"];
    if( [moveDir isEqualToString:path] )
        return YES;
    
    if( path == nil )
        return NO;
    if( [self.accessTable objectForKey:path] != nil )
        return YES;
    
    BOOL b = [[NSURL fileURLWithPath:path] startAccessing];
    if( b )
        [self.accessTable setObject:[NSNumber numberWithInteger:1] forKey:path];
    return b;
}

- (void)stopAccessingToPath:(NSString *)path
{
    if( path == nil || [self.accessTable objectForKey:path] == nil )
        return;
    
    [self.accessTable removeObjectForKey:path];
    [[NSURL fileURLWithPath:path] stopAccessing];    
}

- (void)stopAccessingToAll
{
    for( NSString * path in [self.accessTable allKeys] )
        [[NSURL fileURLWithPath:path] stopAccessing];
    
    [self.accessTable removeAllObjects];
}

@end
