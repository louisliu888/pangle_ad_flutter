package net.goc.pangle_ad_flutter.listener;

import android.app.Activity;
import android.util.Log;
import android.view.View;

import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class GocExpressInterstitialAdListener implements  TTAdNative.NativeExpressAdListener, TTAdDislike.DislikeInteractionCallback, TTNativeExpressAd.AdInteractionListener {
    private Activity activity = null;
    MethodChannel channel;
    TTNativeExpressAd ttNativeAd;
    public GocExpressInterstitialAdListener(Activity activity, MethodChannel channel){
        this.activity = activity;
        this.channel = channel;
    }
    @Override
    public void onSelected(int i, String s) {
        Log.d("插屏广告","onSelected");
    }

    @Override
    public void onCancel() {
        Log.d("插屏广告","onCancel");

    }

    @Override
    public void onRefuse() {
        Log.d("插屏广告","onRefuse");
    }

    @Override
    public void onError(int i, String s) {
        Log.d("插屏广告","onError");
        invokeAction(i,s);
    }

    @Override
    public void onNativeExpressAdLoad(List<TTNativeExpressAd> list) {
        if (list == null || list.isEmpty()) {
            return;
        }
        TTNativeExpressAd ttNativeAd = list.get(0);
        ttNativeAd.setDislikeCallback(activity, this);
        ttNativeAd.setExpressInteractionListener(this);
        ttNativeAd.render();
        this.ttNativeAd = ttNativeAd;

        Log.d("插屏广告","onNativeExpressAdLoad");
    }

    @Override
    public void onAdDismiss() {

        Log.d("插屏广告","onAdDismiss");
        try {
            //ttNativeAd.destroy();
            this.ttNativeAd = null;
            this.activity = null;
        } catch ( Exception e) {
            //e.printStackTrace();
        }
    }

    @Override
    public void onAdClicked(View view, int i) {
        Log.d("插屏广告","onAdClicked");
    }

    @Override
    public void onAdShow(View view, int i) {
        Log.d("插屏广告","onAdShow");

    }

    @Override
    public void onRenderFail(View view, String s, int i) {
        Log.d("插屏广告","onRenderFail");
        invokeAction(i,s);
    }

    @Override
    public void onRenderSuccess(View view, float v, float v1) {
        Log.d("插屏广告","onRenderSuccess");
        this.ttNativeAd.showInteractionExpressAd(this.activity);
    }

    private void invokeAction(int code, String message) {
        Map<String,Object> params = new HashMap<String,Object>();
        params.put("code", code);
        params.put("message",message);
        channel.invokeMethod("action", params);
    }

}
