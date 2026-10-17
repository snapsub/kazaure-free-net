import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  RewardedAd? _rewardedAd;
  bool isAdLoaded = false;

  void loadRewardedAd(Function onLoaded) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Google Test ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (error) => isAdLoaded = false,
      ),
    );
  }

  void showRewardedAd({required Function(int) onUserRewarded}) {
    if (isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd(() {});
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserRewarded(7200); // Gives 2 hours of time
        },
      );
      isAdLoaded = false;
    }
  }
}
