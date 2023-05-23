package org.example.crypto;

import org.bouncycastle.asn1.DERBitString;
import org.bouncycastle.asn1.DERSet;
import org.bouncycastle.asn1.gm.GMObjectIdentifiers;
import org.bouncycastle.asn1.pkcs.CertificationRequest;
import org.bouncycastle.asn1.pkcs.CertificationRequestInfo;
import org.bouncycastle.asn1.x500.X500Name;
import org.bouncycastle.asn1.x509.AlgorithmIdentifier;
import org.bouncycastle.asn1.x509.SubjectPublicKeyInfo;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.DefaultSignatureAlgorithmIdentifierFinder;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.bouncycastle.pkcs.PKCS10CertificationRequest;
import org.bouncycastle.util.encoders.Base64;

import javax.security.auth.x500.X500Principal;
import java.security.*;

// 依赖BC库
//<dependency>
//    <groupId>org.bouncycastle</groupId>
//    <artifactId>bcprov-jdk15on</artifactId>
//    <version>1.64</version>
//</dependency>
//<dependency>
//    <groupId>org.bouncycastle</groupId>
//    <artifactId>bcpkix-jdk15on</artifactId>
//    <version>1.64</version>
//</dependency>
public class TestGenP10CSR {
    private static final Provider BC = new BouncyCastleProvider();
    public static String genCSR() {
        try {
            Security.addProvider(BC);
            //定义密钥对生成算法
            KeyPairGenerator keyGen = KeyPairGenerator.getInstance("EC"); //RSA  EC
//            keyGen.initialize(2048);      // RSA
            keyGen.initialize(256);  // ECC
            KeyPair kp = keyGen.generateKeyPair();

            String subject = "CN=China, C=CN, O=SomeOrganization, ST=Beijing, OU=SomeCompany";
            String sigAlgName = "SM3withSM2";  // "SM3withSM2"  SHA256WithRSA
            ContentSigner signer = new JcaContentSignerBuilder("SM3withSM2")
                    .setProvider(BC)
                    .build(kp.getPrivate());
            // 系统原有
//            PKCS10CertificationRequestBuilder builder = new JcaPKCS10CertificationRequestBuilder(new X500Principal(subject), kp.getPublic());
//            PKCS10CertificationRequest csr = builder.build(signer);
            // 自定义
            PKCS10CertificationRequest csr = pRequest(kp.getPublic(), kp.getPrivate(), sigAlgName, subject);

            // 封装csr样式
            byte[] der = csr.getEncoded();
            String code = "-----BEGIN CERTIFICATE REQUEST-----\n";
            code += new String(Base64.encode(der));
            code += "\n-----END CERTIFICATE REQUEST-----\n";
            return code;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static PKCS10CertificationRequest pRequest(PublicKey pubKey, PrivateKey privKey, String sigAlgName, String subject) {
        String plainText = "AAABCCAQ"; // 待签名字符串
        CertificationRequestInfo info = new CertificationRequestInfo(X500Name.getInstance(
                new X500Principal(subject).getEncoded()),
                SubjectPublicKeyInfo.getInstance(pubKey.getEncoded()), new DERSet());

        AlgorithmIdentifier identifier = new DefaultSignatureAlgorithmIdentifierFinder().find(sigAlgName);
//        if (attributes.isEmpty()) {
//            if (leaveOffEmpty) {
//                info = new CertificationRequestInfo(subject, publicKeyInfo, null);
//            } else {
//                info = new CertificationRequestInfo(subject, publicKeyInfo, new DERSet());
//            }
//        } else {
//            ASN1EncodableVector v = new ASN1EncodableVector();
//
//            for (Iterator it = attributes.iterator(); it.hasNext(); ) {
//                v.add(Attribute.getInstance(it.next()));
//            }
//
//            info = new CertificationRequestInfo(subject, publicKeyInfo, new DERSet(v));
//        }

        try {
//            OutputStream sOut = signer.getOutputStream();
//            sOut.write(info.getEncoded(ASN1Encoding.DER));
//            sOut.close();

            // 创建签名对象
            Signature signature = Signature.getInstance(GMObjectIdentifiers.sm2sign_with_sm3.toString(), BC);
            // 初始化为签名状态
            signature.initSign(privKey);
            // 传入签名字节
            signature.update(plainText.getBytes()); // 这里测试私钥签名值
            System.out.println("Sign: " + java.util.Base64.getEncoder().encodeToString(signature.sign()));

            return new PKCS10CertificationRequest(new CertificationRequest(info,
                    identifier,
                    new DERBitString(signature.sign())));  // 实际上私钥无法出Key时，利用上述签名后的byte即可，即可省去直接调用私钥
        } catch (Exception e) {
            throw new IllegalStateException("cannot produce certification request signature");
        }
    }


//    private ContentSigner ss() {
//        OperatorHelper helper = new OperatorHelper(new DefaultJcaJceHelper());
//        final Signature sig = helper.createSignature(sigAlgId);
//        final AlgorithmIdentifier signatureAlgId = sigAlgId;
//
//        return new ContentSigner()
//        {
//            private OutputStream stream = OutputStreamFactory.createStream(sig);
//
//            public AlgorithmIdentifier getAlgorithmIdentifier()
//            {
//                return signatureAlgId;
//            }
//
//            public OutputStream getOutputStream()
//            {
//                return stream;
//            }
//
//            public byte[] getSignature()
//            {
//                try
//                {
//                    return sig.sign();
//                }
//                catch (SignatureException e)
//                {
//                    throw new RuntimeOperatorException("exception obtaining signature: " + e.getMessage(), e);
//                }
//            }
//        };
//    }

    public static void main(String[] args) throws NoSuchAlgorithmException, SignatureException, InvalidKeyException, NoSuchProviderException {
        System.out.println(genCSR());
    }
}
