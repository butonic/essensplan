# Essensplan

A simple menu planner in flutter.


## Building
Update version number in pubspec.yaml
`flutter build apk --target-platform android-arm64`

## Updating via adb

Update version number in pubspec.yaml

```
> adb devices
List of devices attached
3069bb5b        device
BB332A4JCA      device
emulator-5554   device

> adb -s 3069bb5b install -r .\build\app\outputs\flutter-apk\app-release.apk
```
Using `adb install -r .\build\app\outputs\flutter-apk\app-release.apk` keeps the previous app data and just re-installs the apk.


## Regenerate hive model
`flutter packages pub run build_runner build`