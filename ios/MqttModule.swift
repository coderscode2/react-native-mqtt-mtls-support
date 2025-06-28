import Foundation
import CFNetwork          
import CocoaMQTT

@objc(MqttModule)
class MqttModule: NSObject {
    
    private var mqtt: CocoaMQTT?

    @objc(connect:clientId:clientCertPem:privateKeyPem:rootCaPem:successCallback:errorCallback:)
    func connect(broker: String,
                 clientId: String,
                 clientCertPem: String,
                 privateKeyPem: String,
                 rootCaPem: String,
                 successCallback: @escaping RCTResponseSenderBlock,
                 errorCallback: @escaping RCTResponseSenderBlock) {
        
        guard let host = URL(string: broker)?.host else {
            errorCallback(["Invalid broker URL"])
            return
        }

        let mqtt = CocoaMQTT(clientID: clientId, host: host, port: 8883)
        mqtt.enableSSL = true
        mqtt.allowUntrustCACertificate = true // only for development
        
        do {
            let sslSettings = try buildSSLSettings(
                clientCertPem: clientCertPem,
                privateKeyPem: privateKeyPem,
                rootCaPem: rootCaPem
            )
            mqtt.sslSettings = sslSettings
        } catch {
            errorCallback(["SSL setup failed: \(error.localizedDescription)"])
            return
        }

        mqtt.didConnectAck = { _, ack in
            if ack == .accept {
                successCallback(["Connected to \(broker)"])
            } else {
                errorCallback(["MQTT connect failed: \(ack)"])
            }
        }

        mqtt.didDisconnect = { _, err in
            if let err = err {
                print("MQTT disconnected: \(err.localizedDescription)")
            }
        }

        mqtt.connect()
        self.mqtt = mqtt
    }

    private func buildSSLSettings(clientCertPem: String,
                                  privateKeyPem: String,
                                  rootCaPem: String) throws -> [String: NSObject] {

        func loadIdentity(cert: String, key: String) throws -> SecIdentity {
            let p12data = try pemToP12(certPem: cert, keyPem: key)
            var items: CFArray?
            let options = [kSecImportExportPassphrase as NSString: ""]
            let status = SecPKCS12Import(p12data as CFData, options as CFDictionary, &items)
            guard status == errSecSuccess,
                  let array = items as? [[String: Any]],
                  let secId = array.first?[kSecImportItemIdentity as String] as? SecIdentity else {
                throw NSError(domain: "SSL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to import identity"])
            }
            return secId
        }

        let identity = try loadIdentity(cert: clientCertPem, key: privateKeyPem)
        let rootCert = try pemToDerCert(pem: rootCaPem)

        return [
            kCFStreamSSLIsServer as String: false as NSObject,
            kCFStreamSSLCertificates as String: [identity] as NSObject,
            kCFStreamSSLPeerName as String: kCFNull,
            kCFStreamSSLValidatesCertificateChain as String: true as NSObject,
            kCFStreamSSLTrustedRoots as String: [rootCert] as NSObject
        ]
    }

    private func pemToP12(certPem: String, keyPem: String) throws -> Data {
        let certClean = certPem.trimmingCharacters(in: .whitespacesAndNewlines)
        let keyClean = keyPem.trimmingCharacters(in: .whitespacesAndNewlines)

        let tmp = FileManager.default.temporaryDirectory
        let certURL = tmp.appendingPathComponent("temp_cert.pem")
        let keyURL  = tmp.appendingPathComponent("temp_key.pem")
        let p12URL  = tmp.appendingPathComponent("bundle.p12")
        
        try certClean.write(to: certURL, atomically: true, encoding: .utf8)
        try keyClean.write(to: keyURL, atomically: true, encoding: .utf8)

        let cmd = """
        openssl pkcs12 -export -out \(p12URL.path) -inkey \(keyURL.path) -in \(certURL.path) -password pass:
        """
        let result = try shell(cmd)
        guard result.exitCode == 0 else {
            throw NSError(domain: "SSL", code: -2, userInfo: [NSLocalizedDescriptionKey: result.output])
        }

        return try Data(contentsOf: p12URL)
    }

    private func pemToDerCert(pem: String) throws -> SecCertificate {
        let b64 = pem
            .components(separatedBy: .newlines)
            .filter { !$0.contains("BEGIN") && !$0.contains("END") }
            .joined()
        guard let data = Data(base64Encoded: b64),
              let cert = SecCertificateCreateWithData(nil, data as CFData) else {
            throw NSError(domain: "SSL", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid CA certificate"])
        }
        return cert
    }

    private func shell(_ command: String) throws -> (output: String, exitCode: Int32) {
        let task = Foundation.Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        return (String(decoding: data, as: UTF8.self), task.terminationStatus)
    }
}
