import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService.createBannerAd(
          () => setState(() {}),             // ✅ On Ad loaded
          () => setState(() => _bannerAd = null), // ✅ On Ad failed (no fill)
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ If no ad, return shrinked SizedBox
    if (_bannerAd == null) {
      return const SizedBox.shrink();
    }

    // ✅ If ad loaded, show AdWidget with exact size
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
