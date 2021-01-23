package net.goc.pangle_ad_flutter.listener;

import android.app.Activity;
import android.view.View;
import android.widget.FrameLayout;

import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTFeedAd;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

import net.goc.pangle_ad_flutter.PangleAdManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class GocExpressFeedAdListener implements  TTAdNative.NativeExpressAdListener{

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
        Log.e("Banner","信息流 广告 onError....code:"+i +" message:"+s);
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
        Log.e("Banner","信息流 广告 onNativeExpressAdLoad==================......");
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
