//
//  main.m
//  CTUniqueOperationQueueTests
//
//  Created by Matt Ronge on 10/9/12.
//  Copyright (c) 2012 Central Atomics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTUniqueOperationQueue.h"

@interface SlowOp : NSOperation
@end

@implementation SlowOp
- (void)main {
    NSLog(@"I'm sleepy zzzzzzzz........");
    sleep(2);
    NSLog(@"Done sleeping!");
}
@end

@interface TestOp : NSOperation
@end

@implementation TestOp
- (void)main {
    NSLog(@"I'm dumb, I do nothing cool.");
}
@end

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        CTUniqueOperationQueue *queue = [[CTUniqueOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setSuspended:YES];
        
        NSLog(@"Adding stuff to queue");
        [queue addOperation:[[TestOp alloc] init] withID:@"A"];
        assert(queue.operationCount == 1);
        
        // I shouldn't be able to add something with the same ID again
        [queue addOperation:[[TestOp alloc] init] withID:@"A"];
        assert(queue.operationCount == 1);
        
        [queue addOperation:[[TestOp alloc] init] withID:@"B"];
        assert(queue.operationCount == 2);
        
        [queue addOperationWithBlock:^{ NSLog(@"Block test!"); } withID:@"C"];
        assert(queue.operationCount == 3);
        
        NSLog(@"Letting queue run");
        [queue setSuspended:NO];
        [queue waitUntilAllOperationsAreFinished];
        
        NSLog(@"Trying to add an op with the same ID again after it was finished");
        // I should be able to add the same ID's again
        [queue addOperation:[[TestOp alloc] init] withID:@"A"];
        assert(queue.operationCount == 1);
        
        [queue waitUntilAllOperationsAreFinished];
        
        NSLog(@"Testing out cancelling");
        [queue setSuspended:YES];
        [queue addOperation:[[SlowOp alloc] init] withID:@"D"];
        [queue addOperation:[[TestOp alloc] init] withID:@"A"];
        [queue addOperation:[[TestOp alloc] init] withID:@"B"];
        [queue setSuspended:NO];
        assert(queue.operationCount == 3);
        [queue cancelOperationWithID:@"A"];
        [queue cancelOperationWithID:@"B"];
        
        [queue waitUntilAllOperationsAreFinished];
        [queue setSuspended:YES];
        assert(queue.operationCount == 0);
        
        NSLog(@"Attempting to add back canceled op");
        [queue addOperationWithBlock:^{ NSLog(@"I was cancelled!"); } withID:@"B"];
        assert(queue.operationCount == 1);
        [queue setSuspended:NO];
        [queue waitUntilAllOperationsAreFinished];
        
        NSLog(@"SUCCESS");
    }
    return 0;
}

