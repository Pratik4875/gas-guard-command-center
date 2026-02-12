# Gas Guard Command Center - User Guide

Welcome to the **Gas Guard Command Center**! This guide will help you set up the app, connect your hardware, and customize the experience.

---

## 1. Firebase Setup (The "Brain")
To make the app "Universal," you need to link it to your own Firebase project.

### Step A: Create a Project
1.  Go to [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add project** and give it a name (e.g., "Gas-Safety-Project").
3.  Disable Google Analytics (keep it simple) and click **Create project**.

### Step B: Create the Database
1.  In your new project, go to **Build > Realtime Database**.
2.  Click **Create Database**.
3.  Choose a location (e.g., United States) and click **Next**.
4.  **IMPORTANT:** Choose **Start in Test Mode** (this allows read/write without complex rules for now). Click **Enable**.

### Step C: Get Your Credentials
You need 5 keys to connect your app.
1.  Click the **Gear Icon (Settings) > Project settings**.
2.  Scroll down to **Your apps** and click the **Web icon (`</>`)**.
3.  Register the app (nickname: "Gas App").
4.  You will see a code block like this:
    ```javascript
    const firebaseConfig = {
      apiKey: "AIzaSy...",
      authDomain: "...",
      databaseURL: "https://your-project.firebaseio.com",
      projectId: "gas-safety-project",
      storageBucket: "...",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:..."
    };
    ```
5.  **COPY THESE VALUES!** You will need:
    *   `databaseURL`
    *   `apiKey`
    *   `projectId`
    *   `appId`
    *   `messagingSenderId`

---

## 2. App Configuration (Easy Mode 🚀)
1.  Open the **Gas Guard App** on your phone or PC.
2.  On the first run, you will see the **SYSTEM CONFIGURATION** screen.
3.  **Smart Import**: Copy the entire `const firebaseConfig = { ... }` code block from the Firebase Console (Step C above).
4.  Paste it into the **"Paste code here"** box in the app.
5.  The app will magically extract all the confusing IDs (`appId`, `projectId`, etc.) for you!
6.  Click **LAUNCH MISSION CONTROL**.

*(Note: failed to parse? You can still click "Advanced Details" to enter them manually).*

---

## 3. Hardware Setup (ESP8266)
1.  Open `SmartGasDetector.ino` in Arduino IDE.
2.  Update these lines with your Wi-Fi and Firebase details:
    ```cpp
    #define WIFI_SSID "YOUR_WIFI_NAME"
    #define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
    #define API_KEY "YOUR_FIREBASE_API_KEY"      // Same as App
    #define DATABASE_URL "YOUR_FIREBASE_DB_URL"  // Same as App
    ```
3.  **Wiring:**
    *   **MQ Sensor**: A0 (Analog)
    *   **Red LED**: D1
    *   **Buzzer**: D2
4.  Upload the code to your ESP8266.

---

## 4. Customization
### Changing the App Logo
1.  Prepare your logo image (PNG is best).
2.  Name it `app_icon.png`.
3.  Replace the file in `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (for Android) or use a tool like `flutter_launcher_icons` for a professional update.
