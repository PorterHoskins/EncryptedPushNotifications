//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Porter Hoskins on 11/11/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import UserNotifications

import OneSignal

let keychainAccessGroupName = "9WF89A89NX.com.porterhoskins.EncryptedPushTest"

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        print("got push")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: "com.porterhoskins.testKey".data(using: .utf8)!,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: keychainAccessGroupName
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        self.receivedRequest = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            var error: Unmanaged<CFError>?
            
            if status == errSecSuccess, let bodyData = Data(base64Encoded: bestAttemptContent.body), let data = SecKeyCreateDecryptedData(item as! SecKey, .rsaEncryptionOAEPSHA512, bodyData as CFData, &error) {
                bestAttemptContent.body = String(data: data as Data, encoding: .utf8) ?? "😵"
            } else {
                bestAttemptContent.body = "🤬"
            }
            
            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
}
