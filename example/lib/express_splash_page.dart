import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';

import 'Home.dart';

class ExpressSplashPage extends StatefulWidget {
  final bool isRoot;

  const ExpressSplashPage({Key key, this.isRoot = true}) : super(key: key);

  @override
  _ExpressSplashPageState createState() => _ExpressSplashPageState();
}

class _ExpressSplashPageState extends State<ExpressSplashPage> {
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ExpressSplashView(
                    config: ExpressSplashConfig(
                        iOSSlotId: "887416348",
                        androidSlotId: "887416348",
                        expressSize:
                            PangleExpressSize(width: 375, height: 667)),
                    backgroundColor: Colors.white,
                    onTimeOver: _handleAdEnd,
                    onSkip: _handleAdEnd,
                    onClick: _handleAdEnd,
                    onError: (code, message) {
                      print("=======$code");
                      print(message);
                    },
                    onShow: _handleAdStart,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  height: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlutterLogo(size: 40),
                      SizedBox(height: 10),
                      Text('Pangle Flutter'),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Offstage(
          //   offstage: _showAd,
          //   child: Container(
          //     color: Colors.white,
          //     alignment: Alignment.center,
          //     child: FlutterLogo(size: 100),
          //   ),
          // ),
        ],
      ),
    );
  }

  _handleAdStart() {
    print("_handleAdStart==================");
    setState(() {
      _showAd = true;
    });
  }

  _handleAdEnd() {
    print("_handleAdEnd==================");
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    //Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HomePage();
    }));

    if (widget.isRoot) {}
  }
}
