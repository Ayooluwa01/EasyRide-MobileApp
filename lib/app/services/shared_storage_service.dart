import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedStorageService {
  SharedStorageService._internal();
  static final SharedStorageService _instance =
      SharedStorageService._internal();

  factory SharedStorageService() {
    return _instance;
  }

  void setAccessToken(String accessToken) {}
}
