//
//  GiffyEnumerator.h
//  Giffy
//
//  Created by Francesco Frison on 04/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractLazyCollection : NSEnumerator
@property (nonatomic, assign) CGSize format;
@property (nonatomic, assign) NSUInteger count;

@end
