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
    if (!mapping) return;
    NSArray *relationsMappings = [cls objectRelationsMappings];
    if (relationsMappings) [mapping addPropertyMappingsFromArray:relationsMappings];
    
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
    if (!mapping) return;
    NSArray *relationsMappings = [cls objectRelationsMappings];
    if (relationsMappings) [mapping addPropertyMappingsFromArray:relationsMappings];
    
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    [[[self class] sharedManager] addResponseDescriptor:descriptor];
}

+ (void)setupDeleteRouteForClass:(Class)cls {
    NSString *path = [cls pathForRequestType:RKIRequestDeleteObject];
    if ( nil == path ) {
        path = [cls defaultPathForRequestType:RKIRequestDeleteObject];
    }
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:path
                                            method:RKRequestMethodDELETE];
    [[[self class] sharedRouterRouteSet] addRoute:objectRoute];
}

+ (void)setupPostRouteForClass:(Class)cls {
    NSString *path = [cls pathForRequestType:RKIRequestPostObject];
    if ( nil == path ) {
        path = [cls defaultPathForRequestType:RKIRequestPostObject];
    }
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:path
                                            method:RKRequestMethodPOST];
    [[[self class] sharedRouterRouteSet] addRoute:objectRoute];
    
    RKObjectMapping *requestMapping = [cls requestMapping];
    if (!requestMapping) return;
    RKRequestDescriptor *descriptor = nil;
    descriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                                       objectClass:cls
                                                       rootKeyPath:nil];
    [[[self class] sharedManager] addRequestDescriptor:descriptor];
}

+ (void)setupPutRouteForClass:(Class)cls {
    NSString *path = [cls pathForRequestType:RKIRequestPutObject];
    if ( nil == path ) {
        path = [cls defaultPathForRequestType:RKIRequestPutObject];
    }
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:path
                                            method:RKRequestMethodPUT];
    [[[self class] sharedRouterRouteSet] addRoute:objectRoute];
}

+ (void)setupPatchRouteForClass:(Class)cls {
    NSString *path = [cls pathForRequestType:RKIRequestPatchObject];
    if ( nil == path ) {
        path = [cls defaultPathForRequestType:RKIRequestPatchObject];
    }
    RKRoute *objectRoute = [RKRoute routeWithClass:cls
                                       pathPattern:path
                                            method:RKRequestMethodPATCH];
    [[[self class] sharedRouterRouteSet] addRoute:objectRoute];
}

+ (void)setupRoutesForClass:(Class)cls {
    [[self class] setupObjectsRouteForClass:cls];
    [[self class] setupObjectRouteForClass:cls];
    [[self class] setupDeleteRouteForClass:cls];
    [[self class] setupPostRouteForClass:cls];
    [[self class] setupPutRouteForClass:cls];
    [[self class] setupPatchRouteForClass:cls];
}

+ (void)addMethod:(struct objc_method_description)md asInstance:(BOOL)isInstance toClass:(Class)cls {
    Class stubObjClass = [RKInjectiveStubObject class];
    
    SEL selector = md.name;
    char *signature = md.types;

    Method method;
    Class toCls;
    NSString *addingTo = nil;
    
    if (isInstance) {
        method = class_getInstanceMethod(stubObjClass, selector);
        toCls = cls;
        addingTo = @"Instance";
    } else {
        method = class_getClassMethod(stubObjClass, selector);
        toCls = object_getClass(cls);
        addingTo = @"Class";
    }
    
    IMP implementation = method_getImplementation(method);
    
    NSString *selectorStr = nil;
    // Then add it as default
    if ([cls respondsToSelector:selector]) {
        selectorStr = NSStringFromSelector(selector);
        NSString *newSelectorStr = [@"rki_" stringByAppendingString:selectorStr];
        selector = NSSelectorFromString(newSelectorStr);
    }
    
    // Don't add if something is there
    if (![cls respondsToSelector:selector]) {
        selectorStr = NSStringFromSelector(selector);
        NSLog(@"%@ [%@] adding: %@", NSStringFromClass(cls), addingTo, selectorStr);
        class_addMethod(toCls, selector, implementation, signature);
    }
}

+ (void)addMethodsToClass:(Class)cls asInstance:(BOOL)isInstance {
    Protocol *protocol = @protocol(RKInjectiveProtocol);
    
    unsigned int count;
    struct objc_method_description *methods = NULL;
    methods = protocol_copyMethodDescriptionList(protocol,
                                                 NO,
                                                 isInstance,
                                                 &count);
    for (unsigned int i = 0; i < count; i++) {
        [self addMethod:methods[i] asInstance:isInstance toClass:cls];
    }
    free(methods);
}

+ (void)addClassMethodsToClass:(Class)cls {
    [self addMethodsToClass:cls asInstance:NO];
}

+ (void)addInstanceMethodsToClass:(Class)cls {
    [self addMethodsToClass:cls asInstance:YES];
}

+ (void)registerClass:(Class)cls {
    
    if (nil == [RKObjectManager sharedManager]) {
        assert(@"RKObject manager doesnt exist");
    }
    
    if ( [cls conformsToProtocol:@protocol(RKInjectiveProtocol)] ) {
        
        [[self class] addClassMethodsToClass:cls];
        [[self class] addInstanceMethodsToClass:cls];
        [RKInjective setupRoutesForClass:cls];

    }
}

@end
