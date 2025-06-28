package com.reactnativemqttmtlssupport;

import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.ECGenParameterSpec;
import java.security.KeyPair;
import java.security.cert.Certificate;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidAlgorithmParameterException;
import java.io.IOException;
import java.security.KeyStoreException;
import java.security.NoSuchProviderException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.StringWriter;

import org.bouncycastle.asn1.x500.X500NameBuilder;
import org.bouncycastle.asn1.x500.style.BCStyle;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.bouncycastle.pkcs.PKCS10CertificationRequestBuilder;
import org.bouncycastle.util.io.pem.PemObject;
import org.bouncycastle.util.io.pem.PemWriter;

public class CSRModule extends ReactContextBaseJavaModule {
    private static final String TAG = "CSRModule";

    public CSRModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "CSRModule";
    }

    public static KeyPair generateSoftwareECCKeyPair() throws Exception {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance("EC");
        ECGenParameterSpec ecSpec = new ECGenParameterSpec("secp256r1");
        keyPairGenerator.initialize(ecSpec);
        return keyPairGenerator.generateKeyPair();
    }

    @ReactMethod
    public KeyPair generateECCKeyPair() throws Exception {
        KeyPair keyPair = generateSoftwareECCKeyPair();
        return keyPair;
    }

    @ReactMethod
public void generateCSR(
        String cn,
        String serialNum,
        String userId,
        String country,
        String state,
        String locality,
        String organization,
        String organizationalUnit,
        Promise promise) {
    try {
        KeyPair keyPair = generateECCKeyPair();
        PrivateKey privateKey = keyPair.getPrivate();
        PublicKey publicKey = keyPair.getPublic();

        // Encode keys to Base64
        String base64PrivateKey = Base64.encodeToString(privateKey.getEncoded(), Base64.NO_WRAP);
        String base64PublicKey = Base64.encodeToString(publicKey.getEncoded(), Base64.NO_WRAP);

        // Generate CSR
        String csr = createCSR(
                cn, serialNum, userId, country, state, locality, organization, organizationalUnit,
                privateKey, publicKey);

        // Return everything to JS
        WritableMap result = Arguments.createMap();
        result.putString("csr", csr);
        result.putString("privateKey", base64PrivateKey);
        result.putString("publicKey", base64PublicKey);

        promise.resolve(result);
    } catch (Exception e) {
        promise.reject("CSR_ERROR", "Failed to generate CSR: " + e.getMessage());
    }
}


    private String createCSR(
            String cn,
            String serialNum,
            String userId,
            String country,
            String state,
            String locality,
            String organization,
            String organizationalUnit,
            PrivateKey privateKey,
            PublicKey publicKey) throws Exception {
        X500NameBuilder nameBuilder = new X500NameBuilder(BCStyle.INSTANCE);
        if (cn != null && !cn.isEmpty()) {
            nameBuilder.addRDN(BCStyle.CN, cn);
        }
        if (serialNum != null && !serialNum.isEmpty()) {
            nameBuilder.addRDN(BCStyle.SERIALNUMBER, serialNum);
        }
        if (country != null && !country.isEmpty()) {
            nameBuilder.addRDN(BCStyle.C, country);
        }
        if (state != null && !state.isEmpty()) {
            nameBuilder.addRDN(BCStyle.ST, state);
        }
        if (locality != null && !locality.isEmpty()) {
            nameBuilder.addRDN(BCStyle.L, locality);
        }
        if (organization != null && !organization.isEmpty()) {
            nameBuilder.addRDN(BCStyle.O, organization);
        }
        if (organizationalUnit != null && !organizationalUnit.isEmpty()) {
            nameBuilder.addRDN(BCStyle.OU, organizationalUnit);
        }

        SubjectPublicKeyInfo subjectPublicKeyInfo = SubjectPublicKeyInfo.getInstance(publicKey.getEncoded());
        PKCS10CertificationRequestBuilder csrBuilder = new PKCS10CertificationRequestBuilder(
                nameBuilder.build(), subjectPublicKeyInfo);
        JcaContentSignerBuilder signerBuilder = new JcaContentSignerBuilder("SHA256withECDSA");
        var csr = csrBuilder.build(signerBuilder.build(privateKey));

        StringWriter stringWriter = new StringWriter();
        try (PemWriter pemWriter = new PemWriter(stringWriter)) {
            pemWriter.writeObject(new PemObject("CERTIFICATE REQUEST", csr.getEncoded()));
        }
        return stringWriter.toString();
    }
}