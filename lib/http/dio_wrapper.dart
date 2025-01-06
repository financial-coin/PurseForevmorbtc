import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:purse_for_evmorbtc/http/base_res.dart';

class DioWrapper {
  static BaseResponse errorWrapper(Object e) {
    print("\n=== Error Wrapper ===");
    String errorMessage = '';
    dynamic errorData = null;

    if (e is DioError) {
      switch (e.type) {
        case DioErrorType.connectTimeout:
          errorMessage = '连接服务器超时';
          break;
        case DioErrorType.sendTimeout:
          errorMessage = '发送请求超时';
          break;
        case DioErrorType.receiveTimeout:
          errorMessage = '接收数据超时';
          break;
        case DioErrorType.response:
          errorMessage = '服务器响应错误: ${e.response?.statusCode}';
          errorData = e.response?.data;
          break;
        case DioErrorType.cancel:
          errorMessage = '请求被取消';
          break;
        default:
          errorMessage = '网络错误: ${e.message}';
      }
      print("DioError: $errorMessage");
      if (e.response != null) {
        print("Response: ${e.response?.data}");
        errorData = e.response?.data;
      }
    } else {
      errorMessage = e.toString();
      print("Unknown Error: $e");
    }

    print("=== Error Wrapper End ===\n");

    return BaseResponse(
      code: -1,
      message: errorMessage,
      data: errorData,
      success: false,
      deviceId: "",
    );
  }

  static String _dioErrorWrapper(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
        return '连接服务器超时';
      case DioErrorType.sendTimeout:
        return '连接服务器超时';
      case DioErrorType.receiveTimeout:
        return '连接服务器超时';
      case DioErrorType.cancel:
        return '连接被取消';
      default:
        return '未知错误';
    }
  }

  static BaseResponse responseWrapper(Response response) {
    try {
      // 检查响应状态码
      if (response.statusCode != 200) {
        return BaseResponse(
          code: response.statusCode ?? -1,
          message: "HTTP错误: ${response.statusCode}",
          data: response.data,
          success: false,
          ores: response,
          deviceId: "",
        );
      }

      dynamic responseData = response.data;

      // 如果是数组响应
      if (responseData is List) {
        print("List----->1");
        return BaseResponse(
          code: 0,
          message: "success",
          data: responseData,
          success: true,
          ores: response,
          deviceId: "",
        );
      }

      // 如果是对象响应
      if (responseData is Map) {
        print("----->1");
        final BaseResponse wrapres = BaseResponse.fromJson(responseData);
        print("----->2");
        wrapres.ores = response;
        print("----->3");
        return wrapres;
      }

      // 其他情况
      return BaseResponse(
        code: 0,
        message: "success",
        data: responseData,
        success: true,
        ores: response,
        deviceId: "",
      );
    } catch (e) {
      // print("Response wrapper error: $e");
      return BaseResponse(
        code: -1,
        message: "数据解析错误: $e",
        data: response.data,
        success: false,
        ores: response,
        deviceId: "",
      );
    }
  }
}
