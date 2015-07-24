//
//  AspectRatio.h
//  Giffy
//
//  Created by Francesco Frison on 06/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AspectRatio : NSObject

@property (nonatomic, assign) NSSize size;
@property (nonatomic, strong, readonly) NSString *stringValue;

+ (instancetype)aspectRatioWithSize:(NSSize)size;


// factory
+ (NSArray *)allAspectRatiosFromSize:(NSSize)size;

@end
