package net.goc.pangle_ad_flutter;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;

import net.goc.pangle_ad_flutter.factory.GocExpressBannerViewFactory;
import net.goc.pangle_ad_flutter.factory.GocExpressFeedViewFactory;
import net.goc.pangle_ad_flutter.factory.GocExpressSplashViewFactory;
import net.goc.pangle_ad_flutter.listener.GocExpressInterstitialAdListener;
import net.goc.pangle_ad_flutter.listener.GocFullScreenAdListener;

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
    Log.e("ERROR","onAttachedToActivity==========================================================================");
     activity = binding.getActivity();
     expressFeedViewFactory.attachActivity(binding.getActivity());
     expressBannerViewFactory.attachActivity(binding.getActivity());
    //expressSplashViewFactory.attachActivity(binding.getActivity());
   }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    Log.e("ERROR","onReattachedToActivityForConfigChanges==========================================================================");
    activity = binding.getActivity();
    expressFeedViewFactory.attachActivity(binding.getActivity());
    expressBannerViewFactory.attachActivity(binding.getActivity());
    //expressSplashViewFactory.attachActivity(binding.getActivity());
  }
  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.e("ERROR","onDetachedFromActivityForConfigChanges==========================================================================");
    expressFeedViewFactory.detachActivity();
    expressBannerViewFactory.detachActivity();
    //expressSplashViewFactory.detachActivity();
    activity = null;
  }

  @Override
  public void onDetachedFromActivity() {
    Log.e("ERROR","onDetachedFromActivity==========================================================================");
    expressFeedViewFactory.detachActivity();
    expressBannerViewFactory.detachActivity();
    //expressSplashViewFactory.detachActivity();
    activity = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

    Log.e("ERROR","onAttachedToEngine=========================插件注册==========================================================================");
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
        result.success(null);
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
        //result.success(true);
        break;
      case "loadExpressInterstitialAd": // 插屏广告
        Map<String,Object> interstitialParams = (Map<String,Object>)call.arguments;

        String interstitialSlotId = interstitialParams.get("androidSlotId").toString();
        boolean deepLink = interstitialParams.get("isSupportDeepLink") == null ? true: Boolean.parseBoolean(interstitialParams.get("isSupportDeepLink").toString());
        Map<String,Double> interstitialExpressArgs = (Map<String,Double>)interstitialParams.get("expressSize") ;
        Double iexpressWidth = interstitialExpressArgs.get("width");
        Double iexpressHeight = interstitialExpressArgs.get("height");

        AdSlot adSlotInterstitial = new AdSlot.Builder()
                .setCodeId(interstitialSlotId) //广告位id
                .setSupportDeepLink(deepLink)
                .setAdCount(1) //请求广告数量为1到3条
                .setExpressViewAcceptedSize(iexpressWidth.floatValue(),iexpressHeight.floatValue()) //期望模板广告view的size,单位dp
                .build();

        pangle.loadInteractionExpressAd(adSlotInterstitial,new GocExpressInterstitialAdListener(this.activity,channel)) ;
        result.success(null);
        break;
      case "loadExpressFullscreenVideoAd": //全屏视频广告
        Map<String,Object> fullscreenParams = (Map<String,Object>)call.arguments;

        String fullscreenSlotId = fullscreenParams.get("androidSlotId").toString();
        Map<String,Double> fullscreenParamsArgs = (Map<String,Double>)fullscreenParams.get("expressSize") ;
        AdSlot fullscreenAdSlot;
        if(fullscreenParamsArgs != null && fullscreenParamsArgs.size()>0){
          Double fexpressWidth = fullscreenParamsArgs.get("width");
          Double fexpressHeight = fullscreenParamsArgs.get("height");

          fullscreenAdSlot = new AdSlot.Builder()
                  .setCodeId(fullscreenSlotId)
                  //模板广告需要设置期望个性化模板广告的大小,单位dp,激励视频场景，只要设置的值大于0即可 且仅是模板渲染的代码位ID使用，非模板渲染代码位切勿使用
                  .setExpressViewAcceptedSize(fexpressWidth.floatValue(),fexpressHeight.floatValue())
                  .setSupportDeepLink(true)
                  .setOrientation(TTAdConstant.VERTICAL)//必填参数，期望视频的播放方向：TTAdConstant.HORIZONTAL 或 TTAdConstant.VERTICAL
                  .build();
        }else{
          //TTAdNative mTTAdNative = TTAdSdk.getAdManager().createAdNative(this); //SDK渲染请求AdSlot
          fullscreenAdSlot = new AdSlot.Builder()
                  .setCodeId(fullscreenSlotId)
                  .setSupportDeepLink(true)
                  .setOrientation(TTAdConstant.VERTICAL)//必填参数，期望视频的播放方向：TTAdConstant.HORIZONTAL 或 TTAdConstant.VERTICAL
                  .build();
        }



        pangle.loadFullScreenExpressAd(fullscreenAdSlot,new GocFullScreenAdListener(this.activity,this.channel)); ;
        result.success(null);
        break;
      default:
        result.notImplemented();
    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.e("ERROR","onDetachedFromEngine==========================================================================");
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
