package net.goc.pangle_ad_flutter.feed;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import net.goc.pangle_ad_flutter.PangleAdManager;

import java.util.HashMap;
import java.util.List;
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
        Log.d("ExpressBannerAD",call.method+".............................信息流广告.........");
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

    public static class GocExpressFeedAdListener implements  TTAdNative.NativeExpressAdListener{
    
        private  MethodChannel.Result result;
        private Double width;
        private Double height;
    
        public GocExpressFeedAdListener(MethodChannel.Result result,Double width,Double height){
            this.result = result;
            this.width = width;
            this.height = height;
    //        this.methodChannel = methodChannel;
    //        this.activity = activity;
    //        this.interval = interval;
        }
    
    
    
        @Override
        public void onError(int i, String s) {
            io.flutter.Log.e("Banner","信息流 广告 onError....code:"+i +" message:"+s);
            //container.removeAllViews();
            //methodChannel.invokeMethod("remove", null);
            Map<String,Object> args = new HashMap<String, Object>();
            args.put("code",i);
            args.put("message",s);
            result.success(args);
        }
    
        @Override
        public void onNativeExpressAdLoad(List<TTNativeExpressAd> feedAds) {
            if (feedAds == null || feedAds.isEmpty()) {
                return;
            }
            List<String> data = PangleAdManager.shared.setFeedAd(feedAds,this.width,this.height);
            Map<String,Object> args = new HashMap<String, Object>();
            args.put("code",0);
            args.put("message","success");
            args.put("count",data.size());
            args.put("data",data);
            result.success(args);
            io.flutter.Log.e("Banner","信息流 广告 onNativeExpressAdLoad==================......");
        }
    
    //    @Override
    //    public void onFeedAdLoad(List<TTFeedAd> feedAds){
    //        if (feedAds == null || feedAds.isEmpty()) {
    //            return;
    //        }
    //        Set<String> data = PangleAdManager.shared.setFeedAd(feedAds);
    //        Map<String,Object> args = new HashMap<String, Object>();
    //        args.put("code",0);
    //        args.put("message","success");
    //        args.put("count",data.size());
    //        args.put("data",data);
    //        result.success(args);
    
    //        TTFeedAd ad = feedAds.get(0);
    //        //在banner中显示网盟提供的dislike icon，有助于广告投放精准度提升
    //        ad.setDislikeCallback(activity, this);
    //
    //        ad.render();
    //
    //        container.removeAllViews();
    //        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
    //        View feedAdView = ad.getAdView();
    //        //container.addView(feedAdView, params);
    //        Log.e("Banner","信息流 广告 onFeedAdLoad......");
    //    }
    
    
    }
}
