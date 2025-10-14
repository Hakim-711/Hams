// 📁 lib/core/utils/encryption_helper.dart
import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static final _key = Key.fromUtf8(
      '5360a2f88bb19b0fa966b0d04af0e86f85db6d770d70b409490cd03bb605b719'); // 32-char key
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String encryptedText) {
    final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
