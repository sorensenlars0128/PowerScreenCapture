//
//  GifExporter.h
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AbstractLazyCollection;
@protocol GifExporterDelegate;

@interface GifExporter : NSObject

@property (nonatomic, strong, readonly) AbstractLazyCollection *imagesEnumerator;
@property (nonatomic, strong) NSURL *imagesLocation;
@property (nonatomic, assign) NSUInteger frameRate;
@property (nonatomic, strong) NSURL *saveLocation;
@property (nonatomic, assign) CGSize format;
@property (nonatomic, assign, readonly) BOOL isExecuting;

@property (nonatomic, assign) id<GifExporterDelegate> delegate;


- (instancetype)initWithImagesEnumerator:(AbstractLazyCollection *)enumerator;
- (CGSize)originalFormat;

- (void)execute;
- (void)cancel;

@end


@protocol GifExporterDelegate <NSObject>

- (void)gifExporter:(GifExporter *)exporter processedImage:(NSImage *)image index:(NSUInteger)index outOfTotal:(NSUInteger)total;
- (void)gifExporterIsProcessing:(GifExporter *)exporter;
- (void)gifExporterFinished:(GifExporter *)exporter;

@end