import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:device_info/device_info.dart';

class Adapt {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static final double _width = mediaQuery.size.width;
  static final double _height = mediaQuery.size.height;
  static final double _topbarH = mediaQuery.padding.top;
  static final double _botbarH = mediaQuery.padding.bottom;
  static final double _pixelRatio = mediaQuery.devicePixelRatio;
  // ignore: prefer_typing_uninitialized_variables
  static var _ratio;
  static init(int number) {
    // ignore: unnecessary_type_check
    int uiwidth = number is int ? number : 750;
    _ratio = _width / uiwidth;
  }

  static px(number) {
    if (!(_ratio is double || _ratio is int)) {
      Adapt.init(750);
    }
    return number * _ratio;
  }

  static onepx() {
    return 1 / _pixelRatio;
  }

  static screenW() {
    return _width;
  }

  static screenH() {
    return _height;
  }

  static padTopH() {
    return _topbarH;
  }

  static padBotH() {
    return _botbarH;
  }

  static StringtoTimeStr(time) {
    if (time == null) {
      return "";
    } else if (time == "") {
      return "";
    } else {
      int str = int.parse(time.substring(6, 19));
      DateTime timeStr = DateTime.fromMillisecondsSinceEpoch(str);
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(timeStr.toLocal());
      return formattedDate;
    }
  }

  static String getNowDate() {
    var now = DateTime.now();
    var format = DateFormat('yyyy-MM-dd');
    String formattedDate = format.format(now);
    // print(formattedDate);
    return formattedDate;
  }

  static String getNowTime() {
    var now = DateTime.now();
    var format = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedDate = format.format(now);
    // print(formattedDate);
    return formattedDate;
  }

  static String addTwoDays() {
    DateTime now = DateTime.now();
    DateTime twoDaysLater = now.add(Duration(days: 2));
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(twoDaysLater);
    return formattedDateTime;
  }

  static isNull(Str) {
    if (Str == null) {
      return "";
    } else if (Str == "") {
      return "";
    } else {
      return Str;
    }
  }

  static String twoTime(String data1, String data2) {
    if (data1 == "" || data2 == "") {
      return "";
    }
    final startTime = DateTime.parse(data1);
    final endTime = DateTime.parse(data2);
    final difference = endTime.difference(startTime);
    return difference.inMinutes.toString();
  }

  static getDeviceId() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId;
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print(iosInfo.identifierForVendor);
      return iosInfo.identifierForVendor;
    } else {
      return "";
    }
  }

  static goToLogin() {
    // if (response.deviceId != Adapt.getDeviceId()) {
    Get.toNamed('/Login');
    // }
  }
}
