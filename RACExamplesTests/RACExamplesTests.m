//
//  RACExamplesTests.m
//  RACExamplesTests
//
//  Created by Naoki Tsutsui on 2014/03/15.
//  Copyright (c) 2014年 Naoki Tsutsui. All rights reserved.
//

#import <XCTest/XCTest.h>


@interface RACExamplesTests : XCTestCase

@end

@implementation RACExamplesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//    XCTFail(@"%s Error:%@", __PRETTY_FUNCTION__, error);

//}


- (void)testCombineSignal
{
    __block BOOL waitingForBlock = YES;

    RACSignal *signal1 = @[@(1)].rac_sequence.signal;
    RACSignal *signal2 = @[@(2)].rac_sequence.signal;
    
    [[RACSignal merge:@[signal1, signal2]]
     subscribeCompleted:^{
         NSLog(@"They are both done!");
         XCTAssertTrue(YES, @"Should have been success!");
     }];

    [signal1 subscribeNext:^(id x) {
        NSLog(@"signal1: %@", x);
    }];
    
    [signal2 subscribeNext:^(id x) {
        NSLog(@"signal2: %@", x);
    }];
    waitingForBlock = NO;


    // Run the loop
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}



@end
