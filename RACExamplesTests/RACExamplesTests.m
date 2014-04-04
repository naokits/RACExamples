//
//  RACExamplesTests.m
//  RACExamplesTests
//
//  Created by Naoki Tsutsui on 2014/03/15.
//  Copyright (c) 2014年 Naoki Tsutsui. All rights reserved.
//

#import <XCTest/XCTest.h>
// #import <TRVSMonitor/TRVSMonitor.h>

/**
*   UIが必要でないテストは基本的にここで行う
*/

@interface RACExamplesTests : XCTestCase

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *passwordConfirmation;
@property (nonatomic, assign) BOOL isLoggedin;

@property (nonatomic, strong) UITextField *nameField;

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


/*
    usernameプロパティを監視し、変更がある毎にコンソールに表示する
 */
- (void)testBasicObserv1
{
    [RACObserve(self, username) subscribeNext:^(NSString *newName) {
        NSLog(@"変更された名前: %@", newName);
    }];

    self.username = @"name1";
    self.username = @"name2";
    self.username = @"name3";

    NSLog(@"testBasicObserv1 終了");
}

- (void)testBasicObserv2
{
    [[RACObserve(self, name)
            filter:^(NSString *newName) {
                return [newName hasPrefix:@"Gill"];
            }]
            subscribeNext:^(NSString *x) {
                NSLog(@"%@", x);
            }];

    self.username = @"hoge";
    self.username = @"Gillinghum";
    NSLog(@"testBasicObserv2 終了");
}


/// シグナルの結合の例
- (void)testCombineSignal
{
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
}


//=============================================================================
#pragma mark - シグナルの連鎖（チェイン）
//=============================================================================

/// hogeから始まる名前の場合だけコンソールに表示
- (void)testChain
{
    [[RACObserve(self, username)
            filter:^(NSString *newName) {
                return [newName hasPrefix:@"hoge"]; }]
            subscribeNext:^(NSString *newName) {
                NSLog(@"%@", newName);
            }];

    self.username = @"hoge1";
    self.username = @"jhoge2";
    self.username = @"hoge3";
}


//=============================================================================
#pragma mark - 重要でないテスト
//=============================================================================

- (void)testHogehoge
{
    NSArray *charArray = [@"A B C" componentsSeparatedByString:@" "];
    RACSequence *charSequence = charArray.rac_sequence;
    RACSequence *doubleCharSequence = [charSequence map:^id(NSString *value) {
        return [value stringByAppendingString:value.lowercaseString];
    }];
    
    RACSignal *signalFromDoubleCharSequence = [doubleCharSequence signal];
    
    [signalFromDoubleCharSequence subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}


// やりたいこと
// 名前の配列があるとする。
// 名前の配列を受け取って、名前の先頭に'@'を追加する処理を連続で実行する。
- (RACSignal *)modifyName:(NSString *)name
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *newName = [NSString stringWithFormat:@"@%@", name];
        [subscriber sendNext:newName];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            //
        }];
    }];
}


- (void)testModifyName
{
    [[self modifyName:@"naokits"] subscribeNext:^(id x) {
        NSLog(@"newname: %@", x);
    }];
}

- (void)testJustReturnNameArray
{
    NSArray *array = @[@"name1", @"name2"];
    RACSequence *list = [array rac_sequence];
    RACSignal *signal = [[list map:^id(id value) {
        return value;
    }] signal];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"リストの内容: %@", x);
    }];
}


- (void)testGenerateNewName
{
    NSArray *array = @[@"name1", @"name2"];
    RACSequence *list = [array rac_sequence];
    RACSignal *listSignal = [[list map:^id(id value) {
        return value;
    }] signal];
    
    [listSignal subscribeNext:^(id x) {
        NSLog(@"リストの項目: %@", x);
        [[self modifyName:@"naokits"] subscribeNext:^(id x) {
            NSLog(@"newname: %@", x);
        }];
    }];
}

//- (RACSignal*)loadInformationSignal {
//    RACSignal* coupon = [RACSignal defer:^RACSignal* { return [self.restHelper getCoupon]; }];
//    RACSignal* packet = [RACSignal defer:^RACSignal* { return [self.restHelper getPacket]; }];
//         
//    RACSignal* sig = [[coupon concat:packet] collect];
//    return self.restHelper.accessToken? sig : [[[self.restHelper authorize] catch:self.errorBlock] concat:sig];
//}

//=============================================================================
#pragma mark - 状態の導出
//=============================================================================

/*

 Signalは状態の導出にも用いることができる
 プロパティを監視し、その変化に応じて状態を示すためのプロパティを設定しなくとも、
 RACによってSignalや操作そのものが状態の特性を示すことが出来る。

 次の例では、パスワード入力欄とパスワード確認用の入力欄の値が同じであれば、createEnableed
 をYESとする、一方向のバインディングを作成する。

 **+combineLatest: reduce:** は、Signalの配列を受け取り、各Signalの最新の値を元に
 Blockを実行し、その実行結果に応じて、新たに戻り値を送信する **RACSignal** を作成する。
 */

- (void)testBindState
{
    __block BOOL waitingForBlock = YES;

    _isLoggedin = NO;
    NSLog(@"完了前:%d", self.isLoggedin);

    RAC(self, isLoggedin) =
            [RACSignal combineLatest:@[RACObserve(self, password), RACObserve(self, passwordConfirmation)]
                              reduce:^(NSString *password, NSString *passwordConfirm) {
                                  return @([passwordConfirm isEqualToString:password]);
                              }];

    // プロパティの値を変更
    self.password = @"hogehoge";
    self.passwordConfirmation = @"hogehoge";

    waitingForBlock = NO;

    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    NSLog(@"完了後:%d", self.isLoggedin);
}

@end
