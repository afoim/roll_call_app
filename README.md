# 智能点名表

一个基于Flutter开发的跨平台点名表应用，支持Windows、Android和Web平台。

## 功能特点

- 创建和管理多个点名配置
- 记录出勤状态
- 实时显示日期和时间
- 支持全选/取消选择
- 支持多平台：Windows、Android和Web

## 开发环境设置

1. 确保已安装Flutter SDK
2. 克隆此仓库
3. 运行 `flutter pub get` 安装依赖

```bash
git clone <repository-url>
cd <repository-name>
flutter pub get
```

## 构建应用

### Android

```bash
flutter build apk --release
```

### Windows

```bash
flutter config --enable-windows-desktop
flutter build windows --release
```

### Web

```bash
flutter build web --release
```

## CI/CD 设置

本项目使用GitHub Actions自动构建和发布应用。

### 设置Android签名

1. 运行GitHub Actions工作流 `setup_keystore.yml` 来生成签名密钥
2. 下载生成的密钥库文件和配置文件
3. 使用以下命令生成Base64编码的密钥库：
   ```bash
   base64 upload-keystore.jks | tr -d '\n'
   ```
4. 在GitHub仓库设置中添加以下Secrets：
   - `KEYSTORE_BASE64`: 用Base64编码的密钥库
   - `KEYSTORE_PASSWORD`: 密钥库密码
   - `KEY_PASSWORD`: 密钥密码
   - `KEY_ALIAS`: 密钥别名（通常为"upload"）

### 发布新版本

1. 为代码打上标签（格式：`v*`），例如：`v1.0.0`
2. 推送标签到GitHub：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. 这将自动触发构建工作流，生成所有平台的应用并创建GitHub Release

## 自定义应用

### 更改应用名称

编辑以下文件：
- Android: `android/app/src/main/AndroidManifest.xml` 中的 `android:label`
- Windows: `windows/runner/main.cpp` 中的 `window.Create(L"应用名称", origin, size)`

### 更改包名

1. 编辑 `android/app/build.gradle.kts` 中的 `namespace` 和 `applicationId`
2. 更新 `android/app/src/main/kotlin` 目录结构和Java包名

### 更改应用图标

1. 将图标文件放在 `assets/icon/app_icon.png` 和 `assets/icon/app_icon_foreground.png`
2. 运行 `flutter pub run flutter_launcher_icons` 更新所有平台的图标

## 许可证

[您的许可证信息] 