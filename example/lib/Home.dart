import 'package:flutter/material.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var kBannerId = "945700370";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Banner AD'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ExpressBannerView(
                config: ExpressBannerConfig(
                  iOSSlotId: kBannerId,
                  androidSlotId: kBannerId,
                  expressSize: PangleExpressSize(width: 600, height: 300),
                ),
              ),
              // BannerView(
              //   iOS: IOSBannerConfig(
              //     slotId: kBannerId,
              //     isExpress: false,
              //     imgSize: PangleImgSize.banner600_300,
              //   ),
              //   android: AndroidBannerConfig(
              //     slotId: kBannerId,
              //     isExpress: false,
              //     imgSize: PangleImgSize.banner600_300,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
