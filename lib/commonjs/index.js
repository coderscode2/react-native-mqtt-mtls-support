"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const react_native_1 = require("react-native");
const LINKING_ERROR = `The package 'react-native-mqtt-mtls-support' doesn't seem to be linked.`;
const MqttModule = react_native_1.NativeModules.MqttModule
    ? react_native_1.NativeModules.MqttModule
    : new Proxy({}, {
        get() {
            throw new Error(LINKING_ERROR);
        },
    });
exports.default = MqttModule;
