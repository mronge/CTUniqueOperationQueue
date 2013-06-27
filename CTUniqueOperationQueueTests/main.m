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
        
        {
            NSLog(@"Testing out cancelling and then immediately adding op again");
            [queue setSuspended:YES];
            SlowOp *slowOp = [[SlowOp alloc] init];
            slowOp.completionBlock = ^{ NSLog(@"SlowOp finished"); };
            [queue addOperation:slowOp withID:@"D"];
            TestOp *testOp1 = [[TestOp alloc] init];
            testOp1.completionBlock = ^{ NSLog(@"TestOp1 finished"); };
            [queue addOperation:testOp1 withID:@"A"];
            [queue setSuspended:NO];
            [queue cancelOperationWithID:@"A"];
            [queue setSuspended:YES];
            TestOp *testOp2 = [[TestOp alloc] init];
            testOp2.completionBlock = ^{ NSLog(@"TestOp2 finished"); };
            [queue addOperation:testOp2 withID:@"A"];
            assert([queue.operations containsObject:testOp2] == YES);
            [queue setSuspended:NO];
        }

        [queue waitUntilAllOperationsAreFinished];

        [queue setSuspended:YES];
        
        NSLog(@"Adding more stuff to queue");
        [queue addOperation:[[TestOp alloc] init] withID:@"A"];
        assert(queue.operationCount == 1);
        assert([queue operationWithID:@"A"].queuePriority == NSOperationQueuePriorityNormal);

        // New item should just be added
        [queue addOperation:[[TestOp alloc] init] withID:@"B"];
        assert(queue.operationCount == 2);

        // Same item still queued should have priority changed
        [queue addOrSetQueuePriority:NSOperationQueuePriorityHigh operation:[[TestOp alloc] init] withID:@"A"];
        assert(queue.operationCount == 2);
        assert([queue operationWithID:@"A"].queuePriority == NSOperationQueuePriorityHigh);
        [queue setSuspended:NO];
        [queue waitUntilAllOperationsAreFinished];


        NSLog(@"SUCCESS");
    }
    return 0;
}

