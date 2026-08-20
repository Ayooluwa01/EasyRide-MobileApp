import 'package:dio/dio.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._internal() {
    _initialize();
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late final Dio _dio;
  late final Dio _refreshDio;
  static const String _accessTokenKey = 'access-token';
  static const String _refreshTokenKey = 'refresh-token';

  bool _isRefreshing = false;

  Future<void> _initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        sendTimeout: const Duration(seconds: 40),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        sendTimeout: const Duration(seconds: 40),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              try {
                final token = await secureStorage.read(key: _accessTokenKey);
                final isAuthRequest = AuthRoutes.isAuthRoute(options.path);

                if (!isAuthRequest && token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }

                handler.next(options);
              } catch (e) {
                handler.next(options);
              }
            },

        // --------------------------------------------------
        // RESPONSE
        // --------------------------------------------------
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          handler.next(response);
        },

        // --------------------------------------------------
        // ERROR
        // --------------------------------------------------
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final statusCode = error.response?.statusCode;

          if (statusCode != 401) {
            handler.next(error);
            return;
          }

          final request = error.requestOptions;

          final alreadyRetried = request.extra['alreadyRetried'] == true;

          if (alreadyRetried) {
            await _logout();
            handler.next(error);
            return;
          }

          if (request.path.contains('/auth/refresh')) {
            await _logout();
            handler.next(error);
            return;
          }

          if (_isRefreshing) {
            handler.next(error);
            return;
          }

          _isRefreshing = true;

          try {
            final newAccessToken = await _refreshAccessToken();
            if (newAccessToken == null || newAccessToken.isEmpty) {
              await _logout();
              handler.next(error);
              return;
            }

            request.extra['alreadyRetried'] = true;

            request.headers['Authorization'] = 'Bearer $newAccessToken';

            // Retry original request.
            final response = await _dio.fetch(request);
            handler.resolve(response);
          } catch (e) {
            await _logout();

            handler.next(error);
          } finally {
            _isRefreshing = false;
          }
        },
      ),
    );
  }

  // --------------------------------------------------
  // REFRESH ACCESS TOKEN
  // --------------------------------------------------

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data == null) {
        return null;
      }

      final newAccessToken = data['accessToken'] as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        return null;
      }
      await secureStorage.write(key: _accessTokenKey, value: newAccessToken);
      final newRefreshToken = data['refreshToken'] as String?;

      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await secureStorage.write(
          key: _refreshTokenKey,
          value: newRefreshToken,
        );
      }

      return newAccessToken;
    } on DioException {
      return null;
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> _logout() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }

  // // --------------------------------------------------
  // // MANUAL LOGOUT
  // // --------------------------------------------------

  // Future<void> logout() async {
  //   await _logout();
  // }

  // HELPERS
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
