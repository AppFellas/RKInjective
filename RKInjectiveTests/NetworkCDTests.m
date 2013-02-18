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

- (void)testDeleteObject {
    [RKTestFactory stubDeleteRequest:@"http://localhost/managedObjects/1"];
    
    NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    // Create here 3 objects, one with id=1
    for (int i = 1; i < 4; i++) {
        ManagedObject *obj = [RKTestFactory insertManagedObjectForEntityForName:@"ManagedObject" inManagedObjectContext:moc withProperties:nil];
        obj.itemId = [NSString stringWithFormat:@"%d", i];
    }
    [moc saveToPersistentStore:NULL];
    
    // Check here that you have 3 objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ManagedObject"];
    
    NSError *error = nil;
    NSArray *mobjects = [moc executeFetchRequest:fetchRequest error:&error];
    expect(mobjects.count).to.equal(3);
    
    //get object with id=1
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ManagedObject"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", @"1"];
    [request setPredicate:predicate];
    NSArray *objs = [moc executeFetchRequest:request error:NULL];
    ManagedObject *objectToDelete = [objs lastObject];
    expect(objectToDelete).toNot.beNil();
    
    [self runTestWithBlock:^{
        [objectToDelete deleteObjectOnSuccess:^{
            //check we don't have it anymore
            NSArray *objects = [moc executeFetchRequest:request error:NULL];
            expect(objects.count).to.equal(0);
            [self blockTestCompleted];
        } failure:^(NSError *error){
            expect(error).to.beNil();
            [self blockTestCompleted];
        }];
    }];
}

- (void)testPostObject
{
    [RKTestFactory stubPostRequest:@"http://localhost/managedObjects" withFixture:@"managed_object"];
    NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    ManagedObject *obj = [RKTestFactory insertManagedObjectForEntityForName:@"ManagedObject" inManagedObjectContext:moc withProperties:nil];
    obj.title = @"RKInjective test";
    
    [self runTestWithBlock:^{
        [obj postObjectOnSuccess:^(id object){
            ManagedObject *managedObject = (ManagedObject *)object;
            STAssertNotNil(object, @"Could not load object");
            STAssertEquals(obj, object, @"Expected to match the ManagedObject, but did not");
            expect(managedObject.itemId).notTo.beNil();
            [self blockTestCompleted];
        } failure:^(NSError *error){
            expect(error).to.beNil();
            [self blockTestCompleted];
        }];
    }];
}

- (void)testPutObject
{
    [RKTestFactory stubGetRequest:@"http://localhost/managedObjects" withFixture:@"articles"];
    [RKTestFactory stubPutRequest:@"http://localhost/managedObjects/1" withFixture:@"article_edited"];
    
    NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ManagedObject"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", @"1"];
    [request setPredicate:predicate];
    
    [self runTestWithBlock:^{
        [ManagedObject getObjectsOnSuccess:^(NSArray *objects){
            expect(objects.count).to.equal(3);
            NSArray *objs = [moc executeFetchRequest:request error:NULL];
            ManagedObject *managedObject = [objs lastObject];
            NSString *newTitle = @"Edited title";
            managedObject.title = newTitle;
            [managedObject putObjectOnSuccess:^(id object){
                ManagedObject *editedObject = (ManagedObject *)object;
                expect(editedObject.itemId).to.equal(managedObject.itemId);
                expect(editedObject.title).to.equal(newTitle);
                [self blockTestCompleted];
            } failure:^(NSError *error){
                expect(error).to.beNil();
                [self blockTestCompleted];
            }];
        } failure:^(NSError *error){
            expect(error).to.beNil();
            [self blockTestCompleted];
        }];
    }];
}

- (void)testPatchObject
{
    [RKTestFactory stubGetRequest:@"http://localhost/managedObjects" withFixture:@"articles"];
    [RKTestFactory stubPatchRequest:@"http://localhost/managedObjects/1" withFixture:@"article_edited"];
    
    NSManagedObjectContext *moc = [RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ManagedObject"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", @"1"];
    [request setPredicate:predicate];
    
    [self runTestWithBlock:^{
        [ManagedObject getObjectsOnSuccess:^(NSArray *objects){
            expect(objects.count).to.equal(3);
            NSArray *objs = [moc executeFetchRequest:request error:NULL];
            ManagedObject *managedObject = [objs lastObject];
            NSString *newTitle = @"Edited title";
            managedObject.title = newTitle;
            [managedObject patchObjectOnSuccess:^(id object){
                ManagedObject *editedObject = (ManagedObject *)object;
                expect(editedObject.itemId).to.equal(managedObject.itemId);
                expect(editedObject.title).to.equal(newTitle);
                [self blockTestCompleted];
            } failure:^(NSError *error){
                expect(error).to.beNil();
                [self blockTestCompleted];
            }];
        } failure:^(NSError *error){
            expect(error).to.beNil();
            [self blockTestCompleted];
        }];
    }];
}

@end
