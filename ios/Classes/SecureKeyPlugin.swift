import Flutter
import UIKit
import AudioToolbox

public class SecureKeyPlugin: NSObject, FlutterPlugin {
    var vibration: Int = 1000

    let controller = AppKeyPair()
    var publicKey:SecKey?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "secure_key", binaryMessenger: registrar.messenger())
    let instance = SecureKeyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // result("iOS " + UIDevice.current.systemVersion)
//      guard call.method=="getBatteryLevel" else{
//          result(FlutterMethodNotImplemented)
//          return
//      }
//      self.getBatteryLevel(result: result)
      if call.method == "createPairKey"{
          createPairKey(result: result)
      }else if call.method == "getPublicKey"{
          getPublicKey(result: result)
      }else if call.method == "getPublicKeyData"{
          getPublicKeyData(result: result)
      }else if call.method == "getPrivatekey"{
          getPrivatekey(result: result)
      }else{
          result(FlutterMethodNotImplemented)
      }
  }
    

    private func createPairKey(result: FlutterResult){
        print("\n-----CREATE-----\n")
        do{
           try controller.createRsaKeyPair(result: result)
           print("Success created key pair")
        }catch KeyPairError.badCreate{
            result(FlutterError(code: "BAD_CREATE", message: "Key pair created exception", details: nil))
        }
        catch{
            result(FlutterError(code: "UNKNOWN", message: "Unknown error", details: nil))
        }
        print("\n-----------------------------\n")
    }
    
    private func getPublicKey(result: FlutterResult){
        print("\n-----GET PUBLIC KEY-----\n")
        do{
            try publicKey = controller.getPublicKey(result: result)
        }catch KeyPairError.notFoundPublicKey{
            result(FlutterError(code: "PUBLIC_NOT_FOUND", message: "Public key not founded", details: nil))
        }
        catch{
            result(FlutterError(code: "UNKNOWN", message: "Unknown error", details: nil))
        }
        print("\n-----------------------------\n")
    }
    
    private func getPrivatekey(result:FlutterResult){
        print("\n-----GET PRIVATE KEY-----\n")
        do{
           try controller.getPrivatekey()
        }catch KeyPairError.notFoundPrivateKey{
            print("<<<<<<<<<<<<<>>>>>>>>>>>>>")
            print("        <<ERROR>>         ")
            print(" <<Private key not found>>")
            print("<<<<<<<<<<<<<>>>>>>>>>>>>>")
        }catch {
            print("<<<<<<<<<<<<<>>>>>>>>>>>>>")
            print("        <<ERROR>>         ")
            print("       <<Unknown>>        ")
            print("<<<<<<<<<<<<<>>>>>>>>>>>>>")
        }
        print("\n-----------------------------\n")
    }
    
    private func getPublicKeyData(result: FlutterResult){
        print("\n-----GET PUBLIC KEY DATA-----\n")
        do{
            if publicKey != nil{
                var error: Unmanaged<CFError>?
                guard let data = SecKeyCopyExternalRepresentation(publicKey!, &error) as CFData? else {
                    print("PUBLIC DATA ERROR")
                    throw error!.takeRetainedValue() as Error
                    
                }
                print("RAW PUBLIC KEY")
                print(data)
                result(data)
                
            }
            if controller.privateKey != nil{
                var error: Unmanaged<CFError>?
                guard let data = SecKeyCopyExternalRepresentation(controller.privateKey!, &error) as CFData? else {
                    print("PRIVATE DATA ERROR")
                    throw error!.takeRetainedValue() as Error
                    
                }
                print("RAW PRIVATE KEY")
                print(data)
                result(data)
            }
        }catch{
            result(FlutterError(code: "UNKNOWN", message: "Unknown error", details: nil))
        }
        print("\n-----------------------------\n")
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
