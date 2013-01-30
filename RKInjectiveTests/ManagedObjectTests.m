//
//  ManagedObjectTests.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "ManagedObjectTests.h"
#import "ManagedObject.h"

@implementation ManagedObjectTests

+ (void)checkPathForCoreDataFile {
    NSString *path = RKApplicationDataDirectory();
    NSError *error = nil;
    BOOL isDir = YES;
    NSFileManager *fm= [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path isDirectory:&isDir]) {
        if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error: Create folder failed");
        }
    }
}

+ (void)initialize {
    [self checkPathForCoreDataFile];
    RKManagedObjectStore *managedObjectStore = [RKTestFactory managedObjectStore];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
}

- (void)testCoreDataIntegration {
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];

    expect(managedObjectStore).toNot.beNil();
    
    NSManagedObjectContext *moc = managedObjectStore.persistentStoreManagedObjectContext;
    expect(moc).toNot.beNil();
    
    
    ManagedObject *mo = [RKTestFactory insertManagedObjectForEntityForName:@"ManagedObject" inManagedObjectContext:moc withProperties:nil];
    mo.name = @"SomeObject";
    
    [moc saveToPersistentStore:NULL];
    
    expect(mo).toNot.beNil();
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ManagedObject"];
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    
    expect(objects).toNot.beNil();
}

- (void)testManagedObjectIdentification
{
	RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    //NSDictionary *entitiesByName = [managedObjectStore.managedObjectModel entitiesByName];
    //NSLog(@"entitiesByName: %@", entitiesByName);
    
	RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Article" inManagedObjectStore:managedObjectStore];
	entityMapping.identificationAttributes = @[ @"articleId" ];
	[entityMapping addAttributeMappingsFromDictionary:@{
     @"id":		@"articleId",
     @"title":	@"title"
     }];
	NSDictionary *articleRepresentation = @{ @"id": @1234, @"title": @"The Title" };
	RKMappingTest *mappingTest = [RKMappingTest testForMapping:entityMapping sourceObject:articleRepresentation destinationObject:nil];
    
	// Configure Core Data
	mappingTest.managedObjectContext = managedObjectStore.persistentStoreManagedObjectContext;
    
	// Create an object to match our criteria
	NSManagedObject *article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
	[article setValue:@(1234) forKey:@"articleId"];
    
	// Let the test perform the mapping
	[mappingTest performMapping];
    
	STAssertEquals(article, mappingTest.destinationObject, @"Expected to match the Article, but did not");
}

@end
