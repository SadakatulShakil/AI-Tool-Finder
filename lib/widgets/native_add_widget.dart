import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _nativeAd = AdService.createNativeAd(
          () => setState(() => _isLoaded = true),
          () => setState(() => _isLoaded = false),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      height: 200,
      child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AdWidget(ad: _nativeAd!),
          )), // match your card height
    );
  }
}
