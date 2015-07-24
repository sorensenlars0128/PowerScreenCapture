//
//  VideoExtractor.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "VideoLazyCollection.h"
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoLazyCollection ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) CMTime currentTime;
@property (nonatomic, assign) CMTime progressTime;

@end


@implementation VideoLazyCollection

- (instancetype)initWithVideoURL:(NSURL *)url
{
    return [self initWithVideoURL:url framesPerSecond:24];
}

- (instancetype)initWithVideoURL:(NSURL *)url framesPerSecond:(NSUInteger)frames
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    if (![[self class] isAssetPlayable:asset]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;

        CMTimeScale timescale  = asset.duration.timescale;
        NSInteger samplesPerFrame = timescale / frames;
        
        self.progressTime = CMTimeMake(samplesPerFrame, timescale);
        self.currentTime = CMTimeMake(0, timescale);
        
        self.count = (NSUInteger)(CMTimeGetSeconds(asset.duration) / CMTimeGetSeconds(self.progressTime));
        self.format = [[self imageAtTime:self.currentTime] size];
        self.index = 0;
    }
    
    return self;
}

+ (BOOL)isAssetPlayable:(AVURLAsset *)asset
{
    // Don't know another way to do this.
    NSArray *extensions = @[@"mov", @"m4v", @"avi", @"mpeg", @"mp4", @"dv", @"quicktime"];
    return [extensions containsObject:asset.URL.pathExtension];
}

- (NSImage *)imageAtTime:(CMTime)time
{
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef imgRef = [self.imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    NSImage *image = [[NSImage alloc] initWithCGImage:imgRef size:NSZeroSize];
    CGImageRelease(imgRef);
    
    if (error || time.value != actualTime.value) {
        NSLog(@"Error: %@ [%lld | %lld]", error.debugDescription, time.value, actualTime.value);
    }
    
    return image;
}

- (id)nextObject
{
    
    if (self.index >= self.count) {
        return nil;
    }
    self.index++;
    
    NSImage *image = [self imageAtTime:self.currentTime];
    self.currentTime = CMTimeAdd(self.currentTime, self.progressTime);
    
    return image;
}


@end
