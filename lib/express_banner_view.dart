import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs.dart';
import 'constant.dart';

final kExpressBannerViewType = 'net.goc.oceantide/pangle_expressbannerview';

typedef void ExpressBannerViewCreatedCallback(ExpressBannerViewController controller);

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
  final _kDevicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
  bool _offstage = true;
  bool _removed = false;
  double _adWidth = kPangleSize;
  double _adHeight = kPangleSize;

  Size _lastSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    var size = WidgetsBinding.instance.window.physicalSize;
    _lastSize = size;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _remove();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    var size = WidgetsBinding.instance.window.physicalSize;
    if (_lastSize?.width != size.width || _lastSize?.height != size.height) {
      _lastSize = size;
      _controller?._update(_createParams());
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
            width: _adWidth,
            height: _adHeight,
            child: platformView,
          ),
        );
      }
    } on PlatformException {}
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

  Future<Null> _update(Map<String, dynamic> params) async {
    await _methodChannel?.invokeMethod('update', params);
  }

  void setUserInteractionEnabled(bool enable) {
    if (Platform.isIOS) {
      _methodChannel.invokeMethod("setUserInteractionEnabled", enable ?? false);
    }
  }
}
