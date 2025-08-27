package com.samtechnology.tool_finder
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.MediaView
import android.widget.LinearLayout
import android.widget.TextView

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",
            MyNativeAdFactory(this)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

// ✅ Create your factory class
class MyNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val layout = LinearLayout(context)
        layout.orientation = LinearLayout.VERTICAL

        val adView = NativeAdView(context)

        // Headline
        val headlineView = TextView(context)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView
        layout.addView(headlineView)

        // Media
        nativeAd.mediaContent?.let {
            val mediaView = MediaView(context)
            mediaView.setMediaContent(it)
            adView.mediaView = mediaView
            layout.addView(mediaView)
        }

        adView.addView(layout)
        adView.setNativeAd(nativeAd)
        return adView
    }
}
