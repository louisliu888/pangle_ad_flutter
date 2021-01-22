import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';
import 'package:pangle_ad_flutter/pangle_plugin.dart';

class InterstitialExpressPage extends StatefulWidget {
  @override
  _InterstitialExpressPageState createState() => _InterstitialExpressPageState();
}

class _InterstitialExpressPageState extends State<InterstitialExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Express AD'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: RaisedButton(
                onPressed: _onTapShow,
                child: Text('Show Ad'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapShow() async {
    final width = kPangleScreenWidth - 30;
    final height = width / 1.667;

    final result = await pangle.loadExpressInterstitialAd(
      config: ExpressInterstitialConfig(
        iOSSlotId: "945702436",
        androidSlotId: "945702436",
        // 该宽高为你申请的广告位宽高，请根据实际情况赋值
        expressSize: PangleExpressSize(width: width, height: height),
      ),
    );
    print(result);
  }
}
