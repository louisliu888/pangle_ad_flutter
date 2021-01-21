package net.goc.pangle_ad_flutter;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConfig;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTCustomController;
import com.bytedance.sdk.openadsdk.TTFeedAd;
import com.bytedance.sdk.openadsdk.TTLocation;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import net.goc.pangle_ad_flutter.factory.GocNativeExpressFeedAd;
import net.goc.pangle_ad_flutter.listener.GocExpressFeedAdListener;
import net.goc.pangle_ad_flutter.listener.GocExpressInterstitialAdListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodChannel;

public class PangleAdManager {

    public static PangleAdManager shared = new PangleAdManager();
    Context context;
    private  TTAdManager ttAdManager;
    private TTAdNative ttAdNative;

    private Map<String, GocNativeExpressFeedAd> feedAdCollection = new HashMap<String,GocNativeExpressFeedAd>();
    /**
     * 初始化
     * @param activity
     * @param args
     */
    public void initialize(Activity activity, Map<String, Object> args) {
        Log.e("ad","beging init pangle ad SDK...................");
        if ( activity == null) return;
        context = activity;


        String appId = args.get("appId").toString();
        boolean debug = args.get("debug")==null?false:(boolean)args.get("debug");
        boolean allowShowNotify = args.get("allowShowNotify")==null?true:(boolean)args.get("allowShowNotify");
        boolean allowShowPageWhenScreenLock = args.get("allowShowPageWhenScreenLock")==null?false:(boolean)args.get("allowShowPageWhenScreenLock");
        boolean supportMultiProcess = args.get("supportMultiProcess")==null?false:(boolean)args.get("supportMultiProcess");
        boolean useTextureView = args.get("useTextureView")==null?false:(boolean)args.get("useTextureView");
        int directDownloadNetworkType = args.get("directDownloadNetworkType")==null?0:Integer.parseInt(args.get("directDownloadNetworkType").toString());

        boolean paid = args.get("paid")==null?false:(boolean)args.get("paid");
        int titleBarThemeIndex = args.get("titleBarThemeIndex")==null?-1:Integer.parseInt(args.get("titleBarThemeIndex").toString());
        boolean isCanUseLocation = args.get("isCanUseLocation")==null?true:(boolean)args.get("isCanUseLocation");
        boolean isCanUsePhoneState = args.get("isCanUsePhoneState")==null?false:(boolean)args.get("isCanUsePhoneState");
        boolean isCanUseWriteExternal = args.get("isCanUseWriteExternal")==null?false:(boolean)args.get("isCanUseWriteExternal");
        boolean isCanUseWifiState = args.get("isCanUseWifiState")==null?false:(boolean)args.get("isCanUseWifiState");


        String devImei = args.get("devImei")==null? null:args.get("devImei").toString();
        String devOaid = args.get("devOaid")==null? null:args.get("devOaid").toString();

        Map<String, Double> location = args.get("location") ==null ?null : (Map<String, Double>)args.get("location");

        TTLocation ttLocation = null;
        if(location!=null){
            ttLocation = new TTLocation(location.get("latitude"),location.get("longitude"));
        }

        //强烈建议在应用对应的Application#onCreate()方法中调用，避免出现content为null的异常
        PackageManager packageManager = context.getPackageManager();
        Context applicationContext = context.getApplicationContext();
        PackageInfo pkgInfo = null;
        try {
            pkgInfo = packageManager.getPackageInfo(applicationContext.getPackageName(), 0);
        }catch (PackageManager.NameNotFoundException e ){
            e.printStackTrace();
        }

        //获取应用名
        String appName = pkgInfo.applicationInfo.loadLabel(packageManager).toString();

        TTAdConfig config = new TTAdConfig.Builder()
                .appId(appId)
                .useTextureView(useTextureView) //默认使用SurfaceView播放视频广告,当有SurfaceView冲突的场景，可以使用TextureView
                .appName(appName)
                .titleBarTheme(titleBarThemeIndex)//落地页主题
                .allowShowNotify(allowShowNotify) //是否允许sdk展示通知栏提示
                .debug(debug) //测试阶段打开，可以通过日志排查问题，上线时去除该调用
                .directDownloadNetworkType(TTAdConstant.NETWORK_STATE_WIFI) //允许直接下载的网络状态集合,没有设置的网络下点击下载apk会有二次确认弹窗，弹窗中会披露应用信息
                .supportMultiProcess(supportMultiProcess) //是否支持多进程，true支持
                .asyncInit(true) //是否异步初始化sdk,设置为true可以减少SDK初始化耗时
                .build();

        TTCustomController customController = new TTCustomController() {
            @Override
            public boolean isCanUseLocation() {
                return true;
            }

            @Override
            public TTLocation getTTLocation() {
                return null;
            }
            @Override
            public boolean alist() {
                return true;
            }
            @Override
            public boolean isCanUsePhoneState() {
                return true;
            }
            @Override
            public String getDevImei() {
                return null;
            }
            @Override
            public boolean isCanUseWifiState() {
                return true;
            }
            @Override
            public boolean isCanUseWriteExternal() {
                return true;
            }
            @Override
            public String getDevOaid() {
                return null;
            }

        };
        config.setCustomController(customController);
        TTAdSdk.init(applicationContext, config);

        ttAdManager = TTAdSdk.getAdManager();
        ttAdNative = ttAdManager.createAdNative(activity);
        Log.e("ad","end init pangle ad SDK...................");
    }

    /**
     * 获取SDK版本
     * @return
     */
    public String getSdkVersion() {
        return ttAdManager.getSDKVersion();
    }

    /**
     * 权限
     * @param context
     */
    public void requestPermissionIfNecessary(Context context) {
        ttAdManager.requestPermissionIfNecessary(context);
    }

    /**
     * 加载banner广告
     * @param adSlot
     * @param listener
     */
    public void loadExpressBannerAd(AdSlot adSlot , TTAdNative.NativeExpressAdListener listener ) {
        ttAdNative.loadBannerExpressAd(adSlot, listener);
    }

    /**
     * 加载开屏页广告
     * @param adSlot
     * @param listener
     * @param timeout
     */
    public void loadExpressSplashAd(AdSlot adSlot , TTAdNative.SplashAdListener listener , int timeout) {
         timeout =  timeout<=0 ? 5: timeout;
         ttAdNative.loadSplashAd(adSlot, listener, (timeout * 1000));
    }

    /**
     * 加载信息流广告
     * @param adSlot
     * @param width
     * @param height
     * @param result
     */
    public void loadFeedExpressAd(AdSlot adSlot, Double width, Double height, MethodChannel.Result result) {
        ttAdNative.loadNativeExpressAd(adSlot,new GocExpressFeedAdListener(result,width,height));
    }

    public List<String> setFeedAd(List<TTNativeExpressAd> ttFeedAds,Double width,Double height)  {
        List<String> data = new ArrayList<>();
        for(TTNativeExpressAd feedAD : ttFeedAds){
            String key = ""+feedAD.hashCode();
            feedAdCollection.put(key,new GocNativeExpressFeedAd(feedAD,width,height));
            data.add(key);
        }
        return data;
    }

    public GocNativeExpressFeedAd getFeedAd(String key ) {
        return feedAdCollection.get(key);
    }

    public void removeFeedAd(String key) {
        feedAdCollection.remove(key);
    }


    public void loadInteractionExpressAd(AdSlot adSlotInterstitial,MethodChannel.Result result){
        ttAdNative.loadInteractionExpressAd(adSlotInterstitial, new GocExpressInterstitialAdListener());
    }



}
