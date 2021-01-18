import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';
import 'package:pangle_ad_flutter/pangle_plugin.dart';

import 'Home.dart';
import 'express_feed_page.dart';
import 'express_fullscreen_video_page.dart';
import 'express_interstitial_page.dart';
import 'express_splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initPangle();
  runApp(MyApp());
}

Future<Null> initPangle() async {
  await pangle.init(
    iOS: IOSConfig(
      appId: "5129755",
      logLevel: PangleLogLevel.error,
    ),
    android: AndroidConfig(
      appId: "5129755",
      debug: false,
      allowShowNotify: true,
      allowShowPageWhenScreenLock: false,
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var timeInterval = const Duration(seconds: 1);
  var _timer;

  @override
  void dispose() {
    // 组件销毁时判断Timer是否仍然处于激活状态，是则取消
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(timeInterval, (timer) {
    //   // 循环一定要记得设置取消条件，手动取消
    //   print("xxxxxx$mounted");
    //   if (mounted) {
    //     _timer.cancel();
    //     Navigator.pushNamed(context, '/second')
    //         .then((value) => print(value))
    //         .catchError((err) {
    //       print(err);
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: Container(color: Colors.red, child: ExpressSplashPage()),
      initialRoute: '/',
      routes: {
        '/home': (context) => HomePage(),
        '/second': (context) => ExpressSplashPage()
      },
    );
  }
}
