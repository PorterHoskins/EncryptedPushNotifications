import Vapor
import Foundation

extension Droplet {
    func setupRoutes() throws {
        
        post("test") { request in
            guard let publicKeyEncoded = request.json?["publicKey"]?.string, let publicKeyData = Data(base64Encoded: publicKeyEncoded) else {
                throw Abort(.badRequest)
            }
            
            let keyDictionary: [String: Any] = [
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String: 2048,
                ]
            
            var error: Unmanaged<CFError>?
            guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, keyDictionary as CFDictionary, &error) else {
                if let error = error {
                    print("Error getting public key: \(error.takeRetainedValue() as Error)")
                }
                
                throw Abort(.badRequest)
            }
            
            
            guard let cipherText = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA512, "This is a test".data(using: .utf8)! as CFData, &error) else {
                if let error = error {
                    print("Error encrypting message: \(error.takeRetainedValue() as Error)")
                }
                
                throw Abort(.badRequest)
            }
            
            return cipherText as Data
        }
        
    }
}
