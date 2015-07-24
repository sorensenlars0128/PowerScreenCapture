//
//  ImageDiscover.h
//  Giffy
//
//  Created by Francesco Frison on 03/11/2014.
//  Copyright (c) 2014 Ziofrtiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractLazyCollection.h"

@interface FolderLazyCollection : AbstractLazyCollection
- (instancetype)initWithFolderURL:(NSURL *)url;

@end
