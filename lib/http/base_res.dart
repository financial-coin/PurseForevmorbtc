import 'package:dio/dio.dart';

class BaseResponse {
  late int code;
  late String message;
  late dynamic data;
  late String deviceId;
  late bool success;
  Response? ores;

  BaseResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.success,
    this.ores,
    this.deviceId = "",
  });

  BaseResponse.fromJson(Map<dynamic, dynamic> json) {
    try {
      code = json['code'] ?? -1;
      message = json['message']?.toString() ?? '';
      data = json['data'];
      success = code == 0;
      deviceId = json['deviceId']?.toString() ?? '';
    } catch (e) {
      print("Error parsing JSON: $e");
      print("Raw JSON: $json");
      code = -1;
      message = "数据解析错误";
      data = null;
      success = false;
      deviceId = "";
    }
  }

  @override
  String toString() {
    return '{code: $code, message: $message, data: $data, success: $success, deviceId: $deviceId}';
  }
}
