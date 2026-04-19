# StudyBuddy — Build, Deploy & Icon Guide

> **To the agent reading this:** You are a skilled senior Flutter developer. Read every section fully before running any command. Follow steps in exact order. Do not skip steps. Run every command from the project root unless told otherwise.

---

## App Icon

The app uses a **teal graduation cap** on a dark navy background. The icon is already embedded below as an SVG — use it as the reference for all platform icons.

```
Icon colors:
  Background : #0D1117  (dark navy)
  Cap color  : #00D4AA  (teal accent)
  Text color : #E6EDF3  (light white)
  Cap shadow : #009E80  (darker teal)

Icon shape  : Circle with dashed inner ring
Cap style   : Mortarboard (flat top, tassel on right side dropping down)
Text        : "StudyBuddy" in Georgia serif below the cap
Subtitle    : "AI STUDY COMPANION" in small caps teal below name
```

### Reference SVG (saved as `assets/icon/studybuddy_icon.svg`)

```xml
<svg width="1024" height="1024" viewBox="0 0 680 680" xmlns="http://www.w3.org/2000/svg">
  <circle cx="340" cy="340" r="300" fill="#0D1117"/>
  <circle cx="340" cy="340" r="300" fill="none" stroke="#00D4AA" stroke-width="8"/>
  <circle cx="340" cy="340" r="258" fill="none" stroke="#00D4AA" stroke-width="1.5" stroke-dasharray="6 4"/>
  <polygon points="340,170 520,265 340,360 160,265" fill="#00D4AA"/>
  <polygon points="340,178 508,268 340,348 172,268" fill="#05E8BB" opacity="0.25"/>
  <polygon points="160,265 240,305 240,370 160,330" fill="#009E80"/>
  <polygon points="520,265 440,305 440,370 520,330" fill="#009E80"/>
  <polygon points="240,305 440,305 440,370 240,370" fill="#00B894"/>
  <line x1="520" y1="265" x2="520" y2="390" stroke="#00D4AA" stroke-width="5" stroke-linecap="round"/>
  <circle cx="520" cy="395" r="10" fill="#00D4AA"/>
  <line x1="505" y1="395" x2="495" y2="440" stroke="#00D4AA" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="515" y1="397" x2="510" y2="445" stroke="#00D4AA" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="520" y1="398" x2="520" y2="446" stroke="#00D4AA" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="526" y1="397" x2="530" y2="445" stroke="#00D4AA" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="534" y1="395" x2="545" y2="440" stroke="#00D4AA" stroke-width="3.5" stroke-linecap="round"/>
  <rect x="330" y="355" width="20" height="80" rx="4" fill="#009E80"/>
  <rect x="295" y="428" width="90" height="18" rx="8" fill="#00D4AA"/>
  <text x="340" y="548" text-anchor="middle" font-family="Georgia,serif" font-size="44"
        font-weight="700" fill="#E6EDF3" letter-spacing="2">StudyBuddy</text>
  <text x="340" y="590" text-anchor="middle" font-family="sans-serif" font-size="20"
        font-weight="400" fill="#00D4AA" letter-spacing="3">AI STUDY COMPANION</text>
</svg>
```

> **Agent instruction:** Copy the SVG block above exactly into `assets/icon/studybuddy_icon.svg`. This is the master icon. All steps below reference it.

---

## Part 1 — App Icon Setup

### Step 1 — Add `flutter_launcher_icons` to `pubspec.yaml`

Open `pubspec.yaml`. Under `dev_dependencies`, add:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

Still in `pubspec.yaml`, add this block at the **root level** (not nested inside flutter:):

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/studybuddy_icon.svg"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icon/studybuddy_icon.svg"
    background_color: "#0D1117"
    theme_color: "#00D4AA"
```

### Step 2 — Create the assets folder and save the SVG

Run this in your terminal from the project root:

```bash
mkdir -p assets/icon
```

Then create the file `assets/icon/studybuddy_icon.svg` and paste the SVG from above into it.

### Step 3 — Register the asset in `pubspec.yaml`

Under the `flutter:` section in `pubspec.yaml`, make sure assets is declared:

```yaml
flutter:
  assets:
    - assets/icon/
```

### Step 4 — Run the icon generator

```bash
flutter pub get
dart run flutter_launcher_icons
```

This will generate all required icon sizes for Android (`mipmap-*` folders) and web (`favicon.png`, `Icon-192.png`, `Icon-512.png`).

---

## Part 2 — Android APK Build

### Step 1 — Verify your environment

Run this and confirm everything shows a checkmark:

```bash
flutter doctor
```

If Android SDK or Java has a warning, fix it before continuing.

### Step 2 — Protect your API key with `.env`

Your app already uses `flutter_dotenv`. Make sure your `.env` file exists at the project root:

```
GEMINI_API_KEY=your_actual_key_here
GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

Make sure `.env` is in `.gitignore` so it never gets committed:

```bash
echo ".env" >> .gitignore
```

### Step 3 — Configure Android release signing

Create a keystore file. Run this once — save the password somewhere safe:

```bash
keytool -genkey -v -keystore android/app/studybuddy.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias studybuddy
```

Create the file `android/key.properties` with this content — replace the values with your actual passwords:

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=studybuddy
storeFile=studybuddy.jks
```

Add `key.properties` to `.gitignore`:

```bash
echo "android/key.properties" >> .gitignore
echo "android/app/studybuddy.jks" >> .gitignore
```

### Step 4 — Wire the signing config into `android/app/build.gradle`

Open `android/app/build.gradle`. Add this block **before** the `android {` block:

```gradle
def keyProperties = new Properties()
def keyPropertiesFile = rootProject.file('key.properties')
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.withReader('UTF-8') { reader ->
        keyProperties.load(reader)
    }
}
```

Inside the `android {` block, add the signing config:

```gradle
signingConfigs {
    release {
        keyAlias keyProperties['keyAlias']
        keyPassword keyProperties['keyPassword']
        storeFile keyProperties['storeFile'] ? file(keyProperties['storeFile']) : null
        storePassword keyProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### Step 5 — Build the APK

For a standard APK anyone can install directly (sideload):

```bash
flutter build apk --release
```

For a smaller APK split by CPU architecture (recommended for sharing):

```bash
flutter build apk --release --split-per-abi
```

Your APK files will be at:

```
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk   ← use this one for modern phones
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

Share `app-arm64-v8a-release.apk` for most Android devices made after 2017.

### Step 6 — For Google Play Store (App Bundle)

If you want to publish to Play Store, build an AAB instead:

```bash
flutter build appbundle --release
```

Output is at `build/app/outputs/bundle/release/app-release.aab`.

---

## Part 3 — Web Build and GitHub Pages Deployment

### Step 1 — Enable web support

Check if web is already enabled:

```bash
flutter devices
```

If you do not see Chrome listed, run:

```bash
flutter config --enable-web
```

### Step 2 — Handle `.env` for web

The web build cannot read a `.env` file from the filesystem at runtime. You need to inject the API key at build time using `--dart-define`.

Build the web release like this:

```bash
flutter build web --release \
  --dart-define=GEMINI_API_KEY=your_actual_key_here \
  --dart-define=GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

Then update `api_config.dart` to read from dart-define with a fallback to dotenv:

```dart
class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiBaseUrl = String.fromEnvironment(
    'GEMINI_BASE_URL',
    defaultValue: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent',
  );
}
```

This way the key is baked into the compiled JS at build time and never sits in a plain `.env` file in your repo.

### Step 3 — Build the web release

```bash
flutter build web --release \
  --dart-define=GEMINI_API_KEY=your_actual_key_here \
  --dart-define=GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

Output will be in the `build/web/` folder.

### Step 4 — Create the GitHub repository

Go to github.com and create a new repository named `studybuddy` (or any name you want). Make it public if you want GitHub Pages to work on the free plan.

Initialize git if not already done:

```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/studybuddy.git
```

### Step 5 — Set up GitHub Actions for automatic deployment

Create this folder structure in your project:

```bash
mkdir -p .github/workflows
```

Create the file `.github/workflows/deploy.yml` with this content:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Build web
        run: |
          flutter build web --release \
            --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }} \
            --dart-define=GEMINI_BASE_URL=${{ secrets.GEMINI_BASE_URL }}

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: build/web
```

### Step 6 — Add secrets to GitHub

Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret.

Add these two secrets:

```
Name  : GEMINI_API_KEY
Value : your_actual_gemini_api_key

Name  : GEMINI_BASE_URL
Value : https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent
```

This keeps your API key out of the code and out of the repo entirely.

### Step 7 — Enable GitHub Pages

Go to your GitHub repo → Settings → Pages.

Set source to:
```
Branch: gh-pages
Folder: / (root)
```

Save. GitHub Pages will be live at:
```
https://YOUR_USERNAME.github.io/studybuddy/
```

### Step 8 — Fix the base href for GitHub Pages

Flutter web needs to know the subfolder it is served from. Open `web/index.html` and find this line:

```html
<base href="/">
```

Change it to match your repo name:

```html
<base href="/studybuddy/">
```

Replace `studybuddy` with your actual repository name.

### Step 9 — Commit and push everything

```bash
git add .
git commit -m "Initial StudyBuddy release"
git push -u origin main
```

The GitHub Action will automatically run, build the web app, and deploy it to GitHub Pages. Check the Actions tab in your repo to watch the progress.

---

## Part 4 — Firebase Web Configuration

Firebase requires your web domain to be whitelisted before auth works on the web build.

### Step 1 — Add GitHub Pages domain to Firebase

Go to Firebase Console → Authentication → Settings → Authorized domains.

Click Add domain and add:

```
YOUR_USERNAME.github.io
```

### Step 2 — Update `firebase_options.dart` for web

Make sure the `web` options in `firebase_options.dart` have the correct `authDomain`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_FIREBASE_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'studybuddy-59119',
  authDomain: 'studybuddy-59119.firebaseapp.com',
  storageBucket: 'studybuddy-59119.firebasestorage.app',
);
```

---

## Final Checklist

Work through every item before considering the release done.

**Icon**
- [ ] `assets/icon/studybuddy_icon.svg` created with the SVG from this guide
- [ ] `flutter_launcher_icons` added to `pubspec.yaml`
- [ ] `dart run flutter_launcher_icons` ran successfully
- [ ] Icon visible in `android/app/src/main/res/mipmap-*` folders
- [ ] Icon visible in `web/icons/` folder

**Android APK**
- [ ] `flutter doctor` shows no errors
- [ ] `.env` file exists at project root with real API key
- [ ] `.env` is in `.gitignore`
- [ ] Keystore `studybuddy.jks` generated and saved safely
- [ ] `android/key.properties` created
- [ ] `key.properties` and `studybuddy.jks` are in `.gitignore`
- [ ] `android/app/build.gradle` has signing config wired up
- [ ] `flutter build apk --release --split-per-abi` ran successfully
- [ ] APK installs and runs on a real device

**Web / GitHub Pages**
- [ ] `api_config.dart` updated to use `String.fromEnvironment`
- [ ] `.github/workflows/deploy.yml` created
- [ ] `GEMINI_API_KEY` and `GEMINI_BASE_URL` added as GitHub secrets
- [ ] `web/index.html` base href updated to `/studybuddy/`
- [ ] GitHub Pages source set to `gh-pages` branch
- [ ] Firebase authorized domains includes `YOUR_USERNAME.github.io`
- [ ] GitHub Action ran successfully (green check in Actions tab)
- [ ] App loads at `https://YOUR_USERNAME.github.io/studybuddy/`