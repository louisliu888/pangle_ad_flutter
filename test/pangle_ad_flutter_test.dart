import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('pangle_ad_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await PangleAdFlutter.platformVersion, '42');
  // });
}
