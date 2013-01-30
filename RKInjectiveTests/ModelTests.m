//
//  ModelTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "ModelTests.h"

@implementation ModelTests

- (void)testModelName {
    expect([Article modelName]).to.equal(@"article");
}

- (void)testModelNamePlural {
    expect([Article modelNamePlural]).to.equal(@"articles");
}

- (void)testUniqueIdentifier {
    Article *article = [Article new];
    article.articleId = @"1000";
    expect([article uniqueIdentifier]).to.equal(@"1000");
}

@end
