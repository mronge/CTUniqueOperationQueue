//
//  CTUniqueOperationQueue.h
//  CTUniqueOperationQueue
//
//  Created by Matt Ronge on 10/9/12.
//  Copyright (c) 2012 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTUniqueOperationQueue : NSOperationQueue
- (void)addOperation:(NSOperation *)op withID:(NSString *)aID;
- (void)addOperationWithBlock:(void (^)(void))block withID:(NSString *)aID;
- (void)cancelOperationWithID:(NSString *)anID;
@end
