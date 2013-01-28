//
//  ArticleTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/28/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "ArticleTests.h"
#import "Article.h"

@implementation ArticleTests


- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testModelName {
    expect([Article modelName]).to.equal(@"article");
}

- (void)testModelNamePlural {
    expect([Article modelNamePlural]).to.equal(@"articles");
}

- (void)testObjectMappingDictionary {
    NSDictionary *dict = [Article objectMappingDictionary];
    NSDictionary *dict2 = @{@"id" : @"articleId", @"name" : @"name"};
    expect(dict).to.equal(dict2);
}

- (void)testUniqueIdentifier {
    Article *article = [Article new];
    expect([article uniqueIdentifier]).to.equal(@"stub");
}

@end
