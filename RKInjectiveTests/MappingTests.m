//
//  MappingTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "MappingTests.h"
#import "Article.h"

@implementation MappingTests

- (void)setUp {
    [RKTestFactory setUp];
}

- (void)tearDown {
    [RKTestFactory tearDown];
}

- (void)testObjectMappingDictionary {
    NSDictionary *dict = [Article objectMappingDictionary];
    NSDictionary *dict2 = @{@"id" : @"articleId", @"name" : @"name", @"title" : @"title"};
    expect(dict).to.equal(dict2);
}



- (void)testMapping {
    id parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"article.json"];
    
    RKMapping *mapping = [Article objectMapping];
    RKMappingTest *test = [RKMappingTest testForMapping:mapping sourceObject:parsedJSON destinationObject:nil];
	[test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    BOOL evaluated = [test evaluate];
    expect(evaluated).to.equal(YES);
}

@end
