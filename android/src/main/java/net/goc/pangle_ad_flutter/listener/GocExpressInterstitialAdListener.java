package net.goc.pangle_ad_flutter.listener;

import android.util.Log;
import android.view.View;

import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import java.util.List;

public class GocExpressInterstitialAdListener implements  TTAdNative.NativeExpressAdListener, TTAdDislike.DislikeInteractionCallback, TTNativeExpressAd.AdInteractionListener {


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
    }

    @Override
    public void onNativeExpressAdLoad(List<TTNativeExpressAd> list) {
        Log.d("插屏广告","onNativeExpressAdLoad");
    }

    @Override
    public void onAdDismiss() {
        Log.d("插屏广告","onAdDismiss");
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
    }

    @Override
    public void onRenderSuccess(View view, float v, float v1) {
        Log.d("插屏广告","onRenderSuccess");
    }
}
