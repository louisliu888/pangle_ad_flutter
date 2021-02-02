
package net.goc.pangle_ad_flutter.splash;

import android.app.Activity;
import android.content.res.Resources;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTSplashAd;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class GocExpiresSplashView implements PlatformView, MethodChannel.MethodCallHandler, TTAdNative.SplashAdListener {


    private MethodChannel methodChannel;
    private FrameLayout container ;
    //private Context context;

    private int timeout;
    Double expressWidth = 0.0 ;
    Double expressHeight = 0.0 ;

    public GocExpiresSplashView(Activity activity, BinaryMessenger messenger, int id, Object args) {
        methodChannel = new MethodChannel(messenger, "net.goc.oceantide/pangle_expresssplashview_"+id);
        methodChannel.setMethodCallHandler(this);
        //context = activity;
        container = new FrameLayout(activity);


        Map<String,Object> params = (Map<String,Object>)args;

        String slotId = params.get("androidSlotId").toString();

        if (slotId != null) {
            timeout = params.get("timeout") == null ? 0 : Integer.parseInt(params.get("timeout").toString());
            Map<String, Double> expressArgs = (Map<String, Double>)params.get("expressSize");
            expressWidth  = (Double)expressArgs.get("width");
            expressHeight = (Double)expressArgs.get("height");
            float density = Resources.getSystem().getDisplayMetrics().density;
            int imgWidth = (int)(expressWidth * density);
            int imgHeight = (int)(expressHeight * density);
            AdSlot adSlot = new AdSlot.Builder().setCodeId(slotId).setImageAcceptedSize(imgWidth,imgHeight).build();
            TTAdManager ttAdManager = TTAdSdk.getAdManager();
            TTAdNative ttAdNative = ttAdManager.createAdNative(activity);
            ttAdNative.loadSplashAd(adSlot, this,timeout>3500 ? timeout:3500);
            invalidateView(expressWidth, expressHeight);
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
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d("ExpressBannerAD",call.method+".............................");
        switch (call.method){
            case "update":
                invalidateView(expressWidth, expressHeight);
                result.success(null);
                break;
            case "remove":
                container.removeAllViews();
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
        Log.e("开屏广告","销毁......................................");
        container.removeAllViews();
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
