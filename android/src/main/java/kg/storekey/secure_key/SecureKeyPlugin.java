package kg.storekey.secure_key;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** SecureKeyPlugin */
public class SecureKeyPlugin implements FlutterPlugin, MethodCallHandler  {

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
      default:
        result.notImplemented();
    }
  }

  private void initialize(MethodCall call,Result result){
    if(controller != null){
      result.error(AppKeyPairErrors.INIT.toString(), "Controller already init", null);
      return;
    }
    Integer size = call.argument("size");
    System.out.println("------");
    System.out.println(size);
    System.out.println("------");
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
    if(key!=null){
      result.success(key);
    }else{
      result.error(AppKeyPairErrors.NOT_FOUND.toString(),"Public key not found",null);
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
          System.out.println("------1------");
          result.error(AppKeyPairErrors.SIGNATURE_FAIL.toString(),"Signature not created",null);
        }
      }catch (RuntimeException e){
        if(e.getMessage() != null && e.getMessage().equals(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString())){
          result.error(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString(),"Private key not found in storage",null);
        }else{
          System.out.println("------2------");
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


//  private void getAccounts(){
//    AccountPicker.AccountChooserOptions options =  new AccountPicker.AccountChooserOptions.Builder()
//            .setAllowableAccountsTypes(Arrays.asList("com.google"))
//            .setAlwaysShowAccountPicker(false)
//            .build();

//    Intent googlePicker =  AccountPicker.newChooseAccountIntent(options);

//    activity.startActivityForResult(googlePicker, 1333);
//    Intent intent = new Intent(Settings.ACTION_SETTINGS);
//    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

//    GoogleSignInAccount acct = GoogleSignIn.getLastSignedInAccount(activity);
//
//    System.out.println("BBBBBBBB");
//    System.out.println(acct);
//
//    if (acct != null) {
//      String personName = acct.getDisplayName();
//      String personGivenName = acct.getGivenName();
//      String personFamilyName = acct.getFamilyName();
//      String personEmail = acct.getEmail();
//      String personId = acct.getId();
//      Uri personPhoto = acct.getPhotoUrl();
//      System.out.println(personName);
//      System.out.println(personGivenName);
//      System.out.println(personFamilyName);
//      System.out.println(personEmail);
//      System.out.println(personId);
//      System.out.println(personPhoto);
//    }
//    activity.startActivityForResult(intent,1333);
//    GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
//            .requestEmail()
//            .build();

//    GoogleSignInClient client = GoogleSignIn.getClient(activity, gso);

//    System.out.println("AAAAAAAA");
//    System.out.println(client.asGoogleApiClient().isConnected());

//    activity.startActivityForResult(client.getSignInIntent(), RC_SIGN_IN);


//
//    if (ContextCompat.checkSelfPermission(context, Manifest.permission.GET_ACCOUNTS) == PackageManager.PERMISSION_GRANTED) {
//      System.out.println("BBBBBBBBBB");
//      AccountManager accountManager = AccountManager.get(context);
//
//      System.out.println("CCCCCCCCCC");
//      Account[] accounts = accountManager.getAccountsByType("com.google");
//      System.out.println("DDDDDDDDDDD");
//
//      System.out.println(accounts.length);
//      for (Account account : accounts) {
//        String uid = account.name;
//        System.out.println(uid);
//        if (uid != null) {
//          System.out.println("\n");
//          System.out.println(uid);
//          System.out.println("\n");
//        }else{
//          System.out.println("\n");
//          System.out.println("NOT FOUND");
//          System.out.println("\n");
//        }
//      }
//    } else {
//      System.out.println("\n");
//      System.out.println("REQUEST");
//      System.out.println("\n");
//      // Запрос разрешения у пользователя
//      ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.GET_ACCOUNTS}, PERMISSIONS_REQUEST_GET_ACCOUNTS);
////      ActivityCompat.checkSelfPermission(context,Manifest.permission.GET_ACCOUNTS);
//    }
//  }

//  private void handleSignInResult(Task<GoogleSignInAccount> completedTask) {
//    System.out.println("SIGN ednenda");
//    GoogleSignInAccount account = completedTask.getResult();
//    System.out.println("faslf;ks;");
//    System.out.println(account);
//    System.out.println(account.getEmail());
//    try {
//      System.out.println("SIGN ednenda");
//      GoogleSignInAccount account = completedTask.getResult();
//      System.out.println("faslf;ks;");
//      System.out.println(account);
//      System.out.println(account.getEmail());
//      // Signed in successfully, show authenticated UI.
//
//    } catch (ApiException e) {
//      // The ApiException status code indicates the detailed failure reason.
//      // Please refer to the GoogleSignInStatusCodes class reference for more information.
//      Log.w("123", "signInResult:failed code=" + e.getStatusCode());
//
//    }
//  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

}
