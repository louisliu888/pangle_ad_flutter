import Flutter
import UIKit
import BUAdSDK
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
#if canImport(AdSupport)
import AdSupport
#endif

public class SwiftPangleAdFlutterPlugin: NSObject, FlutterPlugin {
    
  private let methodChannel: FlutterMethodChannel

  init(_ methodChannel: FlutterMethodChannel) {
   self.methodChannel = methodChannel
  }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    // 注册插件
    let channel = FlutterMethodChannel(name: "neg.goc.oceantide/pangle_ad_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftPangleAdFlutterPlugin(channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
 
    //注册banner，开屏，信息流广告的VIEW
    let bannerViewFactory = GocExpressBannerViewFactory(messenger: registrar.messenger())
    registrar.register(bannerViewFactory, withId: "net.goc.oceantide/pangle_expressbannerview")
    
    let expressSplashViewFactory = GocExpressSplashViewFactory(messenger: registrar.messenger())
    registrar.register(expressSplashViewFactory, withId: "net.goc.oceantide/pangle_expresssplashview")
    
    let expressfeedViewFactory = GocExpressFeedViewFactory(messenger: registrar.messenger())
    registrar.register(expressfeedViewFactory, withId: "net.goc.oceantide/pangle_expressfeedview")
//
//    let feedViewFactory = FeedViewFactory(messenger: registrar.messenger())
//    registrar.register(feedViewFactory, withId: "nullptrx.github.io/pangle_feedview")
//
//    let splashViewFactory = SplashViewFactory(messenger: registrar.messenger())
//    registrar.register(splashViewFactory, withId: "nullptrx.github.io/pangle_splashview")
  }
    

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let instance = PangleAdManager.shared
    let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
    
    switch call.method {
    case "getSdkVersion":
        result(BUAdSDKManager.sdkVersion)
    case "init":
        instance.initialize(args)
        result(nil)
    case "getTrackingAuthorizationStatus":
        if #available(iOS 14.0, *) {
            result(ATTrackingManager.trackingAuthorizationStatus.rawValue)
        } else {
            result(nil)
        }
    case "requestTrackingAuthorization":
        /// 适配App Tracking Transparency（ATT）
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                result(status.rawValue)
             })
        } else {
            result(nil)
        }
    case "loadExpressFeedAd": // 加载信息流模板广告
        instance.loadExpressFeedAd(args, result: result)
    case "loadExpressInterstitialAd":
        instance.loadExpressInterstitialAd(args, result: result)
    case "loadExpressFullscreenVideoAd":
        instance.loadExpressFullscreenVideoAd(args, result: result)
//    case "loadRewardedVideoAd":
//        instance.loadRewardVideoAd(args, result: result)
//    case "loadFeedAd":
//        instance.loadFeedAd(args, result: result)
//    case "loadInterstitialAd":
//        break
//       // instance.loadInterstitialAd(args, result: result)
//    case "loadFullscreenVideoAd":
//        instance.loadFullscreenVideoAd(args, result: result)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
