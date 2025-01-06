import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purse_for_evmorbtc/http/api.dart';
import 'package:purse_for_evmorbtc/http/base_res.dart';
import 'package:purse_for_evmorbtc/http/dio_intercept.dart' as interceptor;
import 'package:purse_for_evmorbtc/http/dio_wrapper.dart';
import 'package:purse_for_evmorbtc/http/LoadingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';

class HttpUtils {
  static final HttpUtils _instance = HttpUtils._();

  static HttpUtils get instance => HttpUtils();

  factory HttpUtils() => _instance;

  static late Dio _dio;

  Dio get dio => _dio;

  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: non_constant_identifier_names
    final String? UserId = prefs.getString('UserId');
    // print("userId====>:" + UserId!);

    return UserId;
  }

  // 设置基本URL
  static void setBaseUrl() {
    _dio.options.baseUrl = Api.baseUrl;
  }

  static String getBaseUrl() {
    return _dio.options.baseUrl;
  }

  HttpUtils._() {
    // 构造 Dio options
    final BaseOptions options = BaseOptions(
      connectTimeout: 25000,
      receiveTimeout: 25000,
      sendTimeout: 25000,
      responseType: ResponseType.json,
      validateStatus: (_) => true,
      baseUrl: Api.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // 实例化 Dio
    _dio = Dio(options);

    if (!kIsWeb) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // 只保留 AuthInterceptor
    _dio.interceptors.add(interceptor.AuthInterceptor());
  }
  Future<void> userIdFun() async {
    String uId = await getUserId();
    if (uId != null) {
      _dio.options.headers['userId'] = uId;
    }
  }

  Future<BaseResponse> _request(
    String url, {
    String? method = 'POST',
    dynamic params,
    bool tips = false,
    required BuildContext context,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    late BaseResponse response;
    // LoadingPage loading = LoadingPage as LoadingPage;
    try {
      if (tips) {
        // 展示 loading
        // showDialog(
        //     barrierDismissible: true,
        //     context: context,
        //     builder: (BuildContext context) {
        //       return loading;
        //     });
      }
      if (url != "/API/Mobile/CheckLogin") {
        await userIdFun();
      }

      late Response<dynamic> res;
      if (method == 'GET') {
        res = await _dio.get(url, queryParameters: params);
        print(res.data);
      } else if (method == 'UPLOAD') {
        String path = params["FilePath"];
        FormData formData = FormData.fromMap({
          "File": await MultipartFile.fromFile(
            path,
            filename: params["FileName"],
          ),
          "FolderName": params["FolderName"],
        });

        res = await _dio.post(
          url,
          data: formData,
          // onSendProgress: onSendProgress,
          // onReceiveProgress: onReceiveProgress,
        );
      } else {
        res = await _dio.post(
          url,
          data: params,
        );
      }
      response = DioWrapper.responseWrapper(res);
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(response.ores);
      //-------------------------------------------------------------打开之后不同人登录，进入首页---------------------------------------------------------------
      if (!kIsWeb) {
        if (response.message != "App登录成功。") {
          if (response.deviceId != await Adapt.getDeviceId()) {
            // print("-------");
            // print("getDeviceId" + await Adapt.getDeviceId());
            // print("response.getDeviceId" + response.deviceId);
            // print("-------");
            RequestOptions requestOptions1 = RequestOptions(
              method: 'GET',
              path: '',
            );
            Response response1 = Response(
              data:
                  '{"state": "Lose", "Code": -1, "Message": "新用户登录", "data": null}',
              requestOptions: requestOptions1,
            );
            // 请求超时
            response = BaseResponse(
                code: -1,
                message: '新用户登录',
                data: null,
                success: false,
                ores: response1,
                deviceId: "");
            Adapt.goToLogin();
            return response;
          }
        }
      }
      //-------------------------------------------------------------打开之后不同人登录，进入首页end---------------------------------------------------------------
    } on DioError catch (e) {
      // if (e.type == DioErrorType.connectTimeout ||
      //     e.type == DioErrorType.receiveTimeout) {

      RequestOptions requestOptions1 = RequestOptions(
        method: 'GET',
        path: '',
      );
      Response response1 = Response(
        data: '{"state": "Lose", "Code": -1, "Message": "请检查网络", "data": null}',
        requestOptions: requestOptions1,
      );
      // 请求超时
      response = BaseResponse(
          code: -1,
          message: '请检查网络',
          data: null,
          success: false,
          ores: response1,
          deviceId: "");
    } catch (e) {
      response = DioWrapper.errorWrapper(e);
    } finally {
      // 隐藏 loading
      // loading.dismiss();

    }
    return response;
  }

  // GET
  Future<BaseResponse> get(
    String url, {
    dynamic params,
    required BuildContext context,
    bool tips = false,
  }) async {
    try {
      // 1. 打印请求信息
      print("\n=== 请求开始 ===");
      final fullUrl = "${_dio.options.baseUrl}$url";
      print("请求URL: $fullUrl");
      print("请求参数: $params");

      // 2. 构建完整的URL（用于调试）
      if (params != null) {
        String queryString =
            params.entries.map((e) => "${e.key}=${e.value}").join('&');
        print("完整URL: $fullUrl?$queryString");
      }

      // 3. 发送请求
      final Response response = await _dio.get(
        url,
        queryParameters: params,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // 4. 打印响应信息
      print("\n=== 响应信息 ===");
      print("状态码: ${response.statusCode}");
      print("响应头: ${response.headers}");
      print("响应数据: ${response.data}");
      print("=== 请求结束 ===\n");

      // 5. 处理响应
      final result = DioWrapper.responseWrapper(response);
      print("处理后的数据: $result");

      return result;
    } catch (e) {
      // 6. 错误处理
      print("\n=== 请求错误 ===");
      print("错误类型: ${e.runtimeType}");
      print("错误信息: $e");

      if (e is DioError) {
        print("DioError类型: ${e.type}");
        print("DioError消息: ${e.message}");
        if (e.response != null) {
          print("错误响应: ${e.response?.data}");
          print("错误状态码: ${e.response?.statusCode}");
        }
      }
      print("=== 错误结束 ===\n");

      return DioWrapper.errorWrapper(e);
    }
  }

  Future<BaseResponse> get1(
    String url, {
    dynamic params,
    required BuildContext context,
    bool tips = false,
  }) async {
    print("---------------------------------");
    print(url);
    print(params);
    print("---------------------------------");
    return _request(
      url,
      method: 'GET',
      params: params,
      tips: tips,
      context: context,
    );
  }

  // POST
  Future<BaseResponse> post(
    String url, {
    dynamic params,
    required BuildContext context,
    bool tips = false,
  }) async {
    print("---------------------------------");
    print(url);
    print(params);
    print("---------------------------------");
    return _request(
      url,
      method: 'POST',
      params: params,
      tips: tips,
      context: context,
    );
  }

  // UPLOAD
  Future<BaseResponse> upload(
    String url, {
    dynamic params,
    bool tips = false,
    required BuildContext context,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    print("---------------------------------");
    print(url);
    print(params);
    print("---------------------------------");
    return _request(
      url,
      method: 'UPLOAD',
      params: params,
      tips: tips,
      // onSendProgress: onSendProgress,
      // onReceiveProgress: onReceiveProgress,
      context: context,
    );
  }
}
