package net.goc.pangle_ad_flutter.listener;

import android.app.Activity;
import android.view.View;
import android.widget.FrameLayout;

import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;
import com.bytedance.sdk.openadsdk.TTSplashAd;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class GocExpressSplashAdListener implements  TTAdNative.SplashAdListener {

    private FrameLayout container;
    private MethodChannel methodChannel;
    private Activity activity;


    public GocExpressSplashAdListener(FrameLayout container, MethodChannel methodChannel, Activity activity){
        this.container = container;
        this.methodChannel = methodChannel;
        this.activity = activity;

    }

    @Override
    public void onError(int code, String message) {
        invokeAction(code, message ==null? "": message);
    }

    @Override
    public void onTimeout() {
        invokeAction(-1, "timeout");
    }

    private void invokeAction(int code, String message) {
        Map<String,Object> params = new HashMap<String,Object>();
        params.put("code", code);
        params.put("message",message);
        methodChannel.invokeMethod("action", params);
    }
    @Override
    public void onSplashAdLoad(TTSplashAd ttSplashAd) {
        View splashView = ttSplashAd.getSplashView();
        container.addView(splashView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        ttSplashAd.setSplashInteractionListener(new TTSplashAd.AdInteractionListener() {
            @Override
            public void onAdClicked(View view, int type) {
                Log.i("SplashAD:","onAdClicked=======================");
                invokeAction(0,"click");

            }

            @Override
            public void onAdShow(View view, int i) {
                Log.i("SplashAD:","onAdShow=======================");
                invokeAction(0,"show");
            }

            @Override
            public void onAdSkip() {
                Log.i("SplashAD:","onAdSkip=======================");
                invokeAction(0,"skip");
            }

            @Override
            public void onAdTimeOver() {
                Log.i("SplashAD:","onAdTimeOver=======================");
                invokeAction(0,"timeover");
            }

        });


    }

}
