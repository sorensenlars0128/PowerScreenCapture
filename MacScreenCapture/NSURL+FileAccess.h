//
//  NSURL+FileAccess.h
//  Duplicate Photo Cleaner
//
//  Created by Ditriol Wei on 27/5/15.

#import <Foundation/Foundation.h>

@interface NSURL (FileAccess)

- (BOOL)startAccessing;
- (void)stopAccessing;

- (void)setBookmarkData;
- (void)removeBookmarkData;

@end
