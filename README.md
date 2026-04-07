CPAMMA Full Build

Build commands

cd /d "C:\Users\ryang\Downloads\cpamma-app"
npm install
set EXPO_NO_GIT_STATUS=1
npx expo prebuild --clean
set EAS_NO_VCS=1
eas build --platform android --profile preview --clear-cache

Local Android testing

cd /d "C:\Users\ryang\Downloads\cpamma-app"
npx expo start

Then press a to open Android after Android Studio, the Android SDK, and adb are set up.

This build includes:
- exact schedule wording and times
- profile ranks
- youth scheduled days and times
- youth-only progress section for children 12 and under
- employee pay sheets
- expected classes this week
- smart check-in
- announcements
- support messages
- 31 Day Notice


## v24 additions
- payment dashboard for admin
- retention system
- event registration
- notification preference foundation
- unlocked content in profile
