class SecureKeyException {
  final String code;
  final String message;

  SecureKeyException(this.code, this.message);

  @override
  String toString() {
    return 'Code:$code, Message:$message';
  }
}

class SecureKeyErrors {
  static const String notFound = 'NOT_FOUND';
  static const String badArgs = 'BAD_ARGS';
  static const String createFail = 'CREATE_FAIL';
  static const String createFailNotFound = 'CREATE_FAIL_NOT_FOUND';
  static const String removeFail = 'REMOVE_FAIL';
  static const String privateKeyNotFound = 'PRIVATE_KEY_NOT_FOUND';
  static const String signatureFail = 'SIGNATURE_FAIL';
  static const String unknown = 'UNKNOWN';
  static const String init = 'INIT';
}
