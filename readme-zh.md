# 🔐 跨平台OTP认证器

一个用Dart构建的多功能一次性密码（OTP）认证器应用程序，支持多个平台，包括Windows、Linux、Web、Android、iOS和macOS。

[English README](./README.md)

## ✨ 功能特点

- 🖥️ 📱 跨平台支持：可在桌面、网页和移动设备上使用
- 🔄 多设备同步：从任何设备访问您的OTP代码
- 👥 用户友好界面：易于添加、管理和使用OTP代码
- 🛡️ 安全：实现行业标准的OTP算法
- 📱💻 二维码导出：为每个OTP生成二维码，方便转移到其他认证器应用
- 💾 备份和恢复：将您的OTP设置保存为二维码，实现无忧备份

## 🤔 为什么开发这个项目？

虽然Google Authenticator是OTP的流行选择，但它有一些限制：

1. 📵 它只支持Android和iOS，对桌面用户来说不便。
2. 🔒 它是基于设备的，这意味着您无法轻松地在多个设备上访问您的代码。
3. 🔒 OTP设置的备份和转移选项有限。

本项目旨在通过提供一个跨平台解决方案来解决这些问题，让您可以在您喜欢的设备上使用OTP代码，无论是手机、平板还是电脑。此外，我们的二维码导出功能确保您永远不会被锁定在我们的应用程序中 - 您可以轻松地将OTP转移到其他认证器应用或创建备份。

## 🚀 开始使用

### 快速访问选项

- 🌐 **网页版**：访问 [https://cloudotp.me/](https://cloudotp.me/) 直接在浏览器中使用OTP认证器。
- 📥 **预编译版本**：如果您不想自己编译应用程序，可以从我们的 [GitHub Releases 页面](https://github.com/yourusername/otp-authenticator/releases) 下载预编译版本。

### 前提条件（用于从源代码编译）

- [Dart SDK](https://dart.dev/get-dart) 🎯
- [Flutter](https://flutter.dev/docs/get-started/install) 💙 （用于移动和桌面版本构建）

### 安装（从源代码）

1. 克隆仓库：
   ```
   git clone https://github.com/yourusername/otp-authenticator.git
   ```
2. 进入项目目录：
   ```
   cd otp-authenticator
   ```
3. 安装依赖：
   ```
   dart pub get
   ```

### 运行应用

- 网页版：
  ```
  flutter run -d chrome
  ```
- 桌面版（Windows/Linux/macOS）：
  ```
  flutter run -d windows
  flutter run -d linux
  flutter run -d macos
  ```
- 移动版（确保您已连接设备或模拟器）：
  ```
  flutter run
  ```

## 💡 主要功能亮点

### 二维码导出和备份

我们的OTP认证器允许您将任何OTP设置导出为二维码。这个功能提供了几个好处：

1. 🔄 **轻松转移**：快速将您的OTP设置移动到另一个设备或认证器应用。
2. 💾 **安全备份**：为所有OTP生成并保存二维码，作为一种万无一失的备份方法。
3. 🔓 **无锁定**：您永远不会被困在我们的生态系统中 - 您的OTP设置始终是可移植的。
4. 📸 **快速设置**：通过扫描保存的二维码轻松设置新设备。

要使用此功能，只需选择要导出的OTP，然后选择"导出为二维码"选项。然后，您可以安全地保存二维码图像，或立即使用它在另一个应用程序中设置OTP。

## 👥 贡献

欢迎贡献！请随时提交Pull Request。

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 🙏 致谢

- [Dart](https://dart.dev) 🎯
- [Flutter](https://flutter.dev) 💙
- [OTP RFC 6238](https://tools.ietf.org/html/rfc6238) 🔢

## 📊 项目状态

![GitHub stars](https://img.shields.io/github/stars/yourusername/otp-authenticator?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/otp-authenticator?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/otp-authenticator)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/otp-authenticator)

