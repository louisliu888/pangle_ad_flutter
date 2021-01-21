package net.goc.pangle_ad_flutter.factory;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.AdSlot;

import net.goc.pangle_ad_flutter.PangleAdManager;
import net.goc.pangle_ad_flutter.listener.GocExpressBannerAdListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class GocExpressBannerView implements PlatformView, MethodChannel.MethodCallHandler {


    private MethodChannel methodChannel;
    private FrameLayout container ;
    private Activity context;

    private int interval;
    Double expressWidth = 0.0 ;
    Double expressHeight = 0.0 ;
    String slotId ;

    public GocExpressBannerView(Activity activity, BinaryMessenger messenger, int id, Object args) {
        methodChannel = new MethodChannel(messenger, "net.goc.oceantide/pangle_expressbannerview_"+id);
        methodChannel.setMethodCallHandler(this);
        context = activity;
        container = new FrameLayout(context);


        Map<String,Object> params = (Map<String,Object>)args;

        slotId = params.get("androidSlotId").toString();

        if (slotId != null) {
            interval = params.get("interval") == null ? 0 : Integer.parseInt(params.get("interval").toString());
            Map<String, Double> expressArgs = (Map<String, Double>)params.get("expressSize");
            expressWidth  = (Double)expressArgs.get("width");
            expressHeight = (Double)expressArgs.get("height");


            AdSlot adSlot = new AdSlot.Builder()
                    .setCodeId(slotId) //广告位id
                    .setSupportDeepLink(true)
                    .setAdCount(1) //请求广告数量为1到3条
                    .setExpressViewAcceptedSize(expressWidth.floatValue(),expressHeight.floatValue()) //期望模板广告view的size,单位dp
                    .build();

            PangleAdManager.shared.loadExpressBannerAd(adSlot, new GocExpressBannerAdListener(container,methodChannel,context,interval,expressWidth,expressHeight));


            //invalidateView(expressWidth, expressHeight);
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
        container.removeAllViews();
    }
}
