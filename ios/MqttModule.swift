import Foundation
import CocoaMQTT
import CFNetwork
import CoreFoundation

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
        mqtt.allowUntrustCACertificate = true // For development only

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
            let options: NSDictionary = [kSecImportExportPassphrase as NSString: ""]
            let status = SecPKCS12Import(p12data as CFData, options, &items)

            guard status == errSecSuccess,
                  let array = items as? [[String: Any]],
                  let secIdRaw = array.first?[kSecImportItemIdentity as String] else {
                throw NSError(domain: "SSL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to import identity"])
            }

            let secId = secIdRaw as AnyObject
            guard CFGetTypeID(secId) == SecIdentityGetTypeID() else {
                throw NSError(domain: "SSL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid identity type"])
            }

            return secId as! SecIdentity
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

        let tempDir = FileManager.default.temporaryDirectory
        let certPath = tempDir.appendingPathComponent("cert.pem")
        let keyPath = tempDir.appendingPathComponent("key.pem")
        let p12Path = tempDir.appendingPathComponent("bundle.p12")

        try certClean.write(to: certPath, atomically: true, encoding: .utf8)
        try keyClean.write(to: keyPath, atomically: true, encoding: .utf8)

        let command = """
        openssl pkcs12 -export -out \(p12Path.path) -inkey \(keyPath.path) -in \(certPath.path) -password pass:
        """

        let result = try shell(command)
        guard result.exitCode == 0 else {
            throw NSError(domain: "SSL", code: -2, userInfo: [NSLocalizedDescriptionKey: result.output])
        }

        return try Data(contentsOf: p12Path)
    }

    private func pemToDerCert(pem: String) throws -> SecCertificate {
        let lines = pem.components(separatedBy: "\n").filter { !$0.contains("BEGIN") && !$0.contains("END") }
        let base64 = lines.joined()
        guard let data = Data(base64Encoded: base64) else {
            throw NSError(domain: "SSL", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid CA cert"])
        }
        guard let cert = SecCertificateCreateWithData(nil, data as CFData) else {
            throw NSError(domain: "SSL", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to create certificate"])
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
        return (String(data: data, encoding: .utf8) ?? "", task.terminationStatus)
    }
}
