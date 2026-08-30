class SharedStorageService {
  SharedStorageService._internal();
  static final SharedStorageService _instance =
      SharedStorageService._internal();

  factory SharedStorageService() {
    return _instance;
  }

  void setAccessToken(String accessToken) {}
}
