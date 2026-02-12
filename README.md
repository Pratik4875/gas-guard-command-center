# Gas Guard Command Center 🚀
*A Futuristic Gas Leak Detection System for Students*

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![ESP8266](https://img.shields.io/badge/ESP8266-Hardware-blue?style=for-the-badge)

## Overview
This project is an educational tool designed to teach 4th and 5th graders about **IoT (Internet of Things)** and **Gas Safety**. It uses an ESP8266 microcontroller to detect gas levels and a beautiful Flutter app to monitor them in real-time.

**Key Features:**
*   **Universal App**: Works with ANY Firebase project (no coding needed!).
*   **Real-time Dashboard**: See gas levels instantly.
*   **Weekly Reports**: Track air quality over time.
*   **Smart Alerts**: Get pop-up warnings if gas is detected.

## 📸 Screenshots
| Dashboard | Settings | Gas Alert |
| :---: | :---: | :---: |
| <img src="docs/screenshots/dashboard_placeholder.png" width="200" alt="Dashboard UI" /> | <img src="docs/screenshots/settings_placeholder.png" width="200" alt="Settings UI" /> | <img src="docs/screenshots/alert_placeholder.png" width="200" alt="Alert UI" /> |

*> **Note for Students:** I have left these placeholders here. Once you test the app, take screenshots and replace these images in the `docs/screenshots` folder!*

## 📂 Project Structure
*   `lib/` - The Flutter Application code.
*   `firmware/` - The C++ code for the ESP8266 microcontroller.
*   `docs/` - **Documentation & Guides**.

## 🚀 Getting Started
1.  **Hardware**: Flash the code in `firmware/` to your ESP8266.
2.  **Firebase**: Create a free project at [console.firebase.google.com](https://console.firebase.google.com).
3.  **App**:
    *   Install Flutter.
    *   Run `flutter pub get`.
    *   Run `flutter run`.
4.  **Config**: Use the "Active/Smart Import" feature in the app to connect your database.

👉 **[READ THE FULL USER GUIDE](docs/USER_GUIDE.md)**

## 🌍 Sharing & Hosting
Want to put this on GitHub or host the Web App online?
👉 **[READ THE DEPLOYMENT GUIDE](docs/DEPLOYMENT.md)**

## License
MIT License - Free for educational use!
