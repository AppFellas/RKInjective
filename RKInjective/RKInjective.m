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

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

@implementation RKInjective

+ (void)setupObjectsRouteForClass:(Class)cls {
    RKRouter *router = [[RKObjectManager sharedManager] router];
    NSString *path = [cls modelNamePlural];
    RKRoute *objectsRoute = [RKRoute routeWithName:[cls modelNamePlural]
                                       pathPattern:path
                                            method:RKRequestMethodGET];
    [router.routeSet addRoute:objectsRoute];
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[RKObjectManager sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupObjectRouteForClass:(Class)cls {
    RKRouter *router = [[RKObjectManager sharedManager] router];
    NSString *objectId = [cls uniqueIdentifierName];
    NSString *pattern = [[cls modelNamePlural] stringByAppendingFormat:@"/:%@", objectId];
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:pattern
                                            method:RKRequestMethodGET];
    [router.routeSet addRoute:objectRoute];
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:pattern
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[RKObjectManager sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupObjectsRouteForClass:(Class)cls path:(NSString *)path {
    RKRouter *router = [[RKObjectManager sharedManager] router];
    RKRoute *objectsRoute = [RKRoute routeWithName:[cls modelNamePlural]
                                       pathPattern:path
                                            method:RKRequestMethodGET];
    [router.routeSet addRoute:objectsRoute];
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[RKObjectManager sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupObjectRouteForClass:(Class)cls path:(NSString *)path {
    RKRouter *router = [[RKObjectManager sharedManager] router];
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:path
                                            method:RKRequestMethodGET];
    [router.routeSet addRoute:objectRoute];
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[RKObjectManager sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupRoutesForClass:(Class)cls {
    NSString *objectsPath = [cls parhForRequestType:RKIRequestGetObjects];
    NSString *objectPath = [cls parhForRequestType:RKIRequestGetObject];
    if ( IsEmpty(objectsPath) ) {
        [[self class] setupObjectsRouteForClass:cls];
    } else {
        [[self class] setupObjectsRouteForClass:cls path:objectsPath];
    }
    if ( IsEmpty(objectPath) ) {
        [[self class] setupObjectRouteForClass:cls];
    } else {
        [[self class] setupObjectRouteForClass:cls path:objectPath];
    }
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
