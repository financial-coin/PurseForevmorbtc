import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if ('token' != '') {
      options.headers['token'] = 'token';
    }
    super.onRequest(options, handler);
  }
}
