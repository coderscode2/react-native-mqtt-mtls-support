"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateCSR = void 0;
const react_native_1 = require("react-native");
const { MqttMtlsSupport, CSR } = react_native_1.NativeModules;
const generateCSR = (...args) => CSR.generateCSR(...args);
exports.generateCSR = generateCSR;
exports.default = MqttMtlsSupport;
