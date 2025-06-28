export declare function generateCSR(cn: string): Promise<string>;
export declare function connect(options: {
    host: string;
    port: number;
    clientId: string;
    cert: string;
    key: string;
}): Promise<void>;
export declare function publish(topic: string, message: string): Promise<void>;
export declare function subscribe(topic: string): Promise<void>;
export declare function disconnect(): Promise<void>;
declare const _default: {
    generateCSR: typeof generateCSR;
    connect: typeof connect;
    publish: typeof publish;
    subscribe: typeof subscribe;
    disconnect: typeof disconnect;
};
export default _default;
