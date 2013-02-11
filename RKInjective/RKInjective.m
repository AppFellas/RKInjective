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

+ (void)addMethod:(struct objc_method_description)md asInstance:(BOOL)isInstance toClass:(Class)cls
{
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
    
    // Then add it as default
    if ([cls respondsToSelector:selector]) {
        NSString *newSelectorStr = [@"rki_" stringByAppendingString:NSStringFromSelector(selector)];
        selector = NSSelectorFromString(newSelectorStr);
    }
    
    // Don't add if something is there
    if (![cls respondsToSelector:selector]) {
        NSLog(@"%@ [%@] adding: %@", NSStringFromClass(cls), addingTo, NSStringFromSelector(selector));
        class_addMethod(toCls, selector, implementation, signature);
    }
}

+ (void)addMethodsToClass:(Class)cls asInstance:(BOOL)isInstance {
    Protocol *protocol = @protocol(RKInjectiveProtocol);
    
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, isInstance, &count);
    for (unsigned i = 0; i < count; i++) {
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
        
        
        //[RKInjective setupMappingForClass:cls];
        [RKInjective setupRoutesForClass:cls];

    }
}

@end
