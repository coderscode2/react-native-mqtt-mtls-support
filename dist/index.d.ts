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
export declare const generateCSR: ({ cn, serialNum, userId, country, state, locality, organization, organizationalUnit, }: GenerateCSRParams) => Promise<{
    csr: string;
    privateKey: string;
    publicKey: string;
}>;
export declare const connectMqtt: ({ broker, clientId, clientCertPem, privateKeyPem, rootCaPem, }: ConnectMqttParams) => Promise<string>;
export declare const subscribe: (topic: string, qos?: number) => void;
export declare const publish: (topic: string, message: string, qos?: number, retained?: boolean) => void;
export declare const disconnect: () => Promise<string>;
export declare const onMqttEvent: (eventName: string, handler: MqttEventHandler) => import("react-native").EmitterSubscription;
declare const _default: {
    generateCSR: ({ cn, serialNum, userId, country, state, locality, organization, organizationalUnit, }: GenerateCSRParams) => Promise<{
        csr: string;
        privateKey: string;
        publicKey: string;
    }>;
    connectMqtt: ({ broker, clientId, clientCertPem, privateKeyPem, rootCaPem, }: ConnectMqttParams) => Promise<string>;
    subscribe: (topic: string, qos?: number) => void;
    publish: (topic: string, message: string, qos?: number, retained?: boolean) => void;
    disconnect: () => Promise<string>;
    onMqttEvent: (eventName: string, handler: MqttEventHandler) => import("react-native").EmitterSubscription;
};
export default _default;
