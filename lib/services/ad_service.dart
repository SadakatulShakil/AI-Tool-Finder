import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Add IDs
  // native real "ca-app-pub-6315599938902614/2887022715"
  // banner real "ca-app-pub-6315599938902614/8205995673"
  // interstitial real "ca-app-pub-6315599938902614/8461447866"
  static const String nativeAdUnitId = "ca-app-pub-3940256099942544/2247696110";
  static const String bannerAdUnitId = "ca-app-pub-3940256099942544/6300978111";
  static const String interstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoaded = false;

  /// Initialize interstitial ad
  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Show interstitial ad if loaded
  static Future<bool> showInterstitialAd() async {
    if (_isInterstitialAdLoaded) {
      _interstitialAd?.show();
      return true;
    } else {
      print('Interstitial ad is not loaded yet');
      return false;
    }
  }

  /// BannerAd
  static BannerAd createBannerAd(VoidCallback onLoaded, VoidCallback onFailed) {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed();
        },
      ),
      request: const AdRequest(),
    );
  }

  /// NativeAd
  static NativeAd createNativeAd(
      VoidCallback onLoaded, VoidCallback onFailed) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed();
        },
      ),
      request: const AdRequest(),
      // factoryId must match with platform view (Flutter NativeAdFactory)
      factoryId: "listTile",
    );
  }
}
