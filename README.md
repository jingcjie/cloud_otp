# 🔐 Cross-Platform OTP Authenticator

A versatile One-Time Password (OTP) authenticator application built with Dart, supporting multiple platforms including Windows, Linux, Web, Android, iOS, and macOS.

[中文版 README](./README_zh.md)

## ✨ Features

- 🖥️ 📱 Cross-platform support: Use on desktop, web, and mobile devices
- 🔄 Multi-device synchronization: Access your OTP codes from any device
- 👥 User-friendly interface: Easy to add, manage, and use OTP codes
- 🛡️ Secure: Implements industry-standard OTP algorithms
- 📱💻 QR Code Export: Generate QR codes for each OTP, enabling easy transfer to other authenticator apps
- 💾 Backup and Restore: Save your OTP setups as QR codes for foolproof backups

## 🤔 Why This Project?

While Google Authenticator is a popular choice for OTP, it has some limitations:

1. 📵 It only supports Android and iOS, making it inconvenient for desktop users.
2. 🔒 It's device-based, which means you can't easily access your codes across multiple devices.
3. 🔒 Limited backup and transfer options for your OTP setups.

This project aims to solve these issues by providing a cross-platform solution that allows you to use OTP codes on your preferred device, whether it's your phone, tablet, or computer. Additionally, our QR code export feature ensures you're never locked into our app - you can easily transfer your OTPs to other authenticator apps or create backups.

## 🚀 Getting Started

### Quick Access Options

- 🌐 **Web Version**: Visit [https://cloudotp.me/](https://cloudotp.me/) to use the OTP Authenticator directly in your browser.
- 📥 **Pre-compiled Releases**: If you don't want to compile the application yourself, you can download pre-compiled releases from our [GitHub Releases page](https://github.com/yourusername/otp-authenticator/releases).

### Prerequisites (for compiling from source)

- [Dart SDK](https://dart.dev/get-dart) 🎯
- [Flutter](https://flutter.dev/docs/get-started/install) 💙 (for mobile and desktop builds)

### Installation (from source)

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/otp-authenticator.git
   ```
2. Navigate to the project directory:
   ```
   cd otp-authenticator
   ```
3. Install dependencies:
   ```
   dart pub get
   ```

### Running the Application

- For web:
  ```
  flutter run -d chrome
  ```
- For desktop (Windows/Linux/macOS):
  ```
  flutter run -d windows
  flutter run -d linux
  flutter run -d macos
  ```
- For mobile (ensure you have a connected device or emulator):
  ```
  flutter run
  ```

## 💡 Key Features Highlight

### QR Code Export and Backup

Our OTP Authenticator allows you to export any of your OTP setups as a QR code. This feature provides several benefits:

1. 🔄 **Easy Transfer**: Quickly move your OTP setups to another device or authenticator app.
2. 💾 **Secure Backup**: Generate and save QR codes for all your OTPs as a foolproof backup method.
3. 🔓 **No Lock-in**: You're never trapped in our ecosystem - your OTP setups are always portable.
4. 📸 **Quick Setup**: Easily set up new devices by scanning your saved QR codes.

To use this feature, simply select the OTP you want to export and choose the "Export as QR" option. You can then save the QR code image securely or use it immediately to set up the OTP in another app.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🙏 Acknowledgements

- [Dart](https://dart.dev) 🎯
- [Flutter](https://flutter.dev) 💙
- [OTP RFC 6238](https://tools.ietf.org/html/rfc6238) 🔢

## 📊 Project Status

![GitHub stars](https://img.shields.io/github/stars/yourusername/otp-authenticator?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/otp-authenticator?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/otp-authenticator)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/otp-authenticator)

