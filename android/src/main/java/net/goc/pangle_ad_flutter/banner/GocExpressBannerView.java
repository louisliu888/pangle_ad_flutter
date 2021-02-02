package net.goc.pangle_ad_flutter.banner;

import android.app.Activity;
import android.content.res.Resources;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class GocExpressBannerView implements PlatformView, MethodChannel.MethodCallHandler,TTAdNative.NativeExpressAdListener,
        TTNativeExpressAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {


    private MethodChannel methodChannel;
    private FrameLayout container ;
    private WeakReference<Activity> activity;
    private TTNativeExpressAd ad;

    private int interval;
    Double expressWidth = 0.0 ;
    Double expressHeight = 0.0 ;
    String slotId ;

    public GocExpressBannerView(WeakReference<Activity> activity, BinaryMessenger messenger, int id, Object args) {

        Log.d("Banner","GocExpressBannerView=========SDK版本:" + TTAdSdk.getAdManager().getSDKVersion());
        methodChannel = new MethodChannel(messenger, "net.goc.oceantide/pangle_expressbannerview_"+id);
        methodChannel.setMethodCallHandler(this);
        this.activity = activity;
        container = new FrameLayout(activity.get());

        Map<String,Object> params = (Map<String,Object>)args;
        slotId = params.get("androidSlotId").toString();

        if (slotId != null) {
            interval = params.get("interval") == null ? 0 : Integer.parseInt(params.get("interval").toString());
            Map<String, Double> expressArgs = (Map<String, Double>)params.get("expressSize");
            expressWidth  = (Double)expressArgs.get("width");
            expressHeight = (Double)expressArgs.get("height");

            float density = Resources.getSystem().getDisplayMetrics().density;
            AdSlot adSlot = new AdSlot.Builder()
                    .setCodeId(slotId) //广告位id
                    .setSupportDeepLink(true)
                    .setAdCount(1) //请求广告数量为1到3条
                    //.setImageAcceptedSize((int)(expressWidth*density),(int)(expressHeight*density))
                    .setExpressViewAcceptedSize(expressWidth.floatValue(),expressHeight.floatValue()) //期望模板广告view的size,单位dp
                    .build();
            TTAdManager ttAdManager = TTAdSdk.getAdManager();
            TTAdNative ttAdNative = ttAdManager.createAdNative(activity.get());
            ttAdNative.loadBannerExpressAd(adSlot, this);
            //ttAdNative.loadNativeExpressAd(adSlot,this);
        }

    }

    private void invalidateView(Double width, Double height) {
         //这里不能强加约束
        //container.setLayoutParams(new FrameLayout.LayoutParams(width.intValue(),height.intValue(),Gravity.CENTER));
        Map<String,Object> params = new HashMap<String,Object>();
        params.put("width",width);
        params.put("height",height);
        methodChannel.invokeMethod("update", params);

    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        Log.d("Banner","onFlutterViewAttached==========================================");
    }

    @Override
    public void onFlutterViewDetached() {
        Log.d("Banner","onFlutterViewDetached==========================================");
    }

    @Override
    public void onInputConnectionLocked() {
        Log.d("Banner","onInputConnectionLocked==========================================");
    }

    @Override
    public void onInputConnectionUnlocked() {
        Log.d("Banner","onInputConnectionUnlocked==========================================");
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d("Banner",call.method+".............................banner 广告=========");
        switch (call.method){
            case "update":
                invalidateView(expressWidth, expressHeight);
                result.success(null);
                break;
            case "remove":
                clear();

                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        Log.d("Banner","Banner dispose========================================");
        clear();
    }

    private void clear(){
        if(ad != null){
            ad.destroy();
            this.ad = null;
        }
        container.removeAllViews();
        this.activity = null;
    }

    @Override
    public void onSelected(int i, String s) {
        Log.e("Banner","Banner 广告 onSelected......=============================================================================");
        container.removeAllViews();
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onCancel() {
        Log.e("Banner","Banner 广告 onCancel......=============================================================================");
    }

    @Override
    public void onRefuse() {
        Log.e("Banner","Banner 广告 onRefuse......=============================================================================");
    }

    @Override
    public void onError(int i, String s) {
        Log.e("Banner","Banner 广告 onError....code:"+i +" message:"+s);
        container.removeAllViews();
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onNativeExpressAdLoad(List<TTNativeExpressAd> ttNativeExpressAds) {
        Log.e("Banner","Banner 广告 onNativeExpressAdLoad......=============================================================================");

        if (ttNativeExpressAds == null || ttNativeExpressAds.isEmpty()) {
            return;
        }
        ad = ttNativeExpressAds.get(0);

        //设置广告互动监听回调
        ad.setExpressInteractionListener(this);

        //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
        ad.setDislikeCallback(activity.get(), this);
        // 设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
        if(interval >29){
            ad.setSlideIntervalTime(interval);
        }
        ad.render();

        //container.removeAllViews();
        //expressAdView = ad.getExpressAdView();

    }

    @Override
    public void onAdDismiss() {
        clear();
        Log.e("Banner","Banner 广告 onAdDismiss......=============================================================================");
    }

    @Override
    public void onAdClicked(View view, int i) {
        Log.e("Banner","Banner 广告 onAdClicked......=============================================================================");
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onAdShow(View view, int i) {
        int height=view.getMeasuredHeight();
        int width=view.getMeasuredWidth();
        Log.e("Banner",height +"======" + width+"Banner 广告 onAdShow......=============================================================================");
        //Log.e("Banner","Banner 广告 onAdShow......=============================================================================");
    }

    @Override
    public void onRenderFail(View view, String s, int i) {
        Log.e("Banner","Banner 广告 renderFail......=============================================================================");
        clear();
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onRenderSuccess(View view, float v, float v1) {

        Log.e("Banner","Banner 广告 onRenderSuccess......=============================================================================");
        int height=view.getMeasuredHeight();
        int width=view.getMeasuredWidth();
        io.flutter.Log.e("Banner",height +"======" + width+"Banner 广告 onRenderSuccess......=============================================================================");
        Map<String,Object> params = new HashMap<String,Object>();
        params.put("width",expressWidth);
        params.put("height",expressHeight);
        methodChannel.invokeMethod("update", params);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        container.addView(ad.getExpressAdView(),layoutParams);
    }
}
