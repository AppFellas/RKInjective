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

- (void)testRelationsMapping
{
    [RKTestFactory stubGetRequest:@"http://localhost/books" withFixture:@"books"];
    
    [self runTestWithBlock:^{
        [Book getObjectsOnSuccess:^(NSArray *objects){
            //check we've loaded 3 books
            NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
            NSError *error = nil;
            NSArray *mobjects = [moc executeFetchRequest:fetchRequest error:&error];
            expect(mobjects.count).to.equal(3);
            
            //check author of book with id=2 is J. K. Rowling
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"bookId == %@", @"2"]];
            error = nil;
            mobjects = [moc executeFetchRequest:fetchRequest error:&error];
            Book *book = [mobjects lastObject];
            expect(book.author.name).to.equal(@"J. K. Rowling");
            
            //check Dan Brown has 2 books
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Author"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"Dan Brown"]];
            error = nil;
            mobjects = [moc executeFetchRequest:fetchRequest error:&error];
            Author *author = [mobjects lastObject];
            expect(author.books.count).to.equal(2);
            
            //test we got 2 authors
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Author"];
            error = nil;
            mobjects = [moc executeFetchRequest:fetchRequest error:&error];
            expect(mobjects.count).to.equal(2);
        } failure:^(NSError *error){
            expect(error).to.beNil();
            [self blockTestCompleted];
        }];
    }];
}

@end
