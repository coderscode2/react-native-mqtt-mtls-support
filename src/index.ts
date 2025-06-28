import { NativeModules } from 'react-native';

const { CSRModule, MqttModule } = NativeModules;

// Wrap and export methods

export function generateCSR(cn: string): Promise<string> {
  return CSRModule.generateCSR(cn);
}

export function connect(options: {
  host: string;
  port: number;
  clientId: string;
  cert: string;
  key: string;
}): Promise<void> {
  return MqttModule.connect(options);
}

export function publish(topic: string, message: string): Promise<void> {
  return MqttModule.publish(topic, message);
}

export function subscribe(topic: string): Promise<void> {
  return MqttModule.subscribe(topic);
}

export function disconnect(): Promise<void> {
  return MqttModule.disconnect();
}

export default {
  generateCSR,
  connect,
  publish,
  subscribe,
  disconnect,
};
