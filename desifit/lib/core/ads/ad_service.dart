import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../network/analytics_service.dart';

class AdService {
  static bool _initialized = false;
  static DateTime? _lastInterstitialShowTime;
  static const Duration _minIntervalBetweenInterstitials = Duration(minutes: 2);

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      debugPrint('AdMob SDK is disabled on Web platform.');
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      // Handle ads initialization error gracefully
    }
  }

  // Target Ad Units (Use standard Google AdMob Test Keys in Debug/Profile, prod configurations in Release)
  static String get bannerAdUnitId {
    if (kReleaseMode) {
      // Inject production key via dart-define, fallback to a placeholder or test key if not set
      return const String.fromEnvironment('ADMOB_BANNER_UNIT_ID', defaultValue: 'ca-app-pub-4656039342175944/1111111111');
    }
    return 'ca-app-pub-3940256099942544/6300978111'; // Google Test Banner Key
  }

  static String get interstitialAdUnitId {
    if (kReleaseMode) {
      // Inject production key via dart-define, fallback to a placeholder or test key if not set
      return const String.fromEnvironment('ADMOB_INTERSTITIAL_UNIT_ID', defaultValue: 'ca-app-pub-4656039342175944/2222222222');
    }
    return 'ca-app-pub-3940256099942544/1033173712'; // Google Test Interstitial Key
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AnalyticsService.logEvent('ad_loaded', {
            'ad_type': 'banner',
            'ad_unit_id': bannerAdUnitId,
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
        onAdImpression: (ad) {
          AnalyticsService.logEvent('ad_shown', {
            'ad_type': 'banner',
            'ad_unit_id': bannerAdUnitId,
          });
        },
        onAdClicked: (ad) {
          AnalyticsService.logEvent('ad_clicked', {
            'ad_type': 'banner',
            'ad_unit_id': bannerAdUnitId,
          });
        },
      ),
    );
  }

  static void showInterstitialAd(VoidCallback onAdDismissed) {
    if (kIsWeb) {
      debugPrint('AdMob Interstitial Ad requested on Web. Dismissing instantly (Simulating Ad flow).');
      onAdDismissed();
      return;
    }
    if (!_initialized) {
      onAdDismissed();
      return;
    }

    final now = DateTime.now();
    if (_lastInterstitialShowTime != null &&
        now.difference(_lastInterstitialShowTime!) < _minIntervalBetweenInterstitials) {
      debugPrint('AdMob Interstitial request throttled by frequency capping.');
      onAdDismissed();
      return;
    }
    
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _lastInterstitialShowTime = DateTime.now();
              AnalyticsService.logEvent('ad_shown', {
                'ad_type': 'interstitial',
                'ad_unit_id': interstitialAdUnitId,
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _lastInterstitialShowTime = DateTime.now();
              onAdDismissed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdDismissed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          onAdDismissed();
        },
      ),
    );
  }

  static String get rewardedAdUnitId {
    if (kReleaseMode) {
      return const String.fromEnvironment('ADMOB_REWARDED_UNIT_ID', defaultValue: 'ca-app-pub-4656039342175944/3333333333');
    }
    return 'ca-app-pub-3940256099942544/5224354917'; // Google Test Rewarded Key
  }

  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;

  static void loadRewardedAd() {
    if (kIsWeb || !_initialized) return;
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          AnalyticsService.logEvent('ad_loaded', {
            'ad_type': 'rewarded',
            'ad_unit_id': rewardedAdUnitId,
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdLoading = false;
          _rewardedAd = null;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  static void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    required VoidCallback onAdDismissed,
  }) {
    if (kIsWeb) {
      debugPrint('AdMob Rewarded Ad requested on Web. Awarding reward instantly (Simulating Ad flow).');
      onUserEarnedReward(RewardItem(10, 'premium_features'));
      onAdDismissed();
      return;
    }
    if (!_initialized) {
      onAdDismissed();
      return;
    }

    if (_rewardedAd != null) {
      final ad = _rewardedAd!;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AnalyticsService.logEvent('ad_shown', {
            'ad_type': 'rewarded',
            'ad_unit_id': rewardedAdUnitId,
          });
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          onAdDismissed();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          onAdDismissed();
          loadRewardedAd();
        },
        onAdClicked: (ad) {
          AnalyticsService.logEvent('ad_clicked', {
            'ad_type': 'rewarded',
            'ad_unit_id': rewardedAdUnitId,
          });
        },
      );
      ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onUserEarnedReward(reward);
        },
      );
    } else {
      _isRewardedAdLoading = true;
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _isRewardedAdLoading = false;
            AnalyticsService.logEvent('ad_loaded', {
              'ad_type': 'rewarded',
              'ad_unit_id': rewardedAdUnitId,
            });
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                AnalyticsService.logEvent('ad_shown', {
                  'ad_type': 'rewarded',
                  'ad_unit_id': rewardedAdUnitId,
                });
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                onAdDismissed();
                loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                onAdDismissed();
                loadRewardedAd();
              },
              onAdClicked: (ad) {
                AnalyticsService.logEvent('ad_clicked', {
                  'ad_type': 'rewarded',
                  'ad_unit_id': rewardedAdUnitId,
                });
              },
            );
            ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                onUserEarnedReward(reward);
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isRewardedAdLoading = false;
            debugPrint('RewardedAd failed to load: $error');
            onAdDismissed();
            loadRewardedAd();
          },
        ),
      );
    }
  }
}

