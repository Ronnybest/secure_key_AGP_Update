//
//  AppKeyPairControl.swift
//  secure_key
//
//  Created by Бекбоосун Абдылдаев on 27/4/23.
//

import Flutter
import Foundation
import CloudKit

class AppKeyPair{
    let size:Int
    
    
    //------------Initilize--------------
    init(size:Int){
        self.size = size
    }
    
    //------------Private-Get-Private-key--------------
    private func getPrivatekey() throws ->SecKey{
        print("-----GET PRIVATE------")
        print("-----1------")
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
        print("-----2------")
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]
        print("-----3------")
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        print("-----4------")
        print(status)
        guard status == errSecSuccess else { throw KeyPairError.PRIVATE_KEY_NOT_FOUND }
        let key = item as! SecKey
        print("-----5------")
    
        return key;
    }
    
    
    //------------Get-Public-Key--------------
    func getPublicKey() throws -> String?{
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
        
        let getquery: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                kSecAttrApplicationTag as String: tag,
                kSecReturnData as String: true,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic
            ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw KeyPairError.NOT_FOUND
           }
        if let keyData = item as? Data {
                return keyData.base64EncodedString()
            } else {
                throw KeyPairError.NOT_FOUND
            }
        
//        let privateKey:SecKey? = try getPrivatekey();
//        print("-----101------")
//        let publicKey = SecKeyCopyPublicKey(privateKey!)!
//        print("-----102------")
//        var error: Unmanaged<CFError>?
//
//        guard let cfData = SecKeyCopyExternalRepresentation(publicKey, &error) as CFData? else {
//            throw KeyPairError.UNKNOWN
//        }
//        print("-----103------")
//        print(cfData)
//        let data = cfData as Data
//        print("-----104------")
//        print(data)
//        print(String(decoding: data, as: UTF8.self))
//        return String(decoding: data, as: UTF8.self)
    }

    //------------Create-Rsa-Key-Pair--------------
    func createRsaKeyPair() throws -> Bool {
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag:String = appBundle
        print("-----1------")
        let attributes: NSDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: size,
            kSecPublicKeyAttrs:[
                kSecAttrIsPermanent: true,
                kSecAttrApplicationTag: tag.data(using: .utf8)!, //(tag+".public").data(using: .utf8)!,
            ],
            kSecPrivateKeyAttrs: [
                kSecAttrIsPermanent: true,
                kSecAttrApplicationTag: tag.data(using: .utf8)!,//(tag+".private").data(using: .utf8)!,
            ]
        ]
        print("-----2------")
        
        do{
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                print("-----12------")
                throw KeyPairError.CREATE_FAIL
            }
            print("-----3------")
            
//            let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
//                                           kSecAttrApplicationTag as String: tag,
//                                           kSecValueRef as String: key]
//            print("-----4------")
//            let status = SecItemAdd(addquery as CFDictionary, nil)
//            guard status == errSecSuccess else {
//                print("-----13------")
//                print(status)
//                throw KeyPairError.CREATE_FAIL
//            }
//            print("-----5------")
//
//            print("PrivateKeyRef")
//            print(key)
//            print("-----6------")
//            guard let data = SecKeyCopyExternalRepresentation(key, &error) as CFData? else {
//                print("-----14------")
//                throw KeyPairError.CREATE_FAIL
//            }
//            print("-----7------")
//            print("Real Private Key")
//            print(data)
            
            
            return true
        }catch {
            print("-----11------")
            throw KeyPairError.CREATE_FAIL
        }
    }
  
    //------------Delete-Key--------------
    func deleteKey()throws->Bool{
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag:Data = appBundle.data(using: .utf8)!
        print("-------1--------")
        let query: [String: Any] = [
               kSecClass as String: kSecClassKey,
               kSecAttrApplicationTag as String: tag
        ]
        print("-------2-------")
        let status = SecItemDelete(query as CFDictionary)
        print("-------3--------")
        print(status)
        if status == errSecSuccess  {
            return true
        }
        
        if status == errSecItemNotFound {
            return false
        }
        throw KeyPairError.REMOVE_FAIL
    }
    
    //--------------Sign-Sha-256---------------
    func signSha256(input:String)throws->String?{
        print("-------1--------")
        print(input)
        let inputSha256 = input.sha256()
        print("-------2--------")
        print(inputSha256)
        let cfData = inputSha256.data(using: .utf8)! as CFData
        print("-------3--------")
        print(cfData)
        let privateKey = try getPrivatekey()
        print("-------4--------")
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePSSSHA256
        print("-------5--------")
        var error: Unmanaged<CFError>?
        print("-------6--------")
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            print("-------7ee--------")
            throw KeyPairError.SIGNATURE_FAIL
       }
        print("-------7--------")

       guard let signature = SecKeyCreateSignature(privateKey,
                                                   algorithm,
                                                   cfData as CFData,
                                                   &error) as Data? else {
           print("-------8e--------")
           throw KeyPairError.SIGNATURE_FAIL
       }
        print("-------8--------")
        return signature.base64EncodedString()
        
//        return String(decoding: signature, as: UTF8.self)
    }
    
//    private func getPrivateKey() throws -> SecKey?{
//        let appBundle: String =  Bundle.main.bundleIdentifier!
//        let tag:String = appBundle
//
//        let query: [String: Any] = [
//              kSecClass as String: kSecClassKey,
//              kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
//              kSecReturnRef as String: true
//        ]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//        guard status == errSecSuccess else {
//            print("Key retrieval error: \(status)")
//            return nil
//        }
//        return (item as! SecKey)
//    }
}


enum KeyPairError: Error {
    case NOT_INIT
    case INIT
    case BAD_ARGS
    case CREATE_FAIL
    case NOT_FOUND
    case CREATE_FAIL_NOT_FOUND
    case SIZE_NOT_FOUND
    case REMOVE_FAIL
    case PRIVATE_KEY_NOT_FOUND
    case SIGNATURE_FAIL
    case UNKNOWN
}
