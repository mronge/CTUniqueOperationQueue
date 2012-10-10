//
//  CTUniqueOperationQueue.m
//  CTUniqueOperationQueue
//
//  Created by Matt Ronge on 10/9/12.
//  Copyright (c) 2012 Central Atomics. All rights reserved.
//

#import "CTUniqueOperationQueue.h"

@implementation CTUniqueOperationQueue {
    NSMutableDictionary *idToOp;
}

- (id)init {
    self = [super init];
    if (self) {
        idToOp = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addOperation:(NSOperation *)op withID:(NSString *)aID {
    NSString *anIdCopy = [aID copy];
    
    void (^realCompletionBlock)() = op.completionBlock;
    op.completionBlock = ^{
        @synchronized(self) {
            [idToOp removeObjectForKey:anIdCopy];
        }
        if (realCompletionBlock) {
            realCompletionBlock();
        }
    };
    
    @synchronized(self) {
        if (![idToOp objectForKey:aID]) {
            [idToOp setValue:op forKey:anIdCopy];
            
            [super addOperation:op];
        }
    }
}

- (void)addOperationWithBlock:(void (^)(void))block withID:(NSString *)aID {
    [self addOperation:[NSBlockOperation blockOperationWithBlock:block] withID:aID];
}

//TODO: try nil
- (void)cancelOperationWithID:(NSString *)anID {
    @synchronized(self) {
        NSOperation *op = [idToOp objectForKey:anID];
        [op cancel];
    }
}

@end
