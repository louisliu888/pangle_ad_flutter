import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs.dart';

final kSplashViewType = 'net.goc.oceantide/pangle_expresssplashview';

typedef void ExpressSplashViewCreatedCallback(ExpressSplashViewController controller);

/// Display banner AD
/// PlatformView does not support Android API level 19 or below.
class ExpressSplashView extends StatefulWidget {
  final ExpressSplashConfig config;

  /// PlatformView 创建成功
  final ExpressSplashViewCreatedCallback onSplashViewCreated;
  final Color backgroundColor;

  /// 获取广告失败
  final void Function(int code, String message) onError;

  /// 广告被点击
  final VoidCallback onClick;

  /// 跳过广告
  final VoidCallback onSkip;

  /// 倒计时结束
  final VoidCallback onTimeOver;

  /// 广告展示
  final VoidCallback onShow;

  const ExpressSplashView({
    Key key,
    @required this.config,
    this.onSplashViewCreated,
    this.backgroundColor,
    this.onError,
    this.onClick,
    this.onSkip,
    this.onTimeOver,
    this.onShow,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExpressSplashViewState();
}

class ExpressSplashViewState extends State<ExpressSplashView> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: widget.backgroundColor ?? Colors.white,
          width: constraints.biggest.width,
          height: constraints.biggest.height,
          child: _buildPlatformView(
            constraints.biggest.width,
            constraints.biggest.height,
          ),
        );
      },
    );
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    var controller = ExpressSplashViewController._(
      id,
      widget.onError,
      widget.onClick,
      widget.onSkip,
      widget.onTimeOver,
      widget.onShow,
    );
    if (widget.onSplashViewCreated == null) {
      return;
    }
    widget.onSplashViewCreated(controller);
  }

  Map<String, dynamic> _createParams(double width, double height) {
    return widget.config.toJSON();
  }

  Widget _buildPlatformView(double width, double height) {
    Widget body;
    try {
      Widget platformView;
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = AndroidView(
          viewType: kSplashViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(context, index),
          creationParams: _createParams(width, height),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kSplashViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(context, index),
          creationParams: _createParams(width, height),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      }
      if (platformView != null) {
        body = platformView;
      }
    } on PlatformException {}
    if (body == null) {
      body = SizedBox.expand();
    }
    return body;
  }
}

class ExpressSplashViewController {
  MethodChannel _methodChannel;

  final void Function(int code, String message) onError;
  final VoidCallback onClick;
  final VoidCallback onSkip;
  final VoidCallback onTimeOver;
  final VoidCallback onShow;

  ExpressSplashViewController._(
    int id,
    this.onError,
    this.onClick,
    this.onSkip,
    this.onTimeOver,
    this.onShow,
  ) {
    _methodChannel = new MethodChannel('${kSplashViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    print("收到开屏广告原始回调Flutter信息........................${call.method} ${call.arguments}");
    if (call.method == 'action') {
      var code = call.arguments['code'];
      var message = call.arguments['message'];
      switch (message) {
        case 'click':
          onClick?.call();
          break;
        case 'skip':
          onSkip?.call();
          break;
        case 'timeover':
          onTimeOver?.call();
          break;
        case 'timeout':
          onTimeOver?.call();
          break;
        case 'show':
          onShow?.call();
          break;
        default:
          onError?.call(code, message);
          break;
      }
    }
    return null;
  }
}
