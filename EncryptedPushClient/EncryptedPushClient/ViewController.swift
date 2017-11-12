//
//  ViewController.swift
//  EncyptedPushTest
//
//  Created by Porter Hoskins on 11/11/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import UIKit

let keyAttributes: [String: Any] = [
    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
    kSecAttrKeySizeInBits as String: 2048,
    kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: "com.porterhoskins.testKey".data(using: .utf8)!,
        kSecAttrAccessGroup as String: keychainAccessGroupName,
    ]
]

let keychainAccessGroupName = "9WF89A89NX.com.porterhoskins.EncryptedPushTest"

class ViewController: UIViewController {
    
    var privateKey: SecKey?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "com.porterhoskins.testKey".data(using: .utf8)!,
            kSecAttrAccessGroup as String: keychainAccessGroupName
        ]
        
        SecItemDelete(query as CFDictionary)
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(keyAttributes as CFDictionary, &error) else {
            print("\(error!.takeRetainedValue() as Error)")
            
            return
        }
        
        self.privateKey = privateKey
    }

    @IBAction func sendPushTapped(_ sender: Any) {
        var error: Unmanaged<CFError>?
        
        let publicKey = SecKeyCopyPublicKey(privateKey!)
        let publicKeyString = (SecKeyCopyExternalRepresentation(publicKey!, &error)! as Data).base64EncodedString()
        
        let json = try! JSONSerialization.data(withJSONObject: ["publicKey": publicKeyString], options: [])
        
        var request = URLRequest(url: URL(string: "http://10.152.104.115:8080/test")!)
        request.httpBody = json
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending key \(error)")
            }
            
            guard let data = data else { return }
            
            var encryptError: Unmanaged<CFError>?
            guard let decrypted = SecKeyCreateDecryptedData(self.privateKey!, .rsaEncryptionOAEPSHA512, data as CFData, &encryptError) else {
                if let encryptError = encryptError {
                    print("Error sending key \(encryptError.takeRetainedValue() as Error)")
                }
                
                return
            }
            
            let string = String(data: decrypted as Data, encoding: .utf8)
            print(string)
        }
        
        task.resume()
    }
    
}

