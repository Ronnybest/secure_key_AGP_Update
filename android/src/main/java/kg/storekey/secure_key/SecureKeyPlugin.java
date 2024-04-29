package kg.storekey.secure_key;

import android.content.Context;
import androidx.annotation.NonNull;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;


/** SecureKeyPlugin */
public class SecureKeyPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

  private MethodChannel channel;
  private Context context;
  private AppKeyPair controller;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "secure_key");
    context =  flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method){
      case "initialize":
        initialize(call, result);
        break;
      case "getPublicKey":
        getPublicKey(result);
        break;
      case "createPairKey":
        createKeyPair(result);
        break;
      case "deleteKey":
        deleteKey(result);
        break;
      case "signSha256":
        signSha256(call,result);
        break;
      case "getPublicKeyBytes":
        getPublicKeyBytes(result);
        break;
      case "signSha256Bytes":
        signSha256Bytes(call,result);
        break;
      case "encryptWithRsa":
        encryptWithRsa(call, result);
        break;
      case "decryptWithRsa":
        decryptWithRsa(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void initialize(MethodCall call,Result result){
    if(controller != null){
      result.success(true);
      return;
    }
    Integer size = call.argument("size");
    if(size != null){
      controller = new AppKeyPair(context, size);
      result.success(true);

    }else {
      result.error(AppKeyPairErrors.BAD_ARGS.toString(), "Size argument mush be NonNull", null);
    }
  }


  private void deleteKey(Result result){
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    try{
      boolean deleted = controller.deleteKeyPair();
      result.success(deleted);
    }catch (RuntimeException e){
      result.error(AppKeyPairErrors.REMOVE_FAIL.toString(),"Key pair removed fail",null);
    }

  }

  private void getPublicKey(Result result){
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    String key = controller.getPublicKey();
    result.success(key);
  }

  private void getPublicKeyBytes(Result result){
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    byte[] key = controller.getPublicKeyBytes();
    result.success(key);
  }

  private void encryptWithRsa(MethodCall call, Result result) {
    if(controller == null) {
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    String input = call.argument("encryptInput");
    if(input != null) {
      try {
        String encryptedData = controller.encryptWithRsa(input);
        if(encryptedData != null) {
          result.success(encryptedData);
        }else  {
          result.error(AppKeyPairErrors.ENCRYPTION_FAIL.toString(),"DATA NOT ENCRYPTED!",null);
        }
      } catch (NoSuchPaddingException | IllegalBlockSizeException | NoSuchAlgorithmException |
               BadPaddingException | InvalidKeyException |NoSuchProviderException e) {
        result.error(AppKeyPairErrors.ENCRYPTION_FAIL.toString(),"DATA NOT ENCRYPTED " + e.toString(),null);
      }
    }
  }

  private void decryptWithRsa(MethodCall call, Result result) {
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    String input = call.argument("decryptInput");
    if(input != null) {
      try {
       String decryptedData =  controller.decryptWithRsa(input);
       if(decryptedData != null) {
         result.success(decryptedData);
       }else {
         result.error(AppKeyPairErrors.DECRYPTION_FAIL.toString(),"DATA NOT DECRYPTED!",null);
       }
      }catch (NoSuchAlgorithmException|
      NoSuchPaddingException|
              InvalidKeyException|
              IllegalBlockSizeException|
              BadPaddingException        |NoSuchProviderException  e) {

        result.error(AppKeyPairErrors.DECRYPTION_FAIL.toString(),"DATA NOT DECRYPTED " + e.toString(),null);
      }
    }
  }
  private void signSha256(MethodCall call,Result result){
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    String input = call.argument("inputSha256");
    if(input != null){
      try{
        String sign = controller.signSha256(input);
        if(sign != null){
          result.success(sign);
        }else {
          result.error(AppKeyPairErrors.SIGNATURE_FAIL.toString(),"Signature not created",null);
        }
      }catch (RuntimeException e){
        if(e.getMessage() != null && e.getMessage().equals(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString())){
          result.error(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString(),"Private key not found in storage",null);
        }else{
          result.error(AppKeyPairErrors.SIGNATURE_FAIL.toString(),"Signature not created",null);
        }
      }
    }else{
      result.error(AppKeyPairErrors.BAD_ARGS.toString(),"Input data not found",null);
    }
  }

  private void signSha256Bytes(MethodCall call,Result result){
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    String input = call.argument("inputSha256");
    if(input != null){
      try{
        byte[] sign = controller.signSha256Bytes(input);
        if(sign != null){
          result.success(sign);
        }else {
          result.error(AppKeyPairErrors.SIGNATURE_FAIL.toString(),"Signature not created",null);
        }
      }catch (RuntimeException e){
        if(e.getMessage() != null && e.getMessage().equals(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString())){
          result.error(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString(),"Private key not found in storage",null);
        }else{
          result.error(AppKeyPairErrors.SIGNATURE_FAIL.toString(),"Signature not created",null);
        }
      }
    }else{
      result.error(AppKeyPairErrors.BAD_ARGS.toString(),"Input data not found",null);
    }
  }


  private void createKeyPair(Result result){
    if(controller == null){
      result.error(AppKeyPairErrors.NOT_INIT.toString(), "Controller not init", null);
      return;
    }
    try {
      controller.createKeyPair();
      String key = controller.getPublicKey();
      if(key != null){
        result.success(true);
      } else {
        result.error(AppKeyPairErrors.CREATE_FAIL_NOT_FOUND.toString(),"Public key not found after created",null);
      }
    }catch (RuntimeException e){
      result.error(AppKeyPairErrors.CREATE_FAIL.toString(),"Fail when create key pair",null);
    }
  }




  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

}


