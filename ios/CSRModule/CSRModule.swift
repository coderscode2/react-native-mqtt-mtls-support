import CryptoKit
import Foundation
import OpenSSLHelper

@objc(CSRModule)
class CSRModule: NSObject {

    @objc
    func generateCSR(_ subjectInfo: [String: Any],
                     error outError: NSErrorPointer) -> String? {
        guard let commonName = subjectInfo["CN"] as? String, !commonName.isEmpty else {
            outError?.pointee = NSError(domain: "CSRGenerationError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Common Name (CN) is required and cannot be empty."
            ])
            return nil
        }

        let userId = subjectInfo["userId"] as? String ?? ""
        let country = subjectInfo["country"] as? String ?? ""
        let state = subjectInfo["state"] as? String ?? ""
        let locality = subjectInfo["locality"] as? String ?? ""
        let organization = subjectInfo["organization"] as? String ?? ""
        let organizationalUnitName = subjectInfo["organizationalUnitName"] as? String ?? ""

        do {
            let privateKey = P256.Signing.PrivateKey()
            let publicKey = privateKey.publicKey

            let privateKeyDER = privateKey.rawRepresentation
            let publicKeyDER = publicKey.rawRepresentation

            guard let privateKeyPtr = privateKeyDER.withUnsafeBytes({ ptr in
                convert_to_evp_pkey(UnsafeMutablePointer(mutating: ptr.baseAddress!.assumingMemoryBound(to: UInt8.self)), Int32(privateKeyDER.count), 1)
            }) else {
                throw NSError(domain: "CSRGenerationError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert private key to EVP_PKEY."])
            }

            guard let x509Req = create_x509_request() else {
                cleanup_evp_pkey(privateKeyPtr)
                throw NSError(domain: "CSRGenerationError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create X509 request."])
            }

            let success = publicKeyDER.withUnsafeBytes { ptr in
                set_public_key(x509Req, UnsafeMutablePointer(mutating: ptr.baseAddress!.assumingMemoryBound(to: UInt8.self)), Int32(publicKeyDER.count))
            }
            guard success != 0 else {
                cleanup_x509_request(x509Req)
                cleanup_evp_pkey(privateKeyPtr)
                throw NSError(domain: "CSRGenerationError", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to set public key."])
            }

            guard let subjectName = create_x509_name() else {
                cleanup_x509_request(x509Req)
                cleanup_evp_pkey(privateKeyPtr)
                throw NSError(domain: "CSRGenerationError", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to create X509 name."])
            }

            try addX509NameEntry(subjectName, field: "CN", value: commonName)
            if !country.isEmpty { try addX509NameEntry(subjectName, field: "C", value: country) }
            if !state.isEmpty { try addX509NameEntry(subjectName, field: "ST", value: state) }
            if !locality.isEmpty { try addX509NameEntry(subjectName, field: "L", value: locality) }
            if !organization.isEmpty { try addX509NameEntry(subjectName, field: "O", value: organization) }
            if !organizationalUnitName.isEmpty { try addX509NameEntry(subjectName, field: "OU", value: organizationalUnitName) }
            if !userId.isEmpty { try addX509NameEntry(subjectName, field: "UID", value: userId) }

            guard set_subject_name(x509Req, subjectName) != 0 else {
                cleanup_x509_name(subjectName)
                cleanup_x509_request(x509Req)
                cleanup_evp_pkey(privateKeyPtr)
                throw NSError(domain: "CSRGenerationError", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to set subject name."])
            }

            guard sign_x509_request(x509Req, privateKeyPtr) != 0 else {
                cleanup_x509_name(subjectName)
                cleanup_x509_request(x509Req)
                cleanup_evp_pkey(privateKeyPtr)
                throw NSError(domain: "CSRGenerationError", code: -7, userInfo: [NSLocalizedDescriptionKey: "Failed to sign CSR."])
            }

            var derLength: Int32 = 0
            guard let derPtr = export_csr_to_der(x509Req, &derLength) else {
                cleanup_x509_name(subjectName)
                cleanup_x509_request(x509Req)
                cleanup_evp_pkey(privateKeyPtr)
                throw NSError(domain: "CSRGenerationError", code: -8, userInfo: [NSLocalizedDescriptionKey: "Failed to export CSR to DER."])
            }

            let csrData = Data(bytes: derPtr, count: Int(derLength))
            free(derPtr)

            let csrBase64 = csrData.base64EncodedString(options: .lineLength64Characters)
            let pem = "-----BEGIN CERTIFICATE REQUEST-----\n\(csrBase64)\n-----END CERTIFICATE REQUEST-----"

            cleanup_x509_name(subjectName)
            cleanup_x509_request(x509Req)
            cleanup_evp_pkey(privateKeyPtr)

            return pem
        } catch {
            outError?.pointee = error as NSError
            return nil
        }
    }

    private func addX509NameEntry(_ name: OpaquePointer, field: String, value: String) throws {
        let result = field.withCString { fieldPtr in
            value.withCString { valuePtr in
                add_x509_name_entry(name, fieldPtr, valuePtr)
            }
        }
        guard result != 0 else {
            throw NSError(domain: "CSRGenerationError", code: -9, userInfo: [NSLocalizedDescriptionKey: "Failed to add X509 name entry for \(field)."])
        }
    }
}
