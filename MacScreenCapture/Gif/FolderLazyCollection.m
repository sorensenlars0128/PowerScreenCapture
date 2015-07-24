//
//  ImageDiscover.m
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import "FolderLazyCollection.h"
#import <AppKit/AppKit.h>

@interface FolderLazyCollection ()

@property (nonatomic, strong) NSEnumerator *urlEnumerator;

@end

@implementation FolderLazyCollection


- (instancetype)initWithFolderURL:(NSURL *)url
{
    
    BOOL isDirectory = NO;
    BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
    if (!dirExists || !isDirectory) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        NSArray *urls = [self URLsWithinURL:url];
        self.urlEnumerator = [urls objectEnumerator];
        
        self.count = urls.count;
        NSURL *url = (NSURL *)[urls firstObject];
        if (url) {
            self.format = [[[NSImage alloc] initWithContentsOfURL:url] size];
        }
    }
    
    return self;
}

- (NSArray *)URLsWithinURL:(NSURL *)url
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:0 errorHandler:nil];
    if (!enumerator) {
        return nil;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    id object;
    while (object = [enumerator nextObject]) {
        NSNumber *key = [self numberAtURL:(NSURL *)object];
        if (key) {
            dictionary[key] = object;
        }
    }
    
    NSArray *keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *mutableUrls = [NSMutableArray array];
    [keys enumerateObjectsUsingBlock:^(NSNumber *key, NSUInteger idx, BOOL *stop) {
        [mutableUrls addObject:dictionary[key]];
    }];
    
    return [mutableUrls copy];
}

- (NSNumber *)numberAtURL:(NSURL *)url
{
    
    static NSRegularExpression *regEx;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       regEx = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)" options:0 error:nil];
    });
    
    NSString *urlString = [[url absoluteString] lastPathComponent];
    
    NSTextCheckingResult *result = [regEx firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    if (result && [result numberOfRanges] > 0) {
        NSString *stringInRange = [urlString substringWithRange:[result rangeAtIndex:0]];
        return @([stringInRange integerValue]);
    }
    else {
        return nil;
    }
}

- (id)nextObject
{
    NSURL *url = (NSURL *)[self.urlEnumerator nextObject];
    if (url) {
        return [[NSImage alloc] initWithContentsOfURL:url];
    }
    
    return nil;
}

@end
