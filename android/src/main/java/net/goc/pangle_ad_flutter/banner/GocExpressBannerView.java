package net.goc.pangle_ad_flutter.banner;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.res.Resources;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAdSdk;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import net.goc.pangle_ad_flutter.PangleAdManager;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class GocExpressBannerView implements PlatformView, MethodChannel.MethodCallHandler {


    private MethodChannel methodChannel;
    private FrameLayout container ;
   // private Activity activity;
    private TTNativeExpressAd ad;

    private int interval;
    Double expressWidth = 0.0 ;
    Double expressHeight = 0.0 ;
    String slotId ;

    public GocExpressBannerView( BinaryMessenger messenger, int id, Object args,Context context) {

        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo processInfo : manager.getRunningAppProcesses()) {
            Log.e("BANNER"," ====================================="+ processInfo.processName);

        }
        Log.d("Banner","GocExpressBannerView=========SDK版本:" + TTAdSdk.getAdManager().getSDKVersion());
        methodChannel = new MethodChannel(messenger, "net.goc.oceantide/pangle_expressbannerview_"+id);
        methodChannel.setMethodCallHandler(this);
        //this.activity = activity;
        container = new FrameLayout(context);

        Map<String,Object> params = (Map<String,Object>)args;
        slotId = params.get("androidSlotId").toString();

        if (slotId != null) {
            interval = params.get("interval") == null ? 0 : Integer.parseInt(params.get("interval").toString());
            Map<String, Double> expressArgs = (Map<String, Double>)params.get("expressSize");
            expressWidth  = (Double)expressArgs.get("width");
            expressHeight = (Double)expressArgs.get("height");
            updateBanner();
        }

    }


    public void updateBanner(){
        TTNativeExpressAd ad = PangleAdManager.shared.getBannerAd(slotId);
        if(ad == null){
            Log.e("Banner2","获取的Banner Ad 对象为空.........................");

            float density = Resources.getSystem().getDisplayMetrics().density;
            AdSlot adSlot = new AdSlot.Builder()
                    .setCodeId(slotId) //广告位id
                    .setSupportDeepLink(true)
                    .setAdCount(1) //请求广告数量为1到3条
                    //.setImageAcceptedSize((int)(expressWidth*density),(int)(expressHeight*density))
                    .setExpressViewAcceptedSize(expressWidth.floatValue(),expressHeight.floatValue()) //期望模板广告view的size,单位dp
                    .build();

            io.flutter.Log.e("Banner2","loadExpressBannerAd.......................................................2");
            PangleAdManager.shared.loadExpressBannerAd(adSlot, new TTAdNative.NativeExpressAdListener(){
                TTNativeExpressAd ad;
                @Override
                @MainThread
                public void onError(int i, String s) {
                    io.flutter.Log.e("Banner2","。。。。。。。。。。。。。。。。。。。。。。。。errCode:"+i +" message:"+s);
                }

                @Override
                @MainThread
                public void onNativeExpressAdLoad(List<TTNativeExpressAd> list) {
                    if(list.size() <= 0){
                        return;
                    }
                    io.flutter.Log.e("Banner2","。。。。。。。。。。。加载成功。。。。。。。。。。。。。onNativeExpressAdLoad");
                    ad = list.get(0);
                    if(interval>0){
                        ad.setSlideIntervalTime(interval * 1000);
                    }
                    ad.render();
                    ad.setExpressInteractionListener(new TTNativeExpressAd.ExpressAdInteractionListener() {
                        @Override
                        public void onAdClicked(View view, int i) {
                            Log.e("Banner2","onAdClicked.........................");
                        }

                        @Override
                        public void onAdShow(View view, int i) {
                            Log.e("Banner2","onshow.........................");
                        }

                        @Override
                        public void onRenderFail(View view, String s, int i) {
                            Log.e("Banner2","onRenderFail........................."+i+" "+s);
                        }

                        @Override
                        public void onRenderSuccess(View view, float v, float v1) {
                            invalidateView(expressWidth,expressHeight);
                            container.removeAllViews();
                            container.addView(view);
                        }
                    });
                }
            });
            return;
        }

        if(interval>0){
            ad.setSlideIntervalTime(interval * 1000);
        }
        ad.render();
        ad.setExpressInteractionListener(new TTNativeExpressAd.ExpressAdInteractionListener() {
            @Override
            public void onAdClicked(View view, int i) {
                Log.e("Banner2","onAdClicked.........................");
            }

            @Override
            public void onAdShow(View view, int i) {
                Log.e("Banner2","onshow.........................");
            }

            @Override
            public void onRenderFail(View view, String s, int i) {
                Log.e("Banner2","onRenderFail........................."+i+" "+s);
            }

            @Override
            public void onRenderSuccess(View view, float v, float v1) {
                invalidateView(expressWidth,expressHeight);
                container.removeAllViews();
                container.addView(view);
            }
        });
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
                updateBanner();
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
        container.removeAllViews();
    }


}
