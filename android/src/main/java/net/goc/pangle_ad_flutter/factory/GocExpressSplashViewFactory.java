package net.goc.pangle_ad_flutter.factory;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

import java.lang.ref.WeakReference;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class GocExpressSplashViewFactory extends PlatformViewFactory {


    private  WeakReference<Activity> activity;
    private  BinaryMessenger messenger;
    private Bundle bundle;

    public GocExpressSplashViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new GocExpiresSplashView(activity.get(), this.messenger, viewId, args);
    }

    public void attachActivity(Activity activity) {
        this.activity = new WeakReference(activity);
    }

    public void detachActivity() {
        this.activity.clear();
        this.activity = null;
    }

}
