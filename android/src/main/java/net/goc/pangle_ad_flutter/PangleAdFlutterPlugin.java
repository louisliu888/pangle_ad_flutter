package net.goc.pangle_ad_flutter;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.AdSlot;

import net.goc.pangle_ad_flutter.factory.GocExpressBannerViewFactory;
import net.goc.pangle_ad_flutter.factory.GocExpressFeedViewFactory;
import net.goc.pangle_ad_flutter.factory.GocExpressSplashViewFactory;

import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** PangleAdFlutterPlugin */
public class PangleAdFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private  MethodChannel channel;
  private Activity activity = null;
  private Context context;
  private  int kDefaultBannerAdCount = 3;
  private  int kDefaultFeedAdCount = 3;
  private  String kChannelName = "neg.goc.oceantide/pangle_ad_flutter";
  GocExpressBannerViewFactory expressBannerViewFactory;
  GocExpressSplashViewFactory expressSplashViewFactory;
  GocExpressFeedViewFactory expressFeedViewFactory;

  @Override
   public void onAttachedToActivity(@NonNull ActivityPluginBinding binding){
    Log.e("ERROR","onAttachedToActivity===================");
     activity = binding.getActivity();
     expressFeedViewFactory.attachActivity(binding.getActivity());
    expressBannerViewFactory.attachActivity(binding.getActivity());
    expressSplashViewFactory.attachActivity(binding.getActivity());
   }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    Log.e("ERROR","onReattachedToActivityForConfigChanges===================");
    activity = binding.getActivity();
    expressFeedViewFactory.attachActivity(binding.getActivity());
    expressBannerViewFactory.attachActivity(binding.getActivity());
    expressSplashViewFactory.attachActivity(binding.getActivity());
  }
  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.e("ERROR","onDetachedFromActivityForConfigChanges===================");
    expressFeedViewFactory.detachActivity();
    expressBannerViewFactory.detachActivity();
    expressSplashViewFactory.detachActivity();
    activity = null;
  }

  @Override
  public void onDetachedFromActivity() {
    Log.e("ERROR","onDetachedFromActivity===================");
    expressFeedViewFactory.detachActivity();
    expressBannerViewFactory.detachActivity();
    expressSplashViewFactory.detachActivity();
    activity = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

    Log.e("ERROR","onAttachedToEngine===================插件注册");
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), kChannelName);
    channel.setMethodCallHandler(this);

    // 注册视图

    expressBannerViewFactory = new GocExpressBannerViewFactory(flutterPluginBinding.getBinaryMessenger());
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("net.goc.oceantide/pangle_expressbannerview",  expressBannerViewFactory);

    expressSplashViewFactory = new GocExpressSplashViewFactory(flutterPluginBinding.getBinaryMessenger());
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("net.goc.oceantide/pangle_expresssplashview",
            expressSplashViewFactory);

    expressFeedViewFactory = new GocExpressFeedViewFactory(flutterPluginBinding.getBinaryMessenger());
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("net.goc.oceantide/pangle_expressfeedview",
            expressFeedViewFactory);

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    PangleAdManager pangle = PangleAdManager.shared;

    switch (call.method){
      case "getSdkVersion":
        String version = pangle.getSdkVersion();
        result.success(version);
        break;
      case "init":
        try {
          pangle.initialize(activity, (Map<String,Object>)call.arguments);
        } catch ( Exception e) {
          e.printStackTrace();
        }
        result.success(null);
        break;
      case "requestPermissionIfNecessary":
        pangle.requestPermissionIfNecessary(context);
        break;
      case "loadExpressFeedAd": // 模板信息流广告
        Map<String,Object> params = (Map<String,Object>)call.arguments;

        String slotId = params.get("androidSlotId").toString();
        int count = params.get("count") == null ? kDefaultFeedAdCount: Integer.parseInt(params.get("count").toString());
        boolean isSupportDeepLink = params.get("isSupportDeepLink") == null ? true: Boolean.parseBoolean(params.get("isSupportDeepLink").toString());

        Map<String,Double> expressArgs = (Map<String, Double>)params.get("expressSize");
        Double expressWidth = expressArgs.get("width");
        Double expressHeight = expressArgs.get("height");

        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(slotId) //广告位id
                .setSupportDeepLink(isSupportDeepLink)
                .setAdCount(count) //请求广告数量为1到3条
                .setExpressViewAcceptedSize(expressWidth.floatValue(),expressHeight.floatValue()) //期望模板广告view的size,单位dp
                .build();
        pangle.loadFeedExpressAd(adSlot,expressWidth,expressHeight,result);
//          {
//            result.success(it)
//          }
        break;
      case "loadExpressInterstitialAd": // 插屏广告
        Map<String,Object> interstitialParams = (Map<String,Object>)call.arguments;

        String interstitialSlotId = interstitialParams.get("androidSlotId").toString();
        boolean deepLink = params.get("isSupportDeepLink") == null ? true: Boolean.parseBoolean(params.get("isSupportDeepLink").toString());
        Map<String,Double> interstitialExpressArgs = (Map<String,Double>)interstitialParams.get("expressSize") ;
        Double iexpressWidth = expressArgs.get("width");
        Double iexpressHeight = expressArgs.get("height");

        val adSlot = PangleAdSlotManager.getInterstitialAdSlot(slotId, isExpress, expressSize, imgSizeIndex, isSupportDeepLink)

        pangle.loadInteractionExpressAd(adSlot, FLTInterstitialExpressAd(activity) {
          result.success(it)
        });
        break;
      case "loadExpressFullscreenVideoAd": //全屏视频广告
        break;
      default:
        result.notImplemented();
    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
