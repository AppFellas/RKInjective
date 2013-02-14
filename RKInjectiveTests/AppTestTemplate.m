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
    [RKInjective registerClass:[Book class]];
    [RKInjective registerClass:[Author class]];
}

- (void)tearDown {
    
    RKRouteSet *set = [RKObjectManager sharedManager].router.routeSet;
    for (RKRoute *route in set.allRoutes) {
        //[set removeRoute:route];
        NSLog(@"route: %@", route);
    }
    
    [RKTestFactory tearDown];
}

@end
