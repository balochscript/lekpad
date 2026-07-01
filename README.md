# Lekpad Keyboard (لِکپَد)

[English](README.md) | [بلۏچی](README_bc.md) | [فارسی](README_fa.md) | [اردو](README_ur.md) | [العربية](README_ar.md)

---

![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=flat-square&logo=flutter)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android)
![iOS](https://img.shields.io/badge/Platform-iOS-000000?style=flat-square&logo=apple)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

**Lekpad** is a standard, modern, and highly customizable keyboard application designed specifically for the **Balochi language**. It provides native support for both **Balorabi** (Perso-Arabic script) and **Balotin** (Latin script) layouts. 

Built with a robust hybrid architecture, it seamlessly integrates a Flutter-based companion app (for settings and theming) with high-performance native Android (Kotlin) and iOS (Swift) custom keyboard extensions.

## ✨ Key Features

*   🌐 **Dual Script Support:** Switch instantly between standard Balorabi and Balotin layouts.
*   🎨 **Full Customization:** Create your own themes using an advanced color picker (Background, Key, and Text colors).
*   💡 **Smart Predictions:** Built-in word prediction algorithm tailored for the Balochi language.
*   📋 **Clipboard Manager:** Built-in clipboard history for easy access to recently copied texts, optimized with a clean UI.
*   🔊 **Native Sound Feedback:** Custom typing sounds integrated natively for zero-latency auditory feedback.
*   🔤 **Comprehensive Characters:** Long-press popups support all necessary characters (including full Perso-Arabic support and diacritics/Aeraab mapping on the 'ا' key).

## 📥 Installation Guide

### 🤖 For Android Users
1. Go to the [Releases page](../../releases) of this repository.
2. Download the latest `Lekpad-android-release.apk` file.
3. Open the downloaded file and tap **Install** (you may need to allow installation from unknown sources).
4. Open the **Lekpad** app from your app drawer.
5. Tap on **"Enable Keyboard" (لکپدا کار بَند)** and turn on Lekpad in your system settings.
6. Tap on **"Choose Keyboard" (لکپدا وتی کیبورڈ گچݔن کَن)** and select Lekpad as your default input method.

### 🍏 For iOS Users
*Note: Since the app is not currently on the App Store, you need to sideload it.*
1. Go to the [Releases page](../../releases) of this repository.
2. Download the latest `Lekpad-iOS-unsigned.ipa` file.
3. Use a sideloading tool like **AltStore**, **Sideloadly**, or **TrollStore** to install the `.ipa` onto your iPhone/iPad.
4. Once installed, go to iOS **Settings > General > Keyboard > Keyboards**.
5. Tap **Add New Keyboard...** and select **Lekpad**.
6. Tap on Lekpad in the list and turn on **"Allow Full Access"** (required for custom themes and clipboard features).

## 🛠️ For Developers (Build from Source)

Lekpad uses a unique build system where the Flutter project is scaffolded on the fly to inject native code.

**Prerequisites:**
*   Flutter SDK (Stable)
*   Python 3 (for Android injection)
*   Ruby & Cocoapods (for iOS injection)

To trigger a build locally or via CI/CD, review the scripts located in the `.github/workflows` directory. The automated system handles the creation of `InputMethodService` (Android) and `UIInputViewController` (iOS) automatically.
