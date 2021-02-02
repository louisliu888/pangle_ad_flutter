package net.goc.pangle_ad_flutter_example;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Build;
import android.webkit.WebView;

public class AdApplication extends io.flutter.app.FlutterApplication {


    @Override
    public void onCreate() {
        super.onCreate();

//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//            String processName = getProcessName(this);
//            String packageName = this.getPackageName();
//            if (!packageName.equals(processName)) {
//                WebView.setDataDirectorySuffix(processName);
//            }
//        }

    }


    private String getProcessName(Context context) {
        if (context == null) return null;
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo processInfo : manager.getRunningAppProcesses()) {
            if (processInfo.pid == android.os.Process.myPid()) {
                return processInfo.processName;
            }
        }
        return null;
    }
}
