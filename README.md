# CTUniqueOperationQueue

CTUniqueOperationQueue helps avoid doing duplicate work in your NSOperationQueue's

## Why?

NSOperationQueue's are incredibly useful but they make it really easy to queue up duplicate operations. For example, if the user scrolls past a UITableViewCell multiple times and the cell requires work to be done, you'll quickly queue up duplicate operations. Or if the user enters a UIViewController multiple times and you kick off work, you'll have duplicate operations.

Currently, to avoid duplicate operations you need to do manual bookkeeping. CTUniqueOperationQueue makes this easy by adding methods which take an unique operation id. There is also a handy method for cancelling operations by id as well.

## Examples

There are two ways to add an operation, either as a regular NSOperation or as a block:

```objc
- (void)addOperation:(NSOperation *)op withID:(NSString *)aID;
- (void)addOperationWithBlock:(void (^)(void))block withID:(NSString *)aID;
```

Both methods take an ID as a NSString. If there is already an operation in the queue with that ID, the new operation isn't added.

It's also super easy to cancel operations when you have the ID:

```objc
- (void)cancelOperationWithID:(NSString *)anID;
```

You can also use all the existing NSOperationQueue methods, which is useful for jobs that don't need to be unique.

## Contact

Matt Ronge  
[@mronge](http://www.twitter.com/mronge)
[http://www.mronge.com](http://www.mronge.com)

## License

(The 3-clause BSD license)

Copyright (C) 2012 - Matt Ronge &lt;mronge@mronge.com&gt; All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of Central Atomics Inc. nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.



