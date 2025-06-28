#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MqttModule, NSObject)

RCT_EXTERN_METHOD(connectWithMtls:
  (NSString *)brokerUrl
  clientId:(NSString *)clientId
  cert:(NSString *)cert
  key:(NSString *)key
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
)

@end
