//
//  GrantAccess.h
//  Duplicate Photo Cleaner
//
//  Created by Ditriol Wei on 9/7/15.
//  Copyright (c) 2015 Computer House. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrantAccess : NSObject

+ (GrantAccess *)sharedInstance;

- (BOOL)startAccessingToPath:(NSString *)path;
- (void)stopAccessingToPath:(NSString *)path;
- (void)stopAccessingToAll;
@end
