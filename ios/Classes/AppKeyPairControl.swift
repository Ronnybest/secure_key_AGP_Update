//
//  AppKeyPairControl.swift
//  secure_key
//
//  Created by Бекбоосун Абдылдаев on 27/4/23.
//

import Flutter
import Foundation

class AppKeyPair{
    var privateKey:SecKey?
    let size:Int = 4096
    
    func getPrivatekey() throws {
     
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
        
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeyPairError.notFoundPrivateKey }
        let key = item as! SecKey
        
        print(key)
    }
    
    func createRsaKeyPair(result: FlutterResult) throws -> Bool {
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
        
        let attributes: NSDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: size,
            kSecPublicKeyAttrs:[
                kSecAttrIsPermanent: true,
                kSecAttrApplicationTag: tag,
            ],
            kSecPrivateKeyAttrs: [
                kSecAttrIsPermanent: true,
                kSecAttrApplicationTag: tag,
            ]
        ]
        
        do{
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                throw error!.takeRetainedValue() as Error
            }
            privateKey = key
            
            let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tag,
                                           kSecValueRef as String: key]
            
            let status = SecItemAdd(addquery as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw KeyPairError.badCreate
            }
            
            print("PrivateKeyRef")
            print(key)
            
            guard let data = SecKeyCopyExternalRepresentation(key, &error) as CFData? else {
                throw error!.takeRetainedValue() as Error
            }
            
            print("Real Private Key")
            print(data)
            
            
            return true
        }catch {
            throw KeyPairError.badCreate
        }
    }
    
    func getPublicKey(result:FlutterResult) throws -> SecKey{
        if privateKey != nil{
            let publicKey = SecKeyCopyPublicKey(privateKey!)!
            print("PublicKeyRef")
            print(publicKey)
            var error: Unmanaged<CFError>?
            
            guard let data = SecKeyCopyExternalRepresentation(publicKey, &error) as CFData? else {
                throw error!.takeRetainedValue() as Error
            }
            
            print("Public Key")
            print(data)
            
            return publicKey
        }
        throw KeyPairError.notFoundPublicKey
    }
    
//    func getPrivateKey(result:FlutterResult) throws -> SecKey{
//
//    }
}


enum KeyPairError: Error {
    case badCreate
    case notFoundPublicKey
    case notFoundPrivateKey
    case signatureCreate
    case signatureVerify
}
