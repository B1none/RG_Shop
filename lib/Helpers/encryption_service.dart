import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }
}