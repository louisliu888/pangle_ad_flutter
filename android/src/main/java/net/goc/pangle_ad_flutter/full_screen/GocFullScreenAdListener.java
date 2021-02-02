package net.goc.pangle_ad_flutter.full_screen;

import android.app.Activity;

import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTFullScreenVideoAd;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class GocFullScreenAdListener implements TTAdNative.FullScreenVideoAdListener,TTFullScreenVideoAd.FullScreenVideoAdInteractionListener {

    private Activity activity = null;
    private MethodChannel channel;
    private TTFullScreenVideoAd ttVideoAd;
    public GocFullScreenAdListener(Activity activity,MethodChannel channel){
        this.activity = activity;
        this.channel = channel;
    }
    @Override
    public void onError(int i, String s) {
        invokeAction(-1, s);
    }

    @Override
    public void onFullScreenVideoAdLoad(TTFullScreenVideoAd ttFullScreenVideoAd) {
        ttFullScreenVideoAd.showFullScreenVideoAd(activity);
        ttFullScreenVideoAd.setFullScreenVideoAdInteractionListener(this);
        ttVideoAd = ttFullScreenVideoAd;
        //ttFullScreenVideoAd = null;

    }

    @Override
    public void onFullScreenVideoCached() {

    }

    private void invokeAction(int code, String message) {
        Map<String,Object> params = new HashMap<String,Object>();
        params.put("code", code);
        params.put("message",message);
        channel.invokeMethod("action", params);
    }

    @Override
    public void onAdShow() {

    }

    @Override
    public void onAdVideoBarClick() {

    }

    @Override
    public void onAdClose() {
        invokeAction(0, "skip");
    }

    @Override
    public void onVideoComplete() {

    }

    @Override
    public void onSkippedVideo() {
        invokeAction(-1, "skip");
    }
}
