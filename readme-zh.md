# 🔐 跨平台OTP认证器

一个用Dart构建的多功能一次性密码（OTP）认证器应用程序，支持多个平台，包括Windows、Linux、Web、Android、iOS和macOS。

[English README](./README.md)
## 🤔 为什么开发这个项目？

1. 每次我想输入验证码我都要去找我的手机，这些OTP验证器就不能好好考虑下桌面用户吗😒。
2. 这些验证器都不能导出我之前的密钥，就像靠怀孕留住老公的小三一样🤐。（至于安全，本来就是二次验证，密码被偷，密钥还被偷啊😂）。
3. 当然，我还是想要自动同步功能，这样我手机电脑都可以随时访问😁。

## ✨ 功能特点（以下均为翻译🗣，可以不看了️）

- 🖥️ 📱 跨平台支持：可在桌面、网页和移动设备上使用
- 🔄 多设备同步：从任何设备访问您的OTP代码
- 👥 用户友好界面：易于添加、管理和使用OTP代码
- 🛡️ 安全：实现行业标准的OTP算法
- 📱💻 二维码导出：为每个OTP生成二维码，方便转移到其他认证器应用
- 💾 备份和恢复：将您的OTP设置保存为二维码，实现无忧备份
## 🚀 开始使用

### 快速访问选项（这个可以看👌)

- 🌐 **网页版**：访问 [https://cloudotp.me/](https://cloudotp.me/) 直接在浏览器中使用OTP认证器。
- 📥 **预编译版本**：如果您不想自己编译应用程序，可以从 [GitHub Releases 页面](https://github.com/yourusername/otp-authenticator/releases) 下载预编译版本。（本人非苹果用户，mac,ios自己编译去哈😘/为什么不直接用web）

### 前提条件（用于从源代码编译）(非程序员止步😘)

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

该OTP认证器允许您将任何OTP设置导出为二维码。这个功能提供了几个好处：

1. 🔄 **轻松转移**：快速将您的OTP设置移动到另一个设备或认证器应用。
2. 💾 **安全备份**：为所有OTP生成并保存二维码，作为一种万无一失的备份方法。
3. 🔓 **无锁定**：您永远不会被困在这个app - 您的OTP设置始终是可移植的。
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

![GitHub stars](https://img.shields.io/github/stars/jingcjie/cloud_otp?style=social)
![GitHub issues](https://img.shields.io/github/issues/jingcjie/cloud_otp)

