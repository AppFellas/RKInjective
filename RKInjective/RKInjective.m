//
//  RKInjective.m
//  RESTClient
//
//  Created by Sergii Kliuiev on 1/23/13.
//  Copyright (c) 2013 Sergii Kliuiev. All rights reserved.
//

#import <objc/runtime.h>
#import "RKInjective.h"
#import "RKInjectiveStubObject.h"
#import "NSString+Inflections.h"

@implementation RKInjective

+ (RKRouteSet *)sharedRouterRouteSet {
    return [RKObjectManager sharedManager].router.routeSet;
}

+ (RKObjectManager *)sharedManager {
    return [RKObjectManager sharedManager];
}

+ (void)setupObjectsRouteForClass:(Class)cls {
    NSString *path = [cls pathForRequestType:RKIRequestGetObjects];
    if ( nil == path ) {
        path = [cls defaultPathForRequestType:RKIRequestGetObjects];
    }
    RKRoute *objectsRoute = [RKRoute routeWithName:[cls modelNamePlural]
                                       pathPattern:path
                                            method:RKRequestMethodGET];
    [[[self class] sharedRouterRouteSet] addRoute:objectsRoute];
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[[self class] sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupObjectRouteForClass:(Class)cls {
    NSString *path = [cls pathForRequestType:RKIRequestGetObject];
    if ( nil == path ) {
        path = [cls defaultPathForRequestType:RKIRequestGetObject];
    }
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:path
                                            method:RKRequestMethodGET];
    [[[self class] sharedRouterRouteSet] addRoute:objectRoute];
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[[self class] sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupRoutesForClass:(Class)cls {
    [[self class] setupObjectsRouteForClass:cls];
    [[self class] setupObjectRouteForClass:cls];
}

+ (void)addClassMethodsToClass:(Class)cls {
    Class stubObjClass = [RKInjectiveStubObject class];
    Protocol *protocol = @protocol(RKInjectiveProtocol);
    
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, NO, &count);
    for (unsigned i = 0; i < count; i++)
    {
        SEL selector = methods[i].name;
        NSLog(@"[Class] checking: %@", NSStringFromSelector(selector));
        if (![cls respondsToSelector:selector]) {
            //addDefaultImplementation
            Method method = class_getClassMethod(stubObjClass, selector);
            char *signature = methods[i].types;
            IMP implementation = method_getImplementation(method);
            class_addMethod(object_getClass(cls), selector, implementation, signature);
        }
    }
    free(methods);
}

+ (void)addInstanceMethodsToClass:(Class)cls {
    Class stubObjClass = [RKInjectiveStubObject class];
    Protocol *protocol = @protocol(RKInjectiveProtocol);
    
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &count);
    for (unsigned i = 0; i < count; i++)
    {
        SEL selector = methods[i].name;
        NSLog(@"[Instance] checking: %@", NSStringFromSelector(selector));
        if (![cls respondsToSelector:selector]) {
            //addDefaultImplementation
            Method method = class_getInstanceMethod(stubObjClass, selector);
            char *signature = methods[i].types;
            IMP implementation = method_getImplementation(method);
            class_addMethod(cls, selector, implementation, signature);
        }
    }
    free(methods);
}

+ (void)registerClass:(Class)cls {
    
    if (nil == [RKObjectManager sharedManager]) {
        assert(@"RKObject manager doesnt exist");
    }
    
    if ( class_conformsToProtocol(cls, @protocol(RKInjectiveProtocol)) ) {
        
        [[self class] addClassMethodsToClass:cls];
        [[self class] addInstanceMethodsToClass:cls];
        
        
        //[RKInjective setupMappingForClass:cls];
        [RKInjective setupRoutesForClass:cls];

    }
}

@end
