//
//  RKTestFactory+AppExtensions.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "RKTestFactory+AppExtensions.h"

@implementation RKTestFactory (AppExtensions)

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

// Perform any global initialization of your testing environment
+ (void)load
{
    // Configuring test bundle
    NSBundle *testTargetBundle = [NSBundle bundleWithIdentifier:@"com.AppFellas.RKInjectiveTests"];
    [RKTestFixture setFixtureBundle:testTargetBundle];
    
    // Set logging levels
	RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
    
    // Setup CoreData
    [self checkPathForCoreDataFile];
	
	[self setSetupBlock:^{
        // Setup Network stubs
		[[LSNocilla sharedInstance] start];
        
        // Core Data
        RKManagedObjectStore *store = [RKTestFactory managedObjectStore];
        [RKManagedObjectStore setDefaultStore:store];
        
        RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost/"]];
        manager.managedObjectStore = store;
	}];
	
	[self setTearDownBlock:^{
        // Clear Network stubs
		[[LSNocilla sharedInstance] clearStubs];
        [[LSNocilla sharedInstance] stop];
	}];
}

+ (void)stubGetRequest:(NSString *)uri withFixture:(NSString *)fixtureName {
    NSString *fileName = [fixtureName stringByAppendingPathExtension:@"json"];
    NSString *data = [RKTestFixture stringWithContentsOfFixture:fileName];
    stubRequest(@"GET", uri).andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).withBody(data);
}

+ (void)stubDeleteRequest:(NSString *)uri withFixture:(NSString *)fixtureName {
    NSString *fileName = [fixtureName stringByAppendingPathExtension:@"json"];
    NSString *data = [RKTestFixture stringWithContentsOfFixture:fileName];
    stubRequest(@"DELETE", uri).andReturn(200).
    withHeaders(@{@"Content-Type": @"application/json"}).withBody(data);
}

+ (void)stubDeleteRequest:(NSString *)uri
{
    [RKTestFactory stubDeleteRequest:uri withFixture:@"empty"];
}

+ (void)stubPostRequest:(NSString *)uri withFixture:(NSString *)fixtureName
{
    NSString *fileName = [fixtureName stringByAppendingPathExtension:@"json"];
    NSString *data = [RKTestFixture stringWithContentsOfFixture:fileName];
    stubRequest(@"POST", uri).andReturn(201).
    withHeaders(@{@"Content-Type": @"application/json"}).withBody(data);
}

+ (void)stubPostRequest:(NSString *)uri
{
    [RKTestFactory stubPostRequest:uri withFixture:@"empty"];
}

@end
