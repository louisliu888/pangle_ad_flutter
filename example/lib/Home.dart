import 'package:flutter/material.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';
import 'package:pangle_ad_flutter/pangle_plugin.dart';

import 'express_feed_page.dart';
import 'express_fullscreen_video_page.dart';
import 'express_interstitial_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var kBannerId = "945804687";
  ExpressBannerViewController controller;

  @override
  void initState() {
    final _kDevicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final _kPhysicalSize = WidgetsBinding.instance.window.physicalSize;
    print("louis:_kDevicePixelRatio:$_kDevicePixelRatio   width:${_kPhysicalSize.width} height:${_kPhysicalSize.height}");

    final kPangleScreenWidth = _kPhysicalSize.width / _kDevicePixelRatio;
    final kPangleScreenHeight = _kPhysicalSize.height / _kDevicePixelRatio;
    print("louis:kPangleScreenWidth:$kPangleScreenWidth   kPangleScreenHeight:$kPangleScreenHeight");
    pangle.requestPermissionIfNecessary();

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
              // FutureBuilder(
              //   future: pangle.loadExpressBannerAd(
              //     config: ExpressBannerConfig(
              //       iOSSlotId: kBannerId,
              //       androidSlotId: kBannerId,
              //       expressSize: PangleBannerExpressSize.withWidth(kPangleScreenWidth, BannerSize.banner_600_300),
              //     ),
              //   ),
              //   builder: (context, snap) {
              //     if (snap.connectionState == ConnectionState.done) {
              //       return ExpressBannerView(
              //         config: ExpressBannerConfig(
              //             iOSSlotId: kBannerId,
              //             androidSlotId: kBannerId,
              //             expressSize: PangleBannerExpressSize.withWidth(kPangleScreenWidth, BannerSize.banner_600_300) //PangleExpressSize.aspectRatio(3),

              //             ),
              //         onBannerViewCreated: (controller) {
              //           this.controller = controller;
              //         },
              //       );
              //     } else {
              //       return Container();
              //     }
              //   },
              // ),
              ExpressBannerView(
                config: ExpressBannerConfig(
                    iOSSlotId: "945804687",
                    androidSlotId: "945804680",
                    expressSize: PangleBannerExpressSize.withWidth(kPangleScreenWidth, BannerSize.banner_600_300) //PangleExpressSize.aspectRatio(3),

                    ),
                onBannerViewCreated: (controller) {
                  this.controller = controller;
                },
              ),

              // InkWell(
              //   onTap: () {
              //     pangle
              //         .loadExpressBannerAd(
              //       config: ExpressBannerConfig(
              //         iOSSlotId: "945804687",
              //         androidSlotId: "945804680",
              //         expressSize: PangleBannerExpressSize.withWidth(kPangleScreenWidth, BannerSize.banner_600_300),
              //       ),
              //     )
              //         .then((value) {
              //       controller.update({});
              //     });
              //   },
              //   child: ListTile(
              //     title: Text("重新加载banner"),
              //   ),
              // ),

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
