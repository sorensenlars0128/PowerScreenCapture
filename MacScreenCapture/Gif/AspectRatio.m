//
//  AspectRatio.m
//  Giffy
//
//  Created by Francesco Frison on 06/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "AspectRatio.h"

@implementation AspectRatio


+ (instancetype)aspectRatioWithSize:(NSSize)size
{
    AspectRatio *ratio = [[AspectRatio alloc] init];
    ratio.size = size;
    
    return ratio;
}

- (NSString *)stringValue
{
    return [NSString stringWithFormat:@"%.0fx%0.f", self.size.width, self.size.height];
}

#pragma equality


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[self class]]) {
        return NO;
    } else {
        return NSEqualSizes(self.size, [other size]);
    }
}

- (NSUInteger)hash
{
    return (int)self.size.width | (int)self.size.height;
}


+ (NSArray *)allAspectRatiosFromSize:(NSSize)size
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSInteger divider = 1;
    
    while (divider < 5) {
        NSInteger w = (NSInteger)(size.width / divider);
        NSInteger h = (NSInteger)(size.height / divider);
        AspectRatio *ratio = [AspectRatio aspectRatioWithSize:NSMakeSize(w, h)];
        [array addObject:ratio];
        
        divider++;
    }
    
    return [array copy];

}

@end
