//
//  Yodo1MASAds.m
//
//  Created by Umberto Ghio on 18/01/22.
//

#import <Foundation/Foundation.h>
#import <Yodo1MasCore/Yodo1Mas.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>
#import <Yodo1MasCore/Yodo1MasNativeAdView.h>

@interface Yodo1MASAds: RCTEventEmitter <RCTBridgeModule, Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate, Yodo1MasNativeAdViewDelegate>
@end

@implementation Yodo1MASAds
{
  bool hasListeners;
}

-(void)startObserving {
  hasListeners = YES;
}

-(void)stopObserving {
  hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"adEvent"];
}

- (void) sendEvent:(NSString *) event {
  if (hasListeners) {
    [self sendEventWithName:@"adEvent" body:@{@"value": event}];
    NSLog(@"Yodo1MASAds: sent Event to RN: %@", event);
  }
}

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
  [self sendEvent:@"reward-onAdOpened"];
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
  switch (event.type) {
    case Yodo1MasAdTypeReward: {
      [self sendEvent:@"reward-onAdClosed"];
      break;
    }
    case Yodo1MasAdTypeInterstitial: {
      [self sendEvent:@"interstitial-onAdClosed"];
      break;
    }
    default: {
      break;
    }
  }
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
  switch (event.type) {
    case Yodo1MasAdTypeReward: {
      [self sendEvent:@"reward-onAdError"];
      break;
    }
    case Yodo1MasAdTypeInterstitial: {
      [self sendEvent:@"interstitial-onAdError"];
      break;
    }
    case Yodo1MasAdTypeBanner: {
      [self sendEvent:@"banner-onAdError"];
      break;
    }
    case Yodo1MasAdTypeNative: {
      [self sendEvent:@"banner-onAdError"];
      break;
    }
  }
}

- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
  [self sendEvent:@"reward-onAdvertRewardEarned"];
}

RCT_EXPORT_METHOD(isInitialized:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject ) {
  NSLog(@"Yodo1MASAds: isInitialized: %@", [Yodo1Mas sharedInstance].isInit ? @"YES" : @"NO");
  resolve(@([Yodo1Mas sharedInstance].isInit));
}

RCT_EXPORT_METHOD(initMasSdk: (NSString *)yodoKey) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [Yodo1Mas sharedInstance].rewardAdDelegate = self;
    [Yodo1Mas sharedInstance].interstitialAdDelegate = self;
    
    Yodo1MasAdBuildConfig *config = [Yodo1MasAdBuildConfig instance];
    config.enableAdaptiveBanner = YES;
    config.enableUserPrivacyDialog = YES;
    [[Yodo1Mas sharedInstance] setAdBuildConfig:config];

    [[Yodo1Mas sharedInstance] initWithAppKey:yodoKey successful:^{
      [self sendEvent:@"onMasInitSuccessful"];
    } fail:^(NSError * _Nonnull error) {
      [self sendEvent:@"onMasInitFailed"];
    }];
  });
}

RCT_EXPORT_METHOD(showRewardedAds) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[Yodo1Mas sharedInstance] showRewardAd];
  });
}

RCT_EXPORT_METHOD(showRewardAdWithPlacement:(NSString *)tag) {
  NSLog(@"Yodo1MASAds: tagFromRewarded: %@", tag);

  dispatch_async(dispatch_get_main_queue(), ^{
    [[Yodo1Mas sharedInstance] showRewardAdWithPlacement: tag];
  });
}

RCT_EXPORT_METHOD(showIntertstialAds) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[Yodo1Mas sharedInstance] showInterstitialAd];
  });
}

RCT_EXPORT_METHOD(showInterstitialAdWithPlacement:(NSString *)tag) {
  NSLog(@"Yodo1MASAds: showIntertstialAds: %@", tag);

  dispatch_async(dispatch_get_main_queue(), ^{
    [[Yodo1Mas sharedInstance] showInterstitialAdWithPlacement:tag];
  });
}

RCT_EXPORT_METHOD(showBannerAds) {
  dispatch_async(dispatch_get_main_queue(), ^{
    Yodo1MasAdBannerAlign align = Yodo1MasAdBannerAlignBottom | Yodo1MasAdBannerAlignHorizontalCenter;
    CGPoint point = CGPointMake(0.0f, 0.0f);
    [[Yodo1Mas sharedInstance] showBannerAdWithAlign:align offset:point];
  });
}

RCT_EXPORT_METHOD(hideBannerAds) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[Yodo1Mas sharedInstance] dismissBannerAdWithDestroy: false];
  });
}

// To export a module named Yodo1MASAds
RCT_EXPORT_MODULE(Yodo1MASAds);
@end
