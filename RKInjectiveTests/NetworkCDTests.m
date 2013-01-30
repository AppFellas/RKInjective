//
//  NetworkCDTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "NetworkCDTests.h"

@implementation NetworkCDTests

- (void)testGetObjects {
    [RKTestFactory stubGetRequest:@"http://localhost/managedObjects" withFixture:@"articles"];
    
    [self runTestWithBlock:^{
        [ManagedObject getObjectsOnSuccess:^(NSArray *objects) {
            STAssertNotNil(objects, @"Could not load objects");
            expect(objects).toNot.beNil();
            expect(objects.count).to.equal(3);
            
            NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ManagedObject"];
            
            NSError *error = nil;
            NSArray *mobjects = [moc executeFetchRequest:fetchRequest error:&error];
            
            expect(mobjects.count).to.equal(3);
            
            [self blockTestCompleted];
        } failure:^(NSError *error) {
            expect(error).to.beNil();
            [self blockTestCompleted];
        }];
    }];
}

@end
