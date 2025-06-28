import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-mqtt-mtls-support' doesn't seem to be linked.`;

const MqttModule = NativeModules.MqttModule
  ? NativeModules.MqttModule
  : new Proxy({}, {
      get() {
        throw new Error(LINKING_ERROR);
      },
    });

export default MqttModule;
