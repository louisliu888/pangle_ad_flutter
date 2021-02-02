import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'configs.dart';
import 'constant.dart';
import 'express_banner_view.dart';
import 'model.dart';

final pangle = PangleAd._();

class PangleAd {
  static const MethodChannel _channel = const MethodChannel('neg.goc.oceantide/pangle_ad_flutter');

  PangleAd._() {
    _channel.setMethodCallHandler((call) => _handleMethod(call));
  }

  _handleMethod(MethodCall call) {}

/*
获取广告SDK的版本号
*/
  Future<String> getSdkVersion() async {
    return await _channel.invokeMethod('getSdkVersion');
  }

  /// Request permissions
  /// 穿山甲SDK不强制获取权限，即使没有获取可选权限SDK也能正常运行；
  /// 获取权限将帮助穿山甲优化投放广告精准度和用户的交互体验，提高eCPM。
  /// 常见问题：
  /// 使用该方法请求权限时 FlutterActivity不会回调onStart,onStop方法，会导致插屏广告
  /// (Interstitial Ad)不能正常显示。详见 Android SDK
  ///   [com.bytedance.sdk.openadsdk.utils.a:28],
  ///   [com.bytedance.sdk.openadsdk.core.c.b:306].
  /// 建议自行实现权限请求, 如使用[permission_handler](https://pub.flutter-io.cn/packages?q=permission_handler)
  ///
  /// ```
  /// [Permission.location, Permission.phone, Permission.storage].request();
  /// ```
  Future<Null> requestPermissionIfNecessary() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('requestPermissionIfNecessary');
    }
  }

  /// Request user tracking authorization with a completion handler returning
  /// the user's authorization status.
  /// Users are able to grant or deny developers tracking privileges on a
  /// per-app basis.This method allows developers to determine if access has
  /// been granted. On first use, this method will prompt the user to grant or
  /// deny access.
  ///
  /// Just works on iOS 14.0+.
  Future<PangleAuthorizationStatus> requestTrackingAuthorization() async {
    if (Platform.isIOS) {
      int rawValue = await _channel.invokeMethod(
        'requestTrackingAuthorization',
      );
      if (rawValue != null) {
        return PangleAuthorizationStatus.values[rawValue];
      }
    }
    return null;
  }

  /// Returns information about your application’s tracking authorization status.
  ///
  /// Just works on iOS 14.0+.
  Future<PangleAuthorizationStatus> getTrackingAuthorizationStatus() async {
    if (Platform.isIOS) {
      int rawValue = await _channel.invokeMethod(
        'getTrackingAuthorizationStatus',
      );
      if (rawValue != null) {
        return PangleAuthorizationStatus.values[rawValue];
      }
    }
    return null;
  }

  /// Register the App key that’s already been applied before requesting an
  /// ad from TikTok Audience Network.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  Future<Null> init({
    IOSConfig iOS,
    AndroidConfig android,
  }) async {
    if (Platform.isIOS && iOS != null) {
      await _channel.invokeMethod('init', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      await _channel.invokeMethod('init', android.toJSON());
    }
  }

  /// Request feed ad data.
  ///
  /// [config] config for iOS and Android
  /// return loaded ad count.
  Future<PangleAdReturn> loadExpressFeedAd({
    ExpressFeedConfig config,
  }) async {
    Map<dynamic, dynamic> result = await _channel.invokeMapMethod(
      'loadExpressFeedAd',
      config.toJSON(),
    );

    if (result == null) {
      return PangleAdReturn.empty();
    }
    return PangleAdReturn.fromJsonMap(result);
  }

  /// Request interstitial ad data.
  ///
  /// [config] config for iOS and Android
  /// return loaded ad count.
  Future<PangleResult> loadExpressBannerAd({
    ExpressBannerConfig config,
  }) async {
    Map<String, dynamic> result;
    result = await _channel.invokeMapMethod(
      'loadExpressBannerAd',
      config.toJSON(),
    );
    return PangleResult.fromJson(result);
  }

  /// Request interstitial ad data.
  ///
  /// [config] config for iOS and Android
  /// return loaded ad count.
  Future<PangleResult> loadExpressInterstitialAd({
    ExpressInterstitialConfig config,
  }) async {
    Map<String, dynamic> result;
    result = await _channel.invokeMapMethod(
      'loadExpressInterstitialAd',
      config.toJSON(),
    );
    return PangleResult.fromJson(result);
  }

  /// Request full screen video ad data.
  ///
  /// [conf] config for iOS and android
  /// return code & message.
  Future<PangleResult> loadExpressFullscreenVideoAd({
    ExpressFullscreenVideoConfig config,
  }) async {
    Map<String, dynamic> result = await _channel.invokeMapMethod(
      'loadExpressFullscreenVideoAd',
      config.toJSON(),
    );

    return PangleResult.fromJson(result);
  }
}
