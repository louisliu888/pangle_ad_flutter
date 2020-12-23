enum PangleAuthorizationStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
}

/// log level, only ios works.
enum PangleLogLevel {
  none,
  error,
  debug,
}

/// The type of loading ads.
///
/// [normal] Showing ads up without preloading.
/// [preload] Showing ads up and preloading next ads.
/// [preload_only] Preloading ads only, not showing ads up.
enum PangleLoadingType {
  normal,
  preload,
  preload_only,
}

/// Pick image size for ad
/// From [v0.2.0] not works for express ads.
enum PangleImgSize {
  banner640_90,
  banner640_100,
  banner600_150,
  banner600_260,
  banner600_286,
  banner600_300,
  banner690_388,
  banner600_400,
  banner600_500,
  feed228_150,
  feed690_388,
  interstitial600_400,
  interstitial600_600,
  interstitial600_900,
  drawFullScreen,
}

/// title bar theme for land page, only android works.
enum AndroidTitleBarTheme {
  light,
  dark,
  no_title_bar,
}

/// available network type for downloading type ad.
class AndroidDirectDownloadNetworkType {
  static const int kNone = 0;
  static const int kMobile = 1;
  static const int k2G = 2;
  static const int k3G = 3;
  static const int kWiFi = 4;
  static const int k4G = 5;
}

enum PangleOrientation {
  // ignore: unused_field
  _,
  veritical,
  horizontal,
}

/// default size
const kPangleSize = 1.0;

/// params contain width, height.
typedef SizeCallback = void Function(Map<dynamic, dynamic> params);

extension CheckNotNull on String {
  bool get isNotBlank => this?.isNotEmpty ?? false;
}
