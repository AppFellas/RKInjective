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

+ (void)setupRoutesForClass:(Class)cls {
    RKRouter *router = [[RKObjectManager sharedManager] router];
    
    NSString *path = [cls modelNamePlural];
    RKRoute *getObjectsRoute = [RKRoute routeWithName:[cls modelNamePlural]
                                          pathPattern:path
                                               method:RKRequestMethodGET];
    [router.routeSet addRoute:getObjectsRoute];
    
    NSString *modelId = [[cls modelName] stringByAppendingString:@"Id"];
    NSString *pattern = [[cls modelNamePlural] stringByAppendingFormat:@"/:%@", modelId];
    RKRoute *getObjectRoute = [RKRoute routeWithClass:cls
                                          pathPattern:pattern
                                               method:RKRequestMethodGET];
    [router.routeSet addRoute:getObjectRoute];
    
    
    RKObjectMapping *mapping = [cls objectMapping];
    NSIndexSet *codes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *descriptor = nil;
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                         pathPattern:path
                                                             keyPath:nil
                                                         statusCodes:codes];
    RKResponseDescriptor *objectDescriptor = nil;
    objectDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                               pathPattern:pattern
                                                                   keyPath:nil
                                                               statusCodes:codes];
    
    [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[descriptor, objectDescriptor]];
    
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
