package kg.storekey.secure_key;

import android.content.Context;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Signature;
import java.security.SignatureException;
import java.security.UnrecoverableEntryException;
import java.security.cert.CertificateException;

public class AppKeyPair {
    private static final String PAIR_KEY_PROVIDER = "AndroidKeyStore";
    private static final String SHA256_WITH_RSA = "SHA256withRSA";
    private final int size;
    private final String alias;

    AppKeyPair(Context context, int size){
        this.alias = context.getPackageName();
        this.size = size;
    }

    public String getPublicKey(){
        PublicKey publicKey = getPublicKeyFromKeystore(alias);
        if (publicKey != null) {
            return encodeKey(publicKey.getEncoded());
        }
        return null;
    }

    public void createKeyPair(){
        try{
            KeyPairGenerator kpg = KeyPairGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_RSA, PAIR_KEY_PROVIDER);
            SecureRandom secureRandom = new SecureRandom();
            kpg.initialize(
                    new KeyGenParameterSpec.Builder(
                            alias,
                            KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY)
                            .setKeySize(size)
                            .setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PKCS1)
                            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
                            .setDigests(KeyProperties.DIGEST_SHA256)
                            .build(),
                    secureRandom);
            kpg.generateKeyPair();
        } catch (InvalidAlgorithmParameterException | NoSuchAlgorithmException | NoSuchProviderException e) {
            throw new RuntimeException(e);
        }
    }

    public String signSha256(String input){
        String signedString;
        try {
            System.out.println("-----1-----");
            PrivateKey privateKey = getPrivateKeyFromKeystore(alias);
            System.out.println("-----2-----");
            System.out.println(privateKey.getAlgorithm());
            System.out.println(privateKey.getFormat());
            System.out.println(privateKey.isDestroyed());
            System.out.println(privateKey.getEncoded());
            if(privateKey == null){
                System.out.println("-----11-----");
                throw new RuntimeException(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString());
            }
            System.out.println(privateKey);
            System.out.println(privateKey==null);
            System.out.println("-----3-----");
            Signature signature = Signature.getInstance(SHA256_WITH_RSA);
            System.out.println("-----4-----");
            signature.initSign(privateKey);
            System.out.println("-----5-----");
            byte[] inputBytes = input.getBytes(StandardCharsets.UTF_8);
            System.out.println("-----6-----");
            signature.update(inputBytes);
            System.out.println("-----7-----");
            byte[] signatureBytes = signature.sign();
            System.out.println("-----8-----");
            signedString = Base64.encodeToString(signatureBytes,Base64.DEFAULT);
            System.out.println("-----9-----");
        } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException e) {
            System.out.println("---error-1"+e.getStackTrace()+"----"+e+"---");
            throw new RuntimeException(e);
        }catch (RuntimeException e){
            System.out.println("---error-2"+e.getStackTrace()+"----");
            throw new RuntimeException(AppKeyPairErrors.PRIVATE_KEY_NOT_FOUND.toString());
        }
        return signedString;
    }



    public boolean deleteKeyPair(){
        try{
            KeyStore ks = KeyStore.getInstance(PAIR_KEY_PROVIDER);
            ks.load(null);
            KeyStore.Entry entry = ks.getEntry(alias, null);
            if(entry == null){
                return false;
            }
            ks.deleteEntry(alias);
            return true;
        }catch (CertificateException|KeyStoreException|IOException|NoSuchAlgorithmException|UnrecoverableEntryException e) {
            System.out.println("DELETE KEY FAIL");
            throw new RuntimeException(e);
        }
    }

    private PublicKey getPublicKeyFromKeystore(String alias) {
        PublicKey publicKey = null;
        try {
            KeyStore keyStore = KeyStore.getInstance(PAIR_KEY_PROVIDER);
            keyStore.load(null);
            KeyStore.Entry entry = keyStore.getEntry(alias, null);

            if (entry instanceof KeyStore.PrivateKeyEntry) {
                publicKey = ((KeyStore.PrivateKeyEntry) entry).getCertificate().getPublicKey();
            }
        } catch (KeyStoreException | IOException | NoSuchAlgorithmException | CertificateException |
                 UnrecoverableEntryException e) {
            throw new RuntimeException(e);
        }
        return publicKey;
    }

    public PrivateKey getPrivateKeyFromKeystore(String alias) {
        PrivateKey privateKey = null;
        try {
            KeyStore keyStore = KeyStore.getInstance(PAIR_KEY_PROVIDER);
            keyStore.load(null);
            System.out.println(keyStore.isKeyEntry(alias));
            privateKey = (PrivateKey) keyStore.getKey(alias, null);
        } catch (KeyStoreException | IOException | NoSuchAlgorithmException | CertificateException | UnrecoverableEntryException e) {
            throw new RuntimeException(e);
        }
        return privateKey;
    }

    private String encodeKey(byte[] keyBytes) {
        return Base64.encodeToString(keyBytes, Base64.DEFAULT);
    }

}
