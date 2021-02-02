import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs.dart';
import 'constant.dart';

final kExpressBannerViewType = 'net.goc.oceantide/pangle_expressbannerview';

typedef void ExpressBannerViewCreatedCallback(ExpressBannerViewController controller);

class PangleBannerExpressSize {
  double _width;
  double _height;
  PangleBannerExpressSize.withWidth(double pwidth, BannerSize size) {
    _width = pwidth;
    switch (size) {
      case BannerSize.banner_600_300:
        _height = _width * 300 / 600;
        break;
      case BannerSize.banner_600_400:
        _height = _width * 400 / 600;
        break;
      case BannerSize.banner_600_500:
        _height = _width * 500 / 600;
        break;
      case BannerSize.banner_600_260:
        _height = _width * 260 / 600;
        break;
      case BannerSize.banner_600_90:
        _height = _width * 90 / 600;
        break;
      case BannerSize.banner_600_150:
        _height = _width * 150 / 600;
        break;
      case BannerSize.banner_640_100:
        _height = _width * 100 / 640;
        break;
      case BannerSize.banner_690_388:
        _height = _width * 388 / 690;
        break;
      default:
        _height = _width * 9 / 16;
    }
  }

  double get width {
    return _width;
  }

  double get height {
    return _height;
  }

  Map<String, dynamic> toJson() {
    return {
      'width': _width,
      'height': _height,
    };
  }
}

enum BannerSize {
  banner_600_300,
  banner_600_400,
  banner_600_500,
  banner_600_260,
  banner_600_90,
  banner_600_150,
  banner_640_100,
  banner_690_388,
}

//个性化模板广告
class ExpressBannerConfig {
  final String iOSSlotId;
  final String androidSlotId;
  final PangleBannerExpressSize expressSize;
  final bool isUserInteractionEnabled;
  final int interval;

  /// The feed ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a banner ad.
  /// [expressSize] optional. 模板宽高
  /// [isUserInteractionEnabled] 广告位是否可点击，true可以，false不可以
  /// [interval] The carousel interval, in seconds, is set in the range of 30~120s,
  ///   and is passed during initialization. If it does not meet the requirements,
  ///   it will not be in carousel ad.
  ExpressBannerConfig({
    @required this.iOSSlotId,
    @required this.androidSlotId,
    this.expressSize,
    this.isUserInteractionEnabled = true,
    this.interval,
  })  : assert(androidSlotId.isNotBlank),
        assert(iOSSlotId.isNotBlank),
        assert(expressSize != null);

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'iOSSlotId': iOSSlotId,
      'androidSlotId': androidSlotId,
      'expressSize': expressSize?.toJson(),
      'isUserInteractionEnabled': isUserInteractionEnabled,
      'interval': interval,
    };
  }
}

/// Display banner AD
/// PlatformView does not support Android API level 19 or below.
class ExpressBannerView extends StatefulWidget {
  final ExpressBannerConfig config;
  final VoidCallback onRemove;
  final ExpressBannerViewCreatedCallback onBannerViewCreated;

  const ExpressBannerView({
    Key key,
    this.config,
    this.onBannerViewCreated,
    this.onRemove,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExpressBannerViewState();
}

class ExpressBannerViewState extends State<ExpressBannerView> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  ExpressBannerViewController _controller;
  //final _kDevicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
  bool _offstage = true;
  bool _removed = false;
  double _adWidth = 100.00;
  double _adHeight = 50.00;

  Size _lastSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    var size = WidgetsBinding.instance.window.physicalSize;
    _lastSize = size;
    WidgetsBinding.instance.addObserver(this);
    var expressSize = widget.config.expressSize;
    _adWidth = expressSize == null ? size.width : expressSize.width;
    _adHeight = expressSize == null ? 200 : expressSize.height;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("banner广告----->dispose=======================");

    _remove();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExpressBannerView oldWidget) {
    print("banner didUpdateWidget=============================");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print("banner deactivate============================");
    super.deactivate();
  }

  @override
  void didChangeMetrics() {
    print("didChangeMetrics============================");
    var size = WidgetsBinding.instance.window.physicalSize;
    if (_lastSize?.width != size.width || _lastSize?.height != size.height) {
      _lastSize = size;
      _controller?.update(_createParams());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_removed) {
      return SizedBox.shrink();
    }
    Widget body;
    try {
      Widget platformView;
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = AndroidView(
          viewType: kExpressBannerViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(context, index),
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kExpressBannerViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(context, index),
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      }
      if (platformView != null) {
        body = Offstage(
          offstage: _offstage,
          child: Container(
            alignment: Alignment.center,
            width: _adWidth,
            height: _adHeight,
            child: platformView,
          ),
        );
      }
    } on PlatformException {
      print("ExpressBannerViewState create Error");
    }
    if (body == null) {
      body = SizedBox.shrink();
    }

    return body;
  }

  /// 设置广告位是否可以点击，默认true
  /// [enable]
  void setUserInteractionEnabled(bool enable) {
    _controller?.setUserInteractionEnabled(enable);
  }

  void _remove() {
    _controller?.remove();
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    print("_onPlatformViewCreated:${_adWidth}高:${_adHeight}");
    final removed = () {
      if (widget.onRemove != null) {
        widget.onRemove();
      } else {
        if (mounted) {
          setState(() {
            this._removed = true;
          });
        }
      }
    };
    final updated = (args) {
      double width = args['width'];
      double height = args['height'];
      print("update banner 广告的高度和宽度:原始宽:${_adWidth}高:${_adHeight}-------------> 更新:${width} 高:${height}");
      if (mounted) {
        setState(() {
          this._offstage = false;
          this._adWidth = width;
          this._adHeight = height;
        });
      }
    };

    var controller = ExpressBannerViewController._(id, onRemove: removed, onUpdate: updated);
    _controller = controller;
    if (widget.onBannerViewCreated == null) {
      return;
    }
    widget.onBannerViewCreated(controller);
  }

  void updateWidget(BuildContext context, bool success) {
    if (mounted) {
      setState(() {
        _offstage = !success;
      });
    }
  }

  Map<String, dynamic> _createParams() {
    return widget.config.toJSON();
  }
}

enum ExpressBannerMethod {
  remove,
  reload,
}

class ExpressBannerViewController {
  MethodChannel _methodChannel;
  final VoidCallback onRemove;
  final SizeCallback onUpdate;

  ExpressBannerViewController._(
    int id, {
    this.onRemove,
    this.onUpdate,
  }) {
    _methodChannel = new MethodChannel('${kExpressBannerViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  void remove() {
    _methodChannel.invokeMethod('remove');
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    print("====${call.method}========${call.arguments}");
    switch (call.method) {
      case 'remove':
        if (onRemove != null) {
          onRemove();
        }
        break;
      case 'update':
        final params = call.arguments as Map<dynamic, dynamic>;
        if (onUpdate != null) {
          onUpdate(params);
        }
        break;
      default:
        break;
    }
    return null;
  }

  Future<Null> update(Map<String, dynamic> params) async {
    await _methodChannel?.invokeMethod('update', params);
  }

  void setUserInteractionEnabled(bool enable) {
    if (Platform.isIOS) {
      _methodChannel.invokeMethod("setUserInteractionEnabled", enable ?? false);
    }
  }
}
