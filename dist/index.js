"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMqttEvent = exports.disconnect = exports.publish = exports.subscribe = exports.connectMqtt = exports.generateCSR = void 0;
const react_native_1 = require("react-native");
const { CSRModule, MqttModule } = react_native_1.NativeModules;
const mqttEmitter = new react_native_1.NativeEventEmitter(MqttModule);
const generateCSR = async ({ cn, serialNum, userId, country, state, locality, organization, organizationalUnit, }) => {
    try {
        const result = await CSRModule.generateCSR(cn || '', serialNum || '', userId || '', country || '', state || '', locality || '', organization || '', organizationalUnit || '');
        return {
            csr: result.csr,
            privateKey: result.privateKey,
            publicKey: result.publicKey,
        };
    }
    catch (err) {
        throw new Error((err === null || err === void 0 ? void 0 : err.message) || 'CSR generation failed');
    }
};
exports.generateCSR = generateCSR;
const connectMqtt = ({ broker, clientId, clientCertPem, privateKeyPem, rootCaPem, }) => {
    return new Promise((resolve, reject) => {
        MqttModule.connect(broker, clientId, clientCertPem, privateKeyPem, rootCaPem, (successMessage) => resolve(successMessage), (errorMessage) => reject(new Error(errorMessage)));
    });
};
exports.connectMqtt = connectMqtt;
const subscribe = (topic, qos = 0) => {
    MqttModule.subscribe(topic, qos);
};
exports.subscribe = subscribe;
const publish = (topic, message, qos = 0, retained = false) => {
    MqttModule.publish(topic, message, qos, retained);
};
exports.publish = publish;
const disconnect = () => {
    return new Promise((resolve) => {
        MqttModule.disconnect((msg) => resolve(msg));
    });
};
exports.disconnect = disconnect;
const onMqttEvent = (eventName, handler) => {
    return mqttEmitter.addListener(eventName, handler);
};
exports.onMqttEvent = onMqttEvent;
exports.default = {
    generateCSR: exports.generateCSR,
    connectMqtt: exports.connectMqtt,
    subscribe: exports.subscribe,
    publish: exports.publish,
    disconnect: exports.disconnect,
    onMqttEvent: exports.onMqttEvent,
};
