# react-native-yodo1-mas
Yodo1 MAS Implementation

- Support iOS >= 11.0 (only on real device)

- Support Android
  - minSdkVersion = 26
  - compileSdkVersion = 29
  - targetSdkVersion = 29
  - use [HBRecorder](https://github.com/HBiSoft/HBRecorder)

## Installation

```sh
yarn add react-native-yodo1-mas
```

### iOS

add Usage Description in info.plist

```
<key>NSCameraUsageDescription</key>
<string>Please allow use of camera</string>
<key>NSMicrophoneUsageDescription</key>
<string>Please allow use of microphone</string>
```

Install pods from the ios folder

```sh
npx pod-install
```

### Android

Add permissions in AndroidManifest.xml

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_INTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## Usage

See the example application for full Android and iOS Example
### TODO

```js
const codeExample = TODO
```

## License

MIT