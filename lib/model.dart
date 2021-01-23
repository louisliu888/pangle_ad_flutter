import 'package:flutter/cupertino.dart';

/// 信息流响应信息
///
/// [code] 响应码，0成功，-1失败
/// [message] 错误时，调试信息
/// [count] 获得信息流数量，一般同上面传入的count，最终结果以此count为主
/// [data] (string list) 用于展示信息流广告的键id
class PangleAdReturn {
  final int code;
  final String message;
  final int count;
  final List<String> data;

  /// 是否成功
  bool get ok => code == 0;

  /// response for loading feed ad
  PangleAdReturn.empty()
      : code = -1,
        message = "",
        count = 0,
        data = [];

  /// response for loading feed ad
  PangleAdReturn.fromJsonMap(Map<dynamic, dynamic> map)
      : code = map["code"],
        message = map["message"],
        count = map["count"],
        data = map["data"] == null ? [] : List<String>.from(map["data"]);

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'count': count,
      'data': data,
    };
  }
}

/// GPS location
class PangleLocation {
  final double latitude;
  final double longitude;

  /// [latitude] 纬度
  /// [longitude] 经度
  PangleLocation({
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  Map<String, double> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

final _kDevicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
final _kPhysicalSize = WidgetsBinding.instance.window.physicalSize;

final kPangleScreenWidth = _kPhysicalSize.width / _kDevicePixelRatio;
final kPangleScreenHeight = _kPhysicalSize.height / _kDevicePixelRatio;

/// expect size
class PangleExpressSize {
  final double width;
  final double height;

  /// 模板渲染时必填
  ///
  /// [width] 宽度，必选, 如果width超过屏幕，默认使用屏幕宽
  /// [height] 高度，必选
  PangleExpressSize({double width, double height})
      : assert(width != null && width > 0),
        assert(height != null && height > 0),
        this.width = width > kPangleScreenWidth ? kPangleScreenWidth : width,
        this.height = height > kPangleScreenWidth / width * height ? kPangleScreenWidth / width * height : height;

  /// 模板渲染时必填
  ///
  /// [aspectRatio] item宽高比例
  PangleExpressSize.aspectRatio(double aspectRatio)
      : assert(aspectRatio != null && aspectRatio > 0),
        this.width = kPangleScreenWidth,
        this.height = kPangleScreenWidth / aspectRatio;

  PangleExpressSize.aspectRatio9_16()
      : this.width = kPangleScreenWidth,
        this.height = kPangleScreenWidth / 0.5625;

  PangleExpressSize.aspectRatio16_9()
      : this.width = kPangleScreenWidth - 20,
        this.height = (kPangleScreenWidth - 20) * 0.5625;

  PangleExpressSize.percent(double widthPercent, double heightPercent)
      : this.width = kPangleScreenWidth * widthPercent,
        this.height = kPangleScreenHeight * heightPercent;

  PangleExpressSize.widthPercent(double widthPercent, {double aspectRatio})
      : this.width = kPangleScreenWidth * widthPercent,
        this.height = kPangleScreenWidth * widthPercent / aspectRatio;

  PangleExpressSize.heightPercent(double heightPercent, {double aspectRatio})
      : this.width = kPangleScreenHeight * heightPercent * aspectRatio,
        this.height = kPangleScreenHeight * heightPercent;

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

/// image size
class PangleImageSize {
  final double width;
  final double height;

  /// 模板渲染时必填
  ///
  /// [width] 宽度，必选, 如果width超过屏幕，默认使用屏幕宽
  /// [height] 高度，必选
  PangleImageSize({double width, double height})
      : assert(width != null && width > 0),
        assert(height != null && height > 0),
        this.width = width > kPangleScreenWidth ? kPangleScreenWidth : width,
        this.height = height > kPangleScreenWidth / width * height ? kPangleScreenWidth / width * height : height;

  /// [aspectRatio] item宽高比例
  PangleImageSize.aspectRatio(double aspectRatio)
      : assert(aspectRatio != null && aspectRatio > 0),
        this.width = kPangleScreenWidth,
        this.height = kPangleScreenWidth / aspectRatio;

  PangleImageSize.aspectRatio9_16()
      : this.width = kPangleScreenWidth,
        this.height = kPangleScreenWidth / 0.5625;

  PangleImageSize.aspectRatio16_9()
      : this.width = kPangleScreenWidth,
        this.height = kPangleScreenWidth * 0.5625;

  PangleImageSize.percent(double widthPercent, double heightPercent)
      : this.width = kPangleScreenWidth * widthPercent,
        this.height = kPangleScreenHeight * heightPercent;

  PangleImageSize.widthPercent(double widthPercent, {double aspectRatio})
      : this.width = kPangleScreenWidth * widthPercent,
        this.height = kPangleScreenWidth * widthPercent / aspectRatio;

  PangleImageSize.heightPercent(double heightPercent, {double aspectRatio})
      : this.width = kPangleScreenHeight * heightPercent * aspectRatio,
        this.height = kPangleScreenHeight * heightPercent;

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

/// 插件返回的结果
///
class PangleResult {
  /// 结果码
  final int code;

  /// 一般是错误信息
  final String message;

  const PangleResult({this.code, this.message});

  /// 是否成功
  bool get ok => code == 0;

  /// 解析插件返回的结果
  ///
  factory PangleResult.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return PangleResult(code: -1, message: 'unknown');
    }
    return PangleResult(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
