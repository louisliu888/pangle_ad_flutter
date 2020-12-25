package net.goc.pangle_ad_flutter.factory;

import com.bytedance.sdk.openadsdk.TTNativeExpressAd;

public class GocNativeExpressFeedAd {
    private TTNativeExpressAd feedAd;
    private Double width;
    private Double height;
    public GocNativeExpressFeedAd(TTNativeExpressAd feedAd, Double width, Double height){
        this.feedAd = feedAd;
        this.width = width;
        this.height = height;
    }

    public TTNativeExpressAd getFeedAd(){
        return feedAd;
    }

    public Double getWidth() {
        return width;
    }

    public Double getHeight(){
        return height;
    }

}
