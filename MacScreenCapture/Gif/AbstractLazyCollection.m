//
//  GiffyEnumerator.m
//  Giffy
//
//  Created by Francesco Frison on 04/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "AbstractLazyCollection.h"

@interface AbstractLazyCollection ()

@end

@implementation AbstractLazyCollection

- (NSArray *)allObjects
{
    NSAssert(NO, @"This should never be called");
    return nil;
}

- (id)nextObject
{
    NSAssert(NO, @"This should have been implemented by subclass");
    return nil;
}

@end
