//
//  AppTestTemplate.m
//  RKInjective
//
//  Created by Taras Kalapun on 1/30/13.
//  Copyright (c) 2013 AppFellas. All rights reserved.
//

#import "AppTestTemplate.h"

@implementation AppTestTemplate

- (void)setUp {
    [RKTestFactory setUp];
    
    
    // re-register
    [RKInjective registerClass:[Article class]];
    [RKInjective registerClass:[Record class]];
    [RKInjective registerClass:[ManagedObject class]];
}

- (void)tearDown {
    [RKTestFactory tearDown];
}

@end
