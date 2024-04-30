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
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeyPairError.PRIVATE_KEY_NOT_FOUND }
        let key = item as! SecKey
       
        return key;
    }
    
    
    //------------Get-Public-Key--------------
    func getPublicKey() throws -> String?{
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
     
        
        let privateKey:SecKey? = try getPrivatekey();
        let publicKey = SecKeyCopyPublicKey(privateKey!)
        
        guard publicKey != nil else{
            throw KeyPairError.NOT_FOUND
        }
        
        var error: Unmanaged<CFError>?

        guard let publicKeyExternalRep = SecKeyCopyExternalRepresentation(publicKey!, &error) as CFData? else {
            throw KeyPairError.UNKNOWN
        }
        
        
        let data = publicKeyExternalRep as Data
        
        let strPublicKeyPKCS1 = appendPrefixSuffixTo(data.base64EncodedString(options: .lineLength64Characters), prefix: "-----BEGIN RSA PUBLIC KEY-----\r\n", suffix: "\r\n-----END RSA PUBLIC KEY-----")

        let pemPrefixBuffer :[UInt8] = [
                  0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
                  0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
                  0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]
        
        var finalPemData = Data(bytes: pemPrefixBuffer as [UInt8], count: pemPrefixBuffer.count)
        finalPemData.append(data)
        
        let strPublicKeyPEM = appendPrefixSuffixTo(finalPemData.base64EncodedString(options: .lineLength64Characters), prefix: "-----BEGIN PUBLIC KEY-----\r\n", suffix: "\r\n-----END PUBLIC KEY-----")
        
        return strPublicKeyPEM
    }
    
    func getPublicKeyBytes() throws -> FlutterStandardTypedData{
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag = appBundle.data(using: .utf8)!
      
        let privateKey:SecKey? = try getPrivatekey();
        let publicKey = SecKeyCopyPublicKey(privateKey!)
        
        guard publicKey != nil else{
            throw KeyPairError.NOT_FOUND
        }
        
        var error: Unmanaged<CFError>?

        guard let cfData = SecKeyCopyExternalRepresentation(publicKey!, &error) as CFData? else {
            throw KeyPairError.UNKNOWN
        }
        return byteArray(from:cfData);
    }


   
    //------------Create-Rsa-Key-Pair--------------
    func createRsaKeyPair() throws -> Bool {
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag:String = appBundle
     
       
        let attributes: NSDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: size,
            kSecPrivateKeyAttrs: [
                kSecAttrIsPermanent: true,
                kSecAttrApplicationTag: tag.data(using: .utf8)!,//(tag+".private").data(using: .utf8)!,
            ]
        ]
        
        do{
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                throw KeyPairError.CREATE_FAIL
            }
      
            
            return true
        }catch {
            throw KeyPairError.CREATE_FAIL
        }
    }
  
    //------------Delete-Key--------------
    func deleteKey()throws->Bool{
        let appBundle: String =  Bundle.main.bundleIdentifier!
        let tag:Data = appBundle.data(using: .utf8)!
        let query: [String: Any] = [
               kSecClass as String: kSecClassKey,
               kSecAttrApplicationTag as String: tag
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess  {
            return true
        }
        
        if status == errSecItemNotFound {
            return false
        }
        throw KeyPairError.REMOVE_FAIL
    }
    
    func encryptWithRsa(plainText: String) throws -> String? {
        guard let data = plainText.data(using: .utf8) else { throw KeyPairError.INPUT_NOT_FOUND  }

        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256
        
        let privateKey:SecKey? = try getPrivatekey()
        let publicKey = SecKeyCopyPublicKey(privateKey!)
        guard publicKey != nil else{
            throw KeyPairError.NOT_FOUND
        }

        guard SecKeyIsAlgorithmSupported(publicKey!, .encrypt, algorithm) else { throw KeyPairError.ALGORITM_NOT_SUPPORTED }
        let maxChunkSize = 190
            
        var encryptedChunks: [Data] = []
            
        var startIndex = 0
        while startIndex < data.count {
            let endIndex = min(startIndex + maxChunkSize, data.count)
            let chunk = data[startIndex..<endIndex]
            var error: Unmanaged<CFError>?
            guard let encryptedData = SecKeyCreateEncryptedData(publicKey!,algorithm,chunk as CFData,&error) as Data? else {
                if let error = error {
                    print("Encryption error: \(error.takeRetainedValue())")
                }
                throw KeyPairError.ENCRYPT_ERROR
            }
            
            encryptedChunks.append(encryptedData)
            startIndex = endIndex
        }

        let encryptedData = Data(encryptedChunks.joined())
        return encryptedData.base64EncodedString()
    }
    
    func decryptWithRsa(cipherData: String) throws -> String? {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256
        let privateKey = try getPrivatekey()

        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else { throw KeyPairError.ALGORITM_NOT_SUPPORTED }
        let maxChunkSize = SecKeyGetBlockSize(privateKey)
        
        guard let encryptedData = Data(base64Encoded: cipherData) else {
            throw KeyPairError.BAD_ARGS
        }
        
        var decryptedChunks: [Data] = []
        
        var startIndex = 0
        while startIndex < encryptedData.count {
            let endIndex = min(startIndex + maxChunkSize, encryptedData.count)
            let chunk = encryptedData[startIndex..<endIndex]

            var error: Unmanaged<CFError>?
            guard let decryptedData = SecKeyCreateDecryptedData(privateKey,algorithm,chunk as CFData,&error) as Data? else {
                if let error = error {
                    print("Decryption error: \(error.takeRetainedValue())")
                }
                throw KeyPairError.DECRYPT_ERROR
            }
            
            decryptedChunks.append(decryptedData)
            startIndex = endIndex
        }
        
        let decryptedData = Data(decryptedChunks.joined())
        
        return String(data: decryptedData, encoding: .utf8)
    }
    
   
    
    //--------------Sign-Sha-256---------------
    func signSha256(input:String)throws->String?{
        let cfData = input.data(using: .utf8)! as CFData
         let privateKey = try getPrivatekey()
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        var error: Unmanaged<CFError>?
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm)else {
            throw KeyPairError.SIGNATURE_FAIL
        }
      
       guard let signature = SecKeyCreateSignature(privateKey,
                                                   algorithm,
                                                   cfData as CFData,
                                                   &error) as Data? else {
           throw KeyPairError.SIGNATURE_FAIL
       }
        return signature.base64EncodedString()
    }
    
    func signSha256Bytes(input:String)throws->FlutterStandardTypedData{
        let inputSha256 = input.sha256()
        let cfData = inputSha256.data(using: .utf8)! as CFData
        let privateKey = try getPrivatekey()
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        var error: Unmanaged<CFError>?
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm)else {
            throw KeyPairError.SIGNATURE_FAIL
        }
        guard let signature = SecKeyCreateSignature(privateKey,
                                                   algorithm,
                                                   cfData as CFData,
                                                   &error) as Data? else {
        throw KeyPairError.SIGNATURE_FAIL
       }
        return FlutterStandardTypedData(bytes: signature)
    }
    
    func byteArray(from cfData: CFData) -> FlutterStandardTypedData {
        let length = CFDataGetLength(cfData)
        var byteArray = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(cfData, CFRangeMake(0, length), &byteArray)
        let data = Data(byteArray)
        return FlutterStandardTypedData(bytes: data)
    }
    
    func appendPrefixSuffixTo(_ string: String, prefix: String, suffix: String) -> String {
        return "\(prefix)\(string)\(suffix)"
    }
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
    case ALGORITM_NOT_SUPPORTED
    case ENCRYPT_ERROR
    case DECRYPT_ERROR
    case INPUT_NOT_FOUND
}
