import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/api/error_exception.dart';
import 'package:easy_ride/app/shared/app_activity_provider.dart';
import 'package:easy_ride/app/shared/storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient(this.ref) {
    _initialize();
  }

  final Ref ref;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late final Dio _dio;
  late final Dio _refreshDio;
  static const String _accessTokenKey = StorageKeys.accessToken;
  static const String _refreshTokenKey = StorageKeys.refreshToken;

  bool _isRefreshing = false;

  void _initialize() {
    const String baseUrl = 'http://127.0.0.1:3000';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420',
        },
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
              developer.log(
                '${options.method} ${options.baseUrl}${options.path}',
                name: 'ApiClient',
              );
              developer.log('Headers: ${options.headers}', name: 'ApiClient');
              developer.log('Body: ${options.data}', name: 'ApiClient');
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
          developer.log(
            'ERROR type=${error.type} status=${error.response?.statusCode}',
            name: 'ApiClient',
          );
          final statusCode = error.response?.statusCode;

          if (statusCode != 401) {
            handler.next(_unwrap(error));
            return;
          }

          final request = error.requestOptions;
          final alreadyRetried = request.extra['alreadyRetried'] == true;

          if (alreadyRetried) {
            developer.log(
              'SECOND 401 RAW: ${error.response?.data}',
              name: 'ApiClient',
            );

            await _logout();
            handler.next(_unwrap(error));
            return;
          }

          if (request.path.contains('/auth/refresh')) {
            await _logout();
            handler.next(_unwrap(error));
            return;
          }

          if (_isRefreshing) {
            handler.next(_unwrap(error));
            return;
          }

          _isRefreshing = true;

          try {
            print("refreshing accessToken now");
            final newAccessToken = await _refreshAccessToken();

            if (newAccessToken == null || newAccessToken.isEmpty) {
              await _logout();
              handler.next(_unwrap(error));
              return;
            }
            print("Proceeding with refresh request");
            request.extra['alreadyRetried'] = true;
            request.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await _dio.fetch(request);
            handler.resolve(response);
          } catch (e) {
            await _logout();
            handler.next(_unwrap(error));
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
    developer.log("Attempting to refreshToken");
    final refreshToken = await secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      developer.log("SENDING DATA TO BACKEND TO REFRESH TOKEN");
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data == null) {
        return null;
      }
      final tokens = data['data']?['tokens'] as Map<String, dynamic>?;
      if (tokens == null) {
        return null;
      }

      final newAccessToken = tokens['accessToken'] as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        return null;
      }
      await secureStorage.write(key: _accessTokenKey, value: newAccessToken);
      final newRefreshToken = tokens['refreshToken'] as String?;
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

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        final err = e.error as AppException;
        ref.read(appToastProvider.notifier).showError(err.message);
        throw err;
      }
      rethrow;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        final err = e.error as AppException;
        ref.read(appToastProvider.notifier).showError(err.message);
        throw err;
      }
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        final err = e.error as AppException;
        ref.read(appToastProvider.notifier).showError(err.message);
        throw err;
      }
      rethrow;
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        final err = e.error as AppException;
        ref.read(appToastProvider.notifier).showError(err.message);
        throw err;
      }
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.error is AppException) {
        final err = e.error as AppException;
        ref.read(appToastProvider.notifier).showError(err.message);
        throw err;
      }
      rethrow;
    }
  }

  DioException _unwrap(DioException error) {
    final data = error.response?.data;
    String message = 'Something went wrong. Please try again.';

    if (data is Map<String, dynamic> &&
        data['error'] is Map<String, dynamic> &&
        data['error']['message'] != null) {
      message = data['error']['message'] as String;
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Connection timed out. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Could not connect to the server.';
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: AppException(message, statusCode: error.response?.statusCode),
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));
