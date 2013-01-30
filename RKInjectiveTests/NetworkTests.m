//
//  NetworkTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "NetworkTests.h"

@implementation NetworkTests

- (void)testGetObjects {
    [RKTestFactory stubGetRequest:@"http://localhost/articles" withFixture:@"articles"];
    
    [self runTestWithBlock:^{
        [Article getObjectsOnSuccess:^(NSArray *objects) {
            STAssertNotNil(objects, @"Could not load objects");
            expect(objects).toNot.beNil();
            expect(objects.count).to.equal(3);
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            STAssertNil(error, @"Should be no error on object loading");
            [self blockTestCompleted];
        }];
    }];
}

- (void)testGetObject {
    [RKTestFactory stubGetRequest:@"http://localhost/articles/10000" withFixture:@"article"];
    
    [self runTestWithBlock:^{
        Article *article = [Article new];
        article.articleId = @"10000";
        [article getObjectOnSuccess:^(id object) {
            STAssertNotNil(object, @"Could not load objects");
            expect(object).toNot.beNil();
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            STAssertNil(error, @"Should be no error on object loading");
            [self blockTestCompleted];
        }];
    }];
}

- (void)testGetObjectsWithPath {
    [RKTestFactory stubGetRequest:@"http://localhost/api_records" withFixture:@"articles"];
    
    [self runTestWithBlock:^{
        [Record getObjectsOnSuccess:^(NSArray *objects) {
            STAssertNotNil(objects, @"Could not load objects");
            expect(objects).toNot.beNil();
            expect(objects.count).to.equal(3);
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            STAssertNil(error, @"Should be no error on object loading");
            [self blockTestCompleted];
        }];
    }];
}


- (void)testGetObjectWithPath {
    [RKTestFactory stubGetRequest:@"http://localhost/api_records/10000" withFixture:@"article"];
    
    [self runTestWithBlock:^{
        Record *record = [Record new];
        record.itemId = @"10000";
        [record getObjectOnSuccess:^(id object) {
            STAssertNotNil(object, @"Could not load objects");
            expect(object).toNot.beNil();
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            STAssertNil(error, @"Should be no error on object loading");
            [self blockTestCompleted];
        }];
    }];
}

@end
