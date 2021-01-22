package net.goc.pangle_ad_flutter.factory;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import net.goc.pangle_ad_flutter.PangleAdManager;
import net.goc.pangle_ad_flutter.listener.GocExpressBannerAdListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class GocExpressFeedView implements PlatformView, MethodChannel.MethodCallHandler {


    private MethodChannel methodChannel;
    private FrameLayout container ;
    private Context context;

    Double expressWidth = 0.0 ;
    Double expressHeight = 0.0 ;

    public GocExpressFeedView(Activity activity, BinaryMessenger messenger, int viewId, Object args) {
        methodChannel = new MethodChannel(messenger, "net.goc.oceantide/pangle_expressfeedview_"+viewId);
        methodChannel.setMethodCallHandler(this);
        context = activity;
        container = new FrameLayout(context);


        Map<String,Object> params = (Map<String,Object>)args;

        String feedId = params.get("feedId").toString();

        if (feedId != null) {
            GocNativeExpressFeedAd gocAd = PangleAdManager.shared.getFeedAd(feedId);
            System.out.println("=============height:"+gocAd.getFeedAd().getExpressAdView().getHeight() + "=====Bottom:"+ gocAd.getFeedAd().getExpressAdView().getBottom());
            this.expressWidth = gocAd.getWidth();
            this.expressHeight = gocAd.getHeight();
            //gocAd.getFeedAd().getExpressAdView().
            container.addView(gocAd.getFeedAd().getExpressAdView());
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
