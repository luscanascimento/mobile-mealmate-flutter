# iOS runner

This directory contains the hand-written iOS sources that are safe to commit:

- `Runner/AppDelegate.swift`
- `Runner/Info.plist` (App Transport Security is set to HTTPS-only)

The Xcode project itself (`Runner.xcodeproj`, `Runner.xcworkspace`,
`Assets.xcassets`, `Base.lproj` storyboards, and CocoaPods files) is generated
by the Flutter tooling. To materialize a complete, buildable iOS project run
the following once from the repository root on a machine with the Flutter SDK
and Xcode installed:

```bash
flutter create --platforms=ios .
```

Flutter will scaffold the missing iOS files without overwriting the Dart code
in `lib/`. Then run `flutter run` to launch on a simulator or device.
