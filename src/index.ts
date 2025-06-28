import { NativeModules } from 'react-native';

const { MqttMtlsSupport, CSR } = NativeModules;

export const generateCSR = (...args: any) => CSR.generateCSR(...args);

export default MqttMtlsSupport;