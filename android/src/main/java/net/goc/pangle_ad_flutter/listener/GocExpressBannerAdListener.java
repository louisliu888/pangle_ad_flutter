package net.goc.pangle_ad_flutter.listener;

import android.app.ActionBar;
import android.app.Activity;
import android.view.View;
import android.widget.FrameLayout;

import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import java.lang.reflect.Method;
import java.util.List;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class GocExpressBannerAdListener implements  TTAdNative.NativeExpressAdListener,
        TTNativeExpressAd.AdInteractionListener, TTAdDislike.DislikeInteractionCallback {

    private FrameLayout container;
    private MethodChannel methodChannel;
    private Activity activity;
    private int interval;

    public GocExpressBannerAdListener(FrameLayout container, MethodChannel methodChannel,Activity activity,int interval){
        this.container = container;
        this.methodChannel = methodChannel;
        this.activity = activity;
        this.interval = interval;
    }

    @Override
    public void onSelected(int i, String s) {
        container.removeAllViews();
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onCancel() {

    }

    @Override
    public void onRefuse() {

    }

    @Override
    public void onError(int i, String s) {
        Log.e("Banner","Banner 广告 onError....code:"+i +" message:"+s);
        container.removeAllViews();
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onNativeExpressAdLoad(List<TTNativeExpressAd> ttNativeExpressAds) {
        if (ttNativeExpressAds == null || ttNativeExpressAds.isEmpty()) {
            return;
        }
//      println("BannerView: load ${Date().toGMTString()}")
        TTNativeExpressAd ad = ttNativeExpressAds.get(0);

        //设置广告互动监听回调
        ad.setExpressInteractionListener(this);

        //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
        ad.setDislikeCallback(activity, this);
        // 设置轮播的时间间隔  间隔在30s到120秒之间的值，不设置默认不轮播
        if(interval >29){
            ad.setSlideIntervalTime(interval);
        }
        ad.render();

        container.removeAllViews();
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        View expressAdView = ad.getExpressAdView();
        container.addView(expressAdView, params);
        Log.e("Banner","Banner 广告 onNativeExpressAdLoad......");
    }

    @Override
    public void onAdDismiss() {
        Log.e("Banner","Banner 广告 onAdDismiss......");
    }

    @Override
    public void onAdClicked(View view, int i) {
        Log.e("Banner","Banner 广告 onAdClicked......");
        methodChannel.invokeMethod("reload", null);
    }

    @Override
    public void onAdShow(View view, int i) {
        Log.e("Banner","Banner 广告 onAdShow......");
    }

    @Override
    public void onRenderFail(View view, String s, int i) {
        Log.e("Banner","Banner 广告 renderFail......");
        container.removeAllViews();
        methodChannel.invokeMethod("remove", null);
    }

    @Override
    public void onRenderSuccess(View view, float v, float v1) {

    }
}
