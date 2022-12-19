import { NativeModules, NativeEventEmitter, Platform } from 'react-native'

const ads = {
  Yodo1MASAds: null,
  eventListener: null,
  interstitial: null,
  interstitialTimeout: null,
  rewarded: null,
  rewardedTimeout: null,
  gotReward: false,
  showBannerWhenInitialized: true
}

const resolveInterstitial = () => ads?.interstitial?.resolve &&
  typeof ads.interstitial.resolve === 'function' &&
  ads.interstitial.resolve(true)

const resolveReward = (gotReward) => ads?.rewarded?.resolve &&
    typeof ads.reward.resolve === 'function' &&
    ads.reward.resolve(gotReward)

const giveReward = () => {
  clearTimeout(ads.rewardedTimeout)
  ads.gotReward = true
  resolveReward(true)
}

const handleYodoEvent = ({ value }) => {
  __DEV__ && console.log(`Yod1 MAS Event: ${value}`)
  switch (value) {
    case 'onMasInitSuccessful':
      ads.showBannerWhenInitialized && setTimeout(() => ads.Yodo1MASAds.showBannerAds(), 3000)
      break

    case 'interstitial-onAdOpened':
      clearTimeout(ads.interstitialTimeout)
      break
    case 'interstitial-onAdClosed':
      resolveInterstitial()
      break
    case 'interstitial-onAdError':
      clearTimeout(ads.interstitialTimeout)
      resolveInterstitial()
      break

    case 'reward-onAdOpened':
      clearTimeout(ads.rewardedTimeout)
      break
    case 'reward-onAdClosed':
      setTimeout(() => resolveReward(ads.gotReward), 1000)
      break
    case 'reward-onAdError':
      giveReward()
      break
    case 'reward-onAdvertRewardEarned':
      ads.gotReward = true
      break
  }
}

const releaseYodo1Mas = () => {
  if (ads?.eventListener?.remove) {
    ads.eventListener.remove()
    ads.eventListener = null
  }
  ads.Yodo1MASAds = null
}

const registerYodo1Mas = ({
  yodoKeyIOS,
  yodoKeyAndroid,
  showBannerWhenInitialized = true
}) => {
  try {
    releaseYodo1Mas()
    ads.Yodo1MASAds = NativeModules.Yodo1MASAds
    ads.showBannerWhenInitialized = showBannerWhenInitialized
    const eventEmitter = new NativeEventEmitter(ads.Yodo1MASAds)
    ads.eventListener = eventEmitter.addListener('adEvent', handleYodoEvent)
    ads.Yodo1MASAds.initMasSdk(Platform.OS === 'ios' ? yodoKeyIOS : yodoKeyAndroid)
    return releaseYodo1Mas
  } catch (e) {
    __DEV__ && console.log('registerYodo1Mas', 'Yodo1Mas not initialized. Have you linked the module?')
  }
}

const showYodo1MasBanner = () => {
  try {
    ads.Yodo1MASAds.showBannerAds()
  } catch (e) {
    __DEV__ && console.log('showYodo1MasBanner', 'Yodo1Mas not registered or not initialized')
  }
}

const hideYodo1MasBanner = () => {
  try {
    ads.Yodo1MASAds.hideBannerAds()
  } catch (e) {
    __DEV__ && console.log('hideYodo1MasBanner', 'Yodo1Mas not registered or not initialized')
  }
}

const handleYodoAction = async (type, timeoutAction, cancelTime, yodoMethod, yodoTag) => {
  const promise = new Promise((resolve, reject) => { ads[type] = { resolve, reject } })

  const adsAvailable = await ads.Yodo1MASAds.isInitialized()
  if (adsAvailable) {
    ads[`${type}Timeout`] = setTimeout(timeoutAction, cancelTime)
    ads.Yodo1MASAds[yodoMethod](yodoTag)
  } else {
    ads[type].resolve(true)
    __DEV__ && console.log('handleYodoAction', type, 'Yodo1Mas not registered or not initialized, skipping and resolving')
  }
  return promise
}

const showRewardedAds = async (timeout = 10000, yodoTag = 'adhawk_rewarded') => {
  ads.gotReward = false
  return handleYodoAction('rewarded', giveReward, timeout, 'showRewardAdWithPlacement', yodoTag)
}

const showInterstitialAds = async (timeout = 10000, yodoTag = 'adhawk_interstitial') => {
  return handleYodoAction('interstitial', resolveInterstitial, timeout, 'showInterstitialAdWithPlacement', yodoTag)
}

export default {
  registerYodo1Mas,
  releaseYodo1Mas,
  showYodo1MasBanner,
  hideYodo1MasBanner,
  showRewardedAds,
  showInterstitialAds
}
