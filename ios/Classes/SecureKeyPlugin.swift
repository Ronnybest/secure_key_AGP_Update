import Flutter
import UIKit
import AudioToolbox

public class SecureKeyPlugin: NSObject, FlutterPlugin {
    var controller:AppKeyPair?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_key", binaryMessenger: registrar.messenger())
    let instance = SecureKeyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     
      if call.method == "initialize"{
          initialize(call:call,result: result)
      }else if call.method == "getPublicKey"{
          getPublicKey(result: result)
      }else if call.method == "createPairKey"{
          createPairKey(result: result)
      }else if call.method == "deleteKey"{
          deleteKey(result: result)
      }else if call.method == "signSha256"{
          signSha256(call: call, result: result)
      }else{
          result(FlutterMethodNotImplemented)
      }
  }
    
    private func initialize(call:FlutterMethodCall,result: @escaping FlutterResult){
        guard controller == nil else{
            result(FlutterError(code: String(describing: KeyPairError.INIT), message: "Plugin init", details: nil))
          return
        }
        if let args = call.arguments as? Dictionary<String, Any>,
           let size = args["size"] as? Int
        {
            controller = AppKeyPair(size: size)
            result(true)
        }else{
            result(FlutterError(code: String(describing: KeyPairError.BAD_ARGS),message: "Size argument not found",details: nil))
        }
    }
    
    private func getPublicKey(result:@escaping FlutterResult){
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        print("\n-----GET PUBLIC KEY-----\n")
        do{
            let publicKey:String? = try controller!.getPublicKey()
            print("----1001-----")
            
            guard !(publicKey ?? "").isEmpty else{
                print("----1002-----")
                result(FlutterError(code: String(describing: KeyPairError.NOT_FOUND) ,message: "Public key not found",details: nil))
                return
            }
            print("----1003-----")
            result(publicKey)
        }catch
            KeyPairError.NOT_FOUND{
            result(FlutterError(code: "PUBLIC_NOT_FOUND", message: "Public key not founded", details: nil))
        }
        catch{
            result(FlutterError(code: "UNKNOWN", message: "Unknown error", details: nil))
        }
        print("\n-----------------------------\n")
    }

    private func createPairKey(result:@escaping FlutterResult){
        print("\n-----CREATE-----\n")
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        do{
            let created:Bool = try controller!.createRsaKeyPair()
            result(created)
           print("Success created key pair")
        }catch KeyPairError.CREATE_FAIL{
            result(FlutterError(code: String(describing: KeyPairError.CREATE_FAIL), message: "Key pair created fail", details: nil))
        }
        catch{
            result(FlutterError(code: String(describing: KeyPairError.UNKNOWN), message: "Unknown error", details: nil))
        }
        print("\n-----------------------------\n")
    }
    
    private func deleteKey(result:@escaping FlutterResult) {
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        do{
          let deleted:Bool = try controller!.deleteKey()
          result(deleted)
        }catch KeyPairError.REMOVE_FAIL{
            result(FlutterError(code: String(describing: KeyPairError.REMOVE_FAIL), message: "Delete key fail", details: nil))
        }catch{
            result(FlutterError(code: String(describing: KeyPairError.UNKNOWN), message: "Unknown error", details: nil))
        }
    }
    
    private func signSha256(call:FlutterMethodCall,result: @escaping FlutterResult){
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        if let args = call.arguments as? Dictionary<String, Any>,
           let input = args["inputSha256"] as? String
        {
            do{
                let signature:String? = try controller!.signSha256(input: input)
                guard signature != nil else{
                    result(FlutterError(code: String(describing: KeyPairError.SIGNATURE_FAIL), message: "Signature not founded", details:nil))
                    return
                }
                result(signature)
            }catch KeyPairError.SIGNATURE_FAIL{
                result(FlutterError(code: String(describing: KeyPairError.SIGNATURE_FAIL), message: "Signature not founded", details:nil))
            }catch{
                result(FlutterError(code: String(describing: KeyPairError.UNKNOWN), message: "Unknown error", details: nil))
            }
           
        }else{
            result(FlutterError(code: String(describing: KeyPairError.BAD_ARGS),message: "Input argument not found",details: nil))
        }
    }
    
    
    
//    private func getBatteryLevel(result: FlutterResult){
//        do{
//            let appBundle: String =  Bundle.main.bundleIdentifier!
//            let tag = appBundle.data(using: .utf8)!
//            print("TAG")
//            print(tag)
//
//            let access = SecAccessControlCreateWithFlags(
//                kCFAllocatorDefault,
//                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
//                .privateKeyUsage,
//                nil)!
//
//
//
//            let attributes: NSDictionary = [
//                kSecAttrKeyType: kSecAttrKeyTypeRSA,
//                kSecAttrKeySizeInBits: 4096,
//                kSecPublicKeyAttrs:[
//                    kSecAttrIsPermanent: true,
//                    kSecAttrApplicationTag: tag,
//                ],
//                kSecPrivateKeyAttrs: [
//                    kSecAttrIsPermanent: true,
//                    kSecAttrApplicationTag: tag,
//                ]
//            ]
//
//
//
//            var error: Unmanaged<CFError>?
//            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
//                print("Error create keys")
//                print(error!.takeRetainedValue())
//                throw error!.takeRetainedValue() as Error
//            }
//
//            let publicKey = SecKeyCopyPublicKey(privateKey)!
//
//            let key = publicKey
//            guard let data = SecKeyCopyExternalRepresentation(key, &error) as CFData? else {
//                throw error!.takeRetainedValue() as Error
//            }
//
//
//            print("Private")
//            print(privateKey.self)
//
//            print("Public")
//            print(publicKey)
//            print("Real Public Key")
//            print(data)
//
//
//
//            let string = "Hello, world!"
//            let stringSha256 = string.sha256()
//            let cfData = stringSha256.data(using: .utf8)! as CFData
//
//            print("CFdata")
//            print(cfData)
//
//            let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePSSSHA256
//
//
//
//           print("----")
//            print(algorithm)
//            guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
//                print("AlgorithmSupported")
//                print("false")
//                return
//            }
//
//            guard let signature = SecKeyCreateSignature(privateKey,
//                                                        algorithm,
//                                                        cfData as CFData,
//                                                        &error) as Data? else {
//                print("SG ERROR")
//                print(error!.takeRetainedValue())
//                                                            throw error!.takeRetainedValue() as Error
//            }
//
//
//            print("Signature")
//            print(signature)
//
//
//            guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
//                throw error!.takeRetainedValue() as Error
//            }
//
//
//            guard SecKeyVerifySignature(publicKey,
//                                        algorithm,
//                                        cfData as CFData,
//                                        signature as CFData,
//                                        &error) else {
//                print("Signature error")
//                print(error!.takeRetainedValue())
//                throw error!.takeRetainedValue() as Error
//            }
//            print("success")
//
//
//
//            result(100)
//
//        }catch{}
//
//    }
}
