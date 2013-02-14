//
//  RelationsTest.m
//  RKInjective
//
//  Created by Alex on 2/14/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "RelationsTest.h"
#import "Book.h"

@implementation RelationsTest

- (void)testMappingDictionary
{
    NSDictionary *mappingDict = [Book objectMappingDictionary];
    expect(mappingDict[@"author"]).to.beNil();
}

@end
