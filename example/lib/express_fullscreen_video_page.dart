import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';
import 'package:pangle_ad_flutter/pangle_plugin.dart';

class ExpressFullscreenVideoPage extends StatefulWidget {
  @override
  _ExpressFullscreenVideoPageState createState() =>
      _ExpressFullscreenVideoPageState();
}

class _ExpressFullscreenVideoPageState
    extends State<ExpressFullscreenVideoPage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullscreen Video AD'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: RaisedButton(
                onPressed: _onTapLoad,
                child: Text('Load'),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: _loaded ? _onTapShow : null,
                child: Text('Show Ad'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  var kFullscreenVideoExpressId = "945702944";
  _onTapLoad() async {
    final result = await pangle.loadExpressFullscreenVideoAd(
      config: ExpressFullscreenVideoConfig(
        iOSSlotId: kFullscreenVideoExpressId,
        androidSlotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
    );

    setState(() {
      _loaded = result.ok;
    });
  }

  _onTapShow() async {
    final result = await pangle.loadExpressFullscreenVideoAd(
      config: ExpressFullscreenVideoConfig(
        iOSSlotId: kFullscreenVideoExpressId,
        androidSlotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
    );
    print(jsonEncode(result));
    setState(() {
      _loaded = false;
    });
  }
}
