import 'package:flutter/material.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';

import 'express_feed_page.dart';
import 'express_fullscreen_video_page.dart';
import 'express_interstitial_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var kBannerId = "945700370";

  @override
  void initState() {
    final _kDevicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final _kPhysicalSize = WidgetsBinding.instance.window.physicalSize;
    print("louis:_kDevicePixelRatio:$_kDevicePixelRatio   width:${_kPhysicalSize.width} height:${_kPhysicalSize.height}");

    final kPangleScreenWidth = _kPhysicalSize.width / _kDevicePixelRatio;
    final kPangleScreenHeight = _kPhysicalSize.height / _kDevicePixelRatio;
    print("louis:kPangleScreenWidth:$kPangleScreenWidth   kPangleScreenHeight:$kPangleScreenHeight");
    super.initState();
  }

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
                config: ExpressBannerConfig(iOSSlotId: kBannerId, androidSlotId: kBannerId, expressSize: PangleExpressSize.aspectRatio16_9() //PangleExpressSize.aspectRatio(3),
                    ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ExpressFeedPage();
                  }));
                },
                child: ListTile(
                  title: Text("信息流"),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return InterstitialExpressPage();
                  }));
                },
                child: ListTile(
                  title: Text("插屏广告"),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ExpressFullscreenVideoPage();
                  }));
                },
                child: ListTile(
                  title: Text("全屏视频广告"),
                ),
              )
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
