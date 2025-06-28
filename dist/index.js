"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateCSR = generateCSR;
exports.connect = connect;
exports.publish = publish;
exports.subscribe = subscribe;
exports.disconnect = disconnect;
const react_native_1 = require("react-native");
const { CSRModule, MqttModule } = react_native_1.NativeModules;
// Wrap and export methods
function generateCSR(cn) {
    return CSRModule.generateCSR(cn);
}
function connect(options) {
    return MqttModule.connect(options);
}
function publish(topic, message) {
    return MqttModule.publish(topic, message);
}
function subscribe(topic) {
    return MqttModule.subscribe(topic);
}
function disconnect() {
    return MqttModule.disconnect();
}
exports.default = {
    generateCSR,
    connect,
    publish,
    subscribe,
    disconnect,
};
