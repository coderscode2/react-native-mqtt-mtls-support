#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MqttModule, NSObject)

RCT_EXTERN_METHOD(connect:
  (NSString *)broker
  clientId:(NSString *)clientId
  clientCertPem:(NSString *)clientCertPem
  privateKeyPem:(NSString *)privateKeyPem
  rootCaPem:(NSString *)rootCaPem
  successCallback:(RCTResponseSenderBlock)successCallback
  errorCallback:(RCTResponseSenderBlock)errorCallback
)

@end
