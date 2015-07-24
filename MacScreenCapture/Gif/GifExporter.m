//
//  GifExporter.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "GifExporter.h"
#import "AbstractLazyCollection.h"
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>

@interface GifExporter ()

@property (nonatomic, strong, readwrite) AbstractLazyCollection *imagesEnumerator;
@property (nonatomic, assign, readwrite) BOOL isExecuting;
@property (nonatomic, assign) BOOL isCancelled;

@end

@implementation GifExporter


- (instancetype)initWithImagesEnumerator:(AbstractLazyCollection *)enumerator
{
    self = [self init];
    if (self) {
        self.imagesEnumerator = enumerator;
    }
    
    return self;
}

- (float)frameLength
{
    float rate = (self.frameRate)? (float) self.frameRate : 12.0;
    
    return 1.0 / rate;
}

- (CGSize)format
{
    if (_format.width <= 0.0 || _format.height <= 0.0) {
        _format = self.originalFormat;
    }
    
    return _format;
}

- (CGSize)originalFormat
{
    return [self.imagesEnumerator format];
}



- (void)execute
{
    
    if (self.isExecuting) {
        return;
    }
    self.isExecuting = YES;
    self.isCancelled = NO;
    
    dispatch_queue_t queue = dispatch_queue_create("com.ziofrtiz.exporter", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSUInteger total = self.imagesEnumerator.count;
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)self.saveLocation,
                                                                            kUTTypeGIF,
                                                                            total,
                                                                            NULL);
        NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFDelayTime : @([self frameLength])}};
        NSDictionary *gifProperties = @{(NSString *)kCGImagePropertyGIFDictionary : @{(NSString *)kCGImagePropertyGIFLoopCount : @0}};
        
        
        NSImage *image;
        NSUInteger index = 0;
        
        while (image = (NSImage *)[self.imagesEnumerator nextObject]) {
            if (self.isCancelled) {
                break;
            }
            
            
            image = [self scaleImage:image];
            
            CFDataRef data = (__bridge CFDataRef)[image TIFFRepresentation];
            
            CGImageSourceRef source = CGImageSourceCreateWithData(data, NULL);
            CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CGImageDestinationAddImage(destination, maskRef, (__bridge CFDictionaryRef)frameProperties);
            
            CFRelease(source);
            CFRelease(maskRef);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(gifExporter:processedImage:index:outOfTotal:)]) {
                    [self.delegate gifExporter:self processedImage:image index:index outOfTotal:total];
                }
            });
            
            index++;
        }
        
        self.imagesEnumerator = nil;
        
        if (self.isCancelled) {
            return;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(gifExporterIsProcessing:)]) {
                [self.delegate gifExporterIsProcessing:self];
            }
        });
        
        
        
        CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(gifExporterFinished:)]) {
                [self.delegate gifExporterFinished:self];
            }
        });
    });
}

- (void)cancel
{
    self.isCancelled = YES;
}

- (NSImage *)scaleImage:(NSImage *)image
{
    NSImage *smallImage = [[NSImage alloc] initWithSize:self.format];
    [smallImage lockFocus];
    [image setSize: self.format];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, self.format.width, self.format.height) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    
    return smallImage;
}


@end
