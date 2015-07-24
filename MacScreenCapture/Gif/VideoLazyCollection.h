//
//  VideoExtractor.h
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractLazyCollection.h"

@interface VideoLazyCollection : AbstractLazyCollection

- (instancetype)initWithVideoURL:(NSURL *)url;
- (instancetype)initWithVideoURL:(NSURL *)url framesPerSecond:(NSUInteger)frames;

@end
