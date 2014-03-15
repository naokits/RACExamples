//
//  RACExamplesTests.m
//  RACExamplesTests
//
//  Created by Naoki Tsutsui on 2014/03/15.
//  Copyright (c) 2014年 Naoki Tsutsui. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TRVSMonitor/TRVSMonitor.h>

@interface RACExamplesTests : XCTestCase
@property (nonatomic, strong, getter=isPushed) NSNumber *pushd;
@property (nonatomic, copy) NSString *name;

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

- (void)testBasicObserv1
{
    __block BOOL waitingForBlock = YES;

    [RACObserve(self, self.pushd) subscribeNext:^(NSNumber *x) {
        NSLog(@"ページ移動");
        waitingForBlock = NO;
    }];

    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    NSLog(@"終了");
}

- (void)testBasicObserv2
{
//    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:2];
    
    [[RACObserve(self, name)
      filter:^(NSString *newName) {
          return [newName hasPrefix:@"Gill"];
      }]
     subscribeNext:^(NSString *x) {
         NSLog(@"%@", x);
     }];
    
    self.name = @"hoge";
    self.name = @"Gillinghum";
//    [monitor signal];

//    [monitor wait];
    NSLog(@"終了");
}

/// シグナルの結合の例
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
