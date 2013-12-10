/*
 * CTUniqueOperationQueue
 *
 * Copyright (C) 2012 - Matt Ronge
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of Central Atomics Inc. nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

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
    if (![aID length])
    {
        return;
    }
    if (!op)
    {
        return;
    }
    NSString *anIdCopy = [aID copy];
    __weak NSOperation *weakOp = op;

    void (^realCompletionBlock)() = op.completionBlock;
    op.completionBlock = ^{
        @synchronized(self) {
            // Make sure we are removing the right object, because
            // if the op was cancelled and it was replaced, we
            // don't want to remove the op that replaced it
            NSOperation *opInQueue = [idToOp objectForKey:aID];
            if (weakOp == opInQueue) {
                [idToOp removeObjectForKey:anIdCopy];
            }
        }
        if (realCompletionBlock) {
            realCompletionBlock();
        }
    };

    @synchronized(self) {
        NSOperation *opInQueue = [idToOp objectForKey:aID];

        // If the op isn't already in the queue or if there is one in the queue
        // but it is cancelled, we'll let another one in.
        if (!opInQueue || opInQueue.isCancelled) {
            [idToOp setValue:op forKey:anIdCopy];

            [super addOperation:op];
        }
    }
}

- (void)addOperationWithBlock:(void (^)(void))block withID:(NSString *)aID {
    [self addOperation:[NSBlockOperation blockOperationWithBlock:block] withID:aID];
}

- (void)cancelOperationWithID:(NSString *)anID {
    @synchronized(self) {
        NSOperation *op = [idToOp objectForKey:anID];
        [op cancel];
    }
}

- (NSOperation *)operationWithID:(NSString *)anID {
    @synchronized(self) {
        NSOperation *op = [idToOp objectForKey:anID];
        return op;
    }
}

- (void)addOrSetQueuePriority:(NSOperationQueuePriority)priority operation:(NSOperation *)op withID:(NSString *)anID {
    @synchronized(self) {
        NSOperation *existingOperation = [idToOp objectForKey:anID];
        if (existingOperation) {
            if ([existingOperation isExecuting]) {
                // do nothing, too late to change priority
            }
            else if (existingOperation.queuePriority == priority) {
                // do nothing, priority has not changed
            }
            else {
                // http://developer.apple.com/library/mac/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW38 says to never modify an operation once placed in a queue, so if it has not yet started, cancel and add the same operation but with a new priority.
                [existingOperation cancel];
                [op setQueuePriority:priority];
                [self addOperation:op withID:anID];
            }
        }
        else {
            [op setQueuePriority:priority];
            [self addOperation:op withID:anID];
        }
    }
}

@end
