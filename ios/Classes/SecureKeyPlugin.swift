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
      }else if call.method == "getPublicKeyBytes"{
          getPublicKeyBytes(result: result)
      }else if call.method == "signSha256Bytes"{
          signSha256Bytes(call: call, result: result)
      }else if call.method == "encryptWithRsa"{
          encryptWithRsa(call: call, result: result)
      }else if call.method == "decryptWithRsa" {
          decryptWithRsa(call: call, result: result)
      } else{
          result(FlutterMethodNotImplemented)
      }
  }
    
    private func initialize(call:FlutterMethodCall,result: @escaping FlutterResult){
        if controller != nil {
          result(true)
          return;
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
        do{
            let publicKey:String? = try controller!.getPublicKey()
            
            guard !(publicKey ?? "").isEmpty else{
                result(FlutterError(code: String(describing: KeyPairError.NOT_FOUND) ,message: "Public key not found",details: nil))
                return
            }
            result(publicKey)
        }catch
            KeyPairError.NOT_FOUND{
            result(FlutterError(code: "PUBLIC_NOT_FOUND", message: "Public key not founded", details: nil))
        }
        catch{
            result(FlutterError(code: "UNKNOWN", message: "Unknown error", details: nil))
        }
       }
    
    private func getPublicKeyBytes(result:@escaping FlutterResult){
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        do{
            let publicKey:FlutterStandardTypedData = try controller!.getPublicKeyBytes()
            result(publicKey)
        }
//        catch
//            KeyPairError.NOT_FOUND{
//            result(FlutterError(code: "PUBLIC_NOT_FOUND", message: "Public key not founded", details: nil))
//        }
        catch{
            result(nil)
//            result(FlutterError(code: "UNKNOWN", message: "Unknown error", details: nil))
        }
        }

    private func createPairKey(result:@escaping FlutterResult){
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        do{
            let created:Bool = try controller!.createRsaKeyPair()
            result(created)
        }catch KeyPairError.CREATE_FAIL{
            result(FlutterError(code: String(describing: KeyPairError.CREATE_FAIL), message: "Key pair created fail", details: nil))
        }
        catch{
            result(FlutterError(code: String(describing: KeyPairError.UNKNOWN), message: "Unknown error", details: nil))
        }
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
    
    private func encryptWithRsa(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard controller != nil else {
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        if let args = call.arguments as? Dictionary<String, Any>,
           let input = args["encryptInput"] as? String
        {
            do{
                let encryptedData:String? = try controller!.encryptWithRsa(plainText: input)
                result(encryptedData)
            }catch KeyPairError.ALGORITM_NOT_SUPPORTED {
                result(FlutterError(code: String(describing: KeyPairError.ALGORITM_NOT_SUPPORTED), message: "Algoritm support error", details: nil))
            }catch KeyPairError.NOT_FOUND{
                result(FlutterError(code: String(describing: KeyPairError.NOT_FOUND), message: "Public key not found", details: nil))
            }catch KeyPairError.ENCRYPT_ERROR {
                result(FlutterError(code: String(describing: KeyPairError.ENCRYPT_ERROR), message: "Encrypt failed", details: nil))
            }catch KeyPairError.INPUT_NOT_FOUND {
                result(FlutterError(code: String(describing: KeyPairError.INPUT_NOT_FOUND), message: "Encrypt failed, input nil", details: nil))
            }catch {
                result(FlutterError(code: String(describing: KeyPairError.ENCRYPT_ERROR), message: "Encryption failed, Error occurred: \(error)", details: nil))
            }
           
        }else{
            result(FlutterError(code: String(describing: KeyPairError.BAD_ARGS),message: "Input argument not found",details: nil))
        }
    }
    
    private func decryptWithRsa(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard controller != nil else {
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        if let args = call.arguments as? Dictionary<String, Any>,
           let input = args["decryptInput"] as? String
        {
            do{
                let decryptedData:String? = try controller!.decryptWithRsa(cipherData: input)
                result(decryptedData)
            }catch KeyPairError.ALGORITM_NOT_SUPPORTED {
                result(FlutterError(code: String(describing: KeyPairError.ALGORITM_NOT_SUPPORTED), message: "Algoritm support error", details: nil))
            }catch KeyPairError.NOT_FOUND{
                result(FlutterError(code: String(describing: KeyPairError.NOT_FOUND), message: "Private key not found", details: nil))
            }catch KeyPairError.DECRYPT_ERROR {
                result(FlutterError(code: String(describing: KeyPairError.DECRYPT_ERROR), message: "Decrypt failed", details: nil))
            }catch {
                result(FlutterError(code: String(describing: KeyPairError.DECRYPT_ERROR), message: "Encryption failed, Error occurred: \(error)", details: nil))
            }
           
        }else{
            result(FlutterError(code: String(describing: KeyPairError.BAD_ARGS),message: "Input argument not found",details: nil))
        }
    }
    
    
    
    private func signSha256Bytes(call:FlutterMethodCall,result: @escaping FlutterResult){
        guard controller != nil else{
            result(FlutterError(code: String(describing: KeyPairError.NOT_INIT), message: "Plugin not init", details: nil))
          return
        }
        if let args = call.arguments as? Dictionary<String, Any>,
           let input = args["inputSha256"] as? String
        {
            do{
                let signature:FlutterStandardTypedData? = try controller!.signSha256Bytes(input: input)
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
    
}
