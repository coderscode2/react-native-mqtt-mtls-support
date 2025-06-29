#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(CSRModule, NSObject)

RCT_EXTERN_METHOD(generateCSR:(NSDictionary *)subjectInfo
                  error:(NSError **)error
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end