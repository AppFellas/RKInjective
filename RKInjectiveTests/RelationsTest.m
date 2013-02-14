//
//  RelationsTest.m
//  RKInjective
//
//  Created by Alex on 2/14/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "RelationsTest.h"
#import "Book.h"
#import "Author.h"

@implementation RelationsTest

- (void)testMappingDictionary
{
    NSDictionary *mappingDict = [Book objectMappingDictionary];
    expect(mappingDict[@"author"]).to.beNil();
}

- (void)testRelationsList
{
    NSArray *mappings = [Book objectRelationsMappings];
    expect(mappings.count).to.equal(1);
    RKRelationshipMapping *receivedMapping = [mappings lastObject];
    
    RKObjectMapping *authorMapping = [Author objectMapping];
    RKRelationshipMapping *relationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                                         toKeyPath:@"author"
                                                                                       withMapping:authorMapping];
    STAssertTrue([receivedMapping isEqualToMapping:relationMapping], @"Author property mappings should be equal");
}

@end
