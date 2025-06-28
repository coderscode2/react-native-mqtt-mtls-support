import { NativeModules, NativeEventEmitter } from 'react-native';

const { CSRModule, MqttModule } = NativeModules;

const mqttEmitter = new NativeEventEmitter(MqttModule);

type GenerateCSRParams = {
  cn?: string;
  serialNum?: string;
  userId?: string;
  country?: string;
  state?: string;
  locality?: string;
  organization?: string;
  organizationalUnit?: string;
};

type ConnectMqttParams = {
  broker: string;
  clientId: string;
  clientCertPem: string;
  privateKeyPem: string;
  rootCaPem: string;
};

type MqttEventHandler = (message: string) => void;

export const generateCSR = async ({
  cn,
  serialNum,
  userId,
  country,
  state,
  locality,
  organization,
  organizationalUnit,
}: GenerateCSRParams): Promise<{
  csr: string;
  privateKey: string;
  publicKey: string;
}> => {
  try {
    const result = await CSRModule.generateCSR(
      cn || '',
      serialNum || '',
      userId || '',
      country || '',
      state || '',
      locality || '',
      organization || '',
      organizationalUnit || ''
    );

    return {
      csr: result.csr,
      privateKey: result.privateKey,
      publicKey: result.publicKey,
    };
  } catch (err: any) {
    throw new Error(err?.message || 'CSR generation failed');
  }
};

export const connectMqtt = ({
  broker,
  clientId,
  clientCertPem,
  privateKeyPem,
  rootCaPem,
}: ConnectMqttParams): Promise<string> => {
  return new Promise((resolve, reject) => {
    MqttModule.connect(
      broker,
      clientId,
      clientCertPem,
      privateKeyPem,
      rootCaPem,
      (successMessage: string) => resolve(successMessage),
      (errorMessage: string) => reject(new Error(errorMessage))
    );
  });
};

export const subscribe = (topic: string, qos: number = 0): void => {
  MqttModule.subscribe(topic, qos);
};

export const publish = (
  topic: string,
  message: string,
  qos: number = 0,
  retained: boolean = false
): void => {
  MqttModule.publish(topic, message, qos, retained);
};

export const disconnect = (): Promise<string> => {
  return new Promise((resolve) => {
    MqttModule.disconnect((msg: string) => resolve(msg));
  });
};

export const onMqttEvent = (
  eventName: string,
  handler: MqttEventHandler
) => {
  return mqttEmitter.addListener(eventName, handler);
};

export default {
  generateCSR,
  connectMqtt,
  subscribe,
  publish,
  disconnect,
  onMqttEvent,
};
