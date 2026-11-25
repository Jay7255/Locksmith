# Locksmith

**Game idea by Emma Chilufya.** Made by Jonathan.

A locksmith puzzle game for Android with AdMob ads. Five kinds of lock take turns as jobs from customers:

| Lock | What you do |
|---|---|
| 🔑 Cut a key | Cut each tooth so every pin lines up with the shear line, then swipe the key in |
| 🔢 Combination padlock | Solve the clue note, roll the wheels, pull the shackle |
| 🚪 Door lock | Tension wrench and pick: set the binding pin, don't overset |
| 🏦 Safe | Spin the dial, watch the stethoscope for the spike, stop and wait for the clunk |
| 📟 Electronic keypad | Smudged keys and a thermal camera; hotter keys were pressed later |

Also: a timer on every job, a daily job (3× coins), workshop tool upgrades, ranks, a speed streak, hints from "Uncle Joseph".

## How the app is built

The game itself is one web page: `assets/game/index.html`. The Flutter app shows that page full screen and adds Google AdMob:

- a **banner** under the game
- **rewarded** ads when the player taps any "▶ watch an ad" button (double coins, free hint, +20 seconds, +2 blanks, +50 coins)
- an **interstitial** (full-screen) ad after every 3 jobs, from job 4
- Google's **consent form** for players in Europe and the UK, and a "Privacy & ad choices" button in ⚙ settings

Progress is saved by the app, so it survives closing the game.

| File | What it does |
|---|---|
| `assets/game/index.html` | The whole game |
| `lib/main.dart` | Shows the game, the banner, and handles messages from the game (ads, saving, copying) |
| `lib/services/ads.dart` | AdMob: consent, banner, interstitial, rewarded. **Your ad IDs go here.** |
| `tool/configure.dart` | Puts the AdMob app ID and the name "Locksmith" into the Android project. **Your app ID goes here.** |
| `tool/setup_windows.ps1` | One command to install everything on Windows and build the APK |
| `.github/workflows/` | Builds the APK on GitHub on every change, and tests that it starts |

---

## Part 1: Get the app on your phone

There are two ways. **Way A** is easiest if you don't want to install anything; **Way B** uses Android Studio on your PC.

### Way A: let GitHub build it

This repository already builds itself: every change to `main` makes a new APK at
<https://github.com/Jay7255/Locksmith/releases/download/latest/locksmith.apk>

To set up the same thing in a new repository:

1. On github.com, tap **+ → New repository**. Name it `locksmith`, leave every box unticked, then **Create repository**.
2. On the new repository page, click **uploading an existing file**.
3. Unzip `locksmith-app.zip` on your PC. Open the `locksmith` folder, select **everything inside it**, including the `.github` folder, and drag it onto the GitHub page. Click **Commit changes**.
   - If you can't see `.github`: in File Explorer choose **View → Show → Hidden items**.
4. Open the **Actions** tab. A build named "Build Android APK" starts. It takes about 7–10 minutes. A green tick means it worked.
5. On your Pixel, open Chrome and go to:
   `https://github.com/Jay7255/Locksmith/releases/download/latest/locksmith.apk`
6. Install it (see "Installing the APK" below).

Every time a file changes on GitHub, a fresh APK appears at the same link.

### Way B: build it on your PC

1. Make sure Android Studio has finished its first-time setup ("Standard" install).
2. Unzip `locksmith-app.zip`, for example to `C:\Users\YOU\locksmith`.
3. Open the **Terminal** app (not as administrator) and run:
   ```
   cd $HOME\locksmith
   powershell -ExecutionPolicy Bypass -File tool\setup_windows.ps1
   ```
   It installs Git and Flutter if needed, prepares the project, runs the tests and builds the app. The first run takes a while.
4. When it says **Done!**, the app is at `locksmith\locksmith.apk`.
5. Copy it to the phone with a USB cable (pull down the phone's notification, choose **File transfer**, copy into **Download**), or with the phone plugged in and USB debugging on, run `flutter install`.

To change the game and try it quickly on the phone: plug it in and run `flutter run` in the project folder.

### Installing the APK on the Pixel

1. Open the downloaded `locksmith.apk` (from the notification, or **Files → Downloads**).
2. Android says the browser or Files can't install apps: tap **Settings → Allow from this source**, then go back.
3. Tap **Install**. If Play Protect warns you, tap **More details → Install anyway** (normal for apps not from the Play Store).
4. If you had an older build signed differently and it refuses to install, uninstall the old one first.

Until you finish Part 2, the ads are Google's **test ads** (they say "Test Ad"). They are safe to tap and pay nothing.

---

## Part 2: Switch on real ads (AdMob)

### Step 1: Create an AdMob account
1. Go to **admob.google.com** and sign in with your Google account.
2. Choose your country (Zambia) and time zone, accept the terms.
3. Add payment details now or later (Payments → Payment info). Google pays out once your earnings reach the threshold (about US$100) by bank transfer. You'll also be asked for tax information.

### Step 2: Add the app
1. **Apps → Add app → Android**.
2. "Is the app listed on a supported app store?" → **No** for now (you'll link it after it's on Google Play).
3. App name: **Locksmith**. Turn on user metrics if offered.
4. Copy the **App ID**. It looks like `ca-app-pub-1234567890123456~1234567890` (note the **~**).

### Step 3: Create three ad units
In your app → **Ad units → Add ad unit**, create:

| Type | Name | Settings |
|---|---|---|
| Banner | Locksmith banner | defaults |
| Interstitial | Locksmith between jobs | defaults |
| Rewarded | Locksmith rewards | Reward amount `1`, reward item `reward` |

Copy each **ad unit ID**. They look like `ca-app-pub-1234567890123456/1234567890` (note the **/**).

### Step 4: Put your IDs into the code
1. `tool/configure.dart`, line near the top:
   ```dart
   const androidAppId = 'ca-app-pub-YOUR~APPID';
   ```
2. `lib/services/ads.dart`:
   ```dart
   static const bool useTestAds = false;
   ```
   and replace `YOUR_ANDROID_BANNER_ID`, `YOUR_ANDROID_INTERSTITIAL_ID` and `YOUR_ANDROID_REWARDED_ID` with your three ad unit IDs.
3. Rebuild (Way A: edit the files on GitHub with the ✏️ pencil and commit; Way B: run `dart run tool/configure.dart` and `flutter build apk --release` again).

### Step 5: Protect your account
- **Never tap your own real ads**, and don't ask friends to. Google bans accounts for this.
- Add your Pixel as a test device: AdMob → **Settings → Test devices → Add test device**. Get the phone's advertising ID in **Settings → Google → All services → Ads**. Real ads then show as test ads on your phone only.

### Step 6: Privacy and consent (required)
1. AdMob → **Privacy & messaging → GDPR → Create message** for your app and publish it. The game already shows this form to players in Europe and the UK, and has a "Privacy & ad choices" button in ⚙ settings.
2. You need a **privacy policy** web page that says the app shows ads from Google AdMob, which may use the device's advertising ID. Its link goes into Google Play (Step 7).

### Step 7: Publish on Google Play (needed for real earnings)
New AdMob apps serve only limited ads until they're on a store and reviewed.
1. Create a **Google Play Console** account at play.google.com/console (one-time US$25 fee, identity check).
2. **Create app** → name Locksmith, Game, Free.
3. Build the Play version, which is an **app bundle** signed with your own **upload key**:
   ```
   keytool -genkey -v -keystore $HOME\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Keep this file and its password safe forever. Then follow Flutter's guide "Build and release an Android app" (docs.flutter.dev/deployment/android): it adds `android/key.properties` and the signing settings, then `flutter build appbundle`.
4. Fill in the Play Console checklist: app content (privacy policy link, **ads: yes**, target audience 13+, data safety: "advertising ID collected, shared with Google for ads"), content rating questionnaire, store listing (icon, screenshots, description).
5. Upload the `.aab` to **Testing → Internal testing** first, then **Production**.
6. Back in AdMob: **App settings → Link to app store** so AdMob can review the app.
7. Optional but recommended: put an `app-ads.txt` file on your developer website (AdMob shows you its content).

The package name is `com.jonathangames.locksmith`. It can never change once the app is on Google Play, so if you want a different one, change `--org com.jonathangames` in `.github/workflows/build.yml` and `tool/setup_windows.ps1` **before** the first Play upload.

---

## Tuning the game

Everything is in `assets/game/index.html`:
- `TYPES` sets the order of lock types; `tierOf` sets how fast levels get harder.
- Each lock type's `time()` sets its clock; `squeeze` shortens the clock at higher levels.
- `TOOLS` and `TOOL_COST` are the workshop.
- In `win()`, `save.level > 4 && (save.level - 1) % 3 === 0` decides when a full-screen ad shows.

## Credits

- Game idea: **Emma Chilufya**
- Development: Jonathan
