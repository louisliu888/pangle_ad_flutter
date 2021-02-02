package net.goc.pangle_ad_flutter.banner;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import net.goc.pangle_ad_flutter.banner.GocExpressBannerView;

import java.lang.ref.WeakReference;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class GocExpressBannerViewFactory extends PlatformViewFactory {


    //private Activity activity;
    private BinaryMessenger messenger;
    private Bundle bundle;

    public GocExpressBannerViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Log.d("Banner","Banner create========================================");
        return new GocExpressBannerView( this.messenger, viewId, args,context);
    }

//    public void attachActivity( Activity activity) {
//        Log.d("Banner","Banner attachActivity========================================");
//        this.activity = activity;
//    }
//
//    public void detachActivity() {
//        Log.d("Banner","Banner detachActivity========================================");
//        //this.activity.clear();
//        this.activity = null;
//    }

}
