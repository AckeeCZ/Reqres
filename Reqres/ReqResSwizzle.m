#import "ReqResSwizzle.h"
#import Reqres;
@import ObjectiveC.runtime;

@implementation ReqResSwizzle

static IMP __original_defaultSessionConfiguration_Imp;

static NSURLSessionConfiguration *dnbtest_defaultSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = ((NSURLSessionConfiguration *(*)(id,SEL))__original_defaultSessionConfiguration_Imp)(self, _cmd);
    NSMutableArray<Class> *classes = [[NSMutableArray alloc] init];
    if (config.protocolClasses)
        [classes addObjectsFromArray:config.protocolClasses];
    [classes insertObject:Reqres.class atIndex:0];
    config.protocolClasses = classes;
    return config;
}

+ (void)swizzle
{
    Method m;

    m = class_getClassMethod([NSURLSessionConfiguration class],
                                @selector(defaultSessionConfiguration));

    __original_defaultSessionConfiguration_Imp = method_setImplementation(m,
                                                              (IMP)dnbtest_defaultSessionConfiguration);
}

@end
