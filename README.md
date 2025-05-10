# 点名表

一个基于Flutter开发的跨平台点名表应用，支持Windows、Android和Web平台。

[![版本](https://img.shields.io/github/v/release/afoim/roll_call_app)](https://github.com/afoim/roll_call_app/releases)
[![许可证](https://img.shields.io/github/license/afoim/roll_call_app)](https://github.com/afoim/roll_call_app/blob/main/LICENSE)

<div align="center">
  <img src="assets/icon/icon.jpg" width="128" height="128" alt="点名表图标">
</div>

## 功能特点

- **多配置管理**: 创建和管理多个不同的点名配置
- **实时出勤记录**: 实时记录并显示出勤状态
- **时间显示**: 自动显示当前日期和时间
- **批量操作**: 支持全选/取消选择等批量操作
- **跨平台支持**: 无缝运行于Windows、Android和Web平台
- **数据持久化**: 自动保存配置和出勤记录
- **简洁直观**: 简洁美观的用户界面，操作直观

## 应用截图

![3cb65cf8c354714e1399ef5cffa4ef54](https://github.com/user-attachments/assets/b14ccf47-06dc-4040-a2d1-79896e7a026c)


## 快速开始

### 下载安装

从[GitHub Releases](https://github.com/afoim/roll_call_app/releases)页面下载最新版本:
- Windows用户: 下载`RollCall-Windows.zip`并解压运行
- Android用户: 下载`RollCall.apk`并安装
- Web用户: 下载`RollCall-Web.zip`并部署到Web服务器

### 使用指南

1. **创建点名配置**:
   - 点击右上角设置按钮
   - 输入配置名称
   - 输入名单（每行一个名字）
   - 点击"保存配置"

2. **进行点名**:
   - 在主界面查看名单
   - 点击名字标记出勤状态
   - 使用"全选"/"取消选择"按钮进行批量操作

3. **管理配置**:
   - 切换不同的点名配置
   - 编辑或删除现有配置

## 开发者指南

### 环境要求

- Flutter SDK (3.7.0+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code
- Git

### 开发环境设置

1. 克隆仓库:
```bash
git clone https://github.com/afoim/roll_call_app.git
cd roll_call_app
```

2. 安装依赖:
```bash
flutter pub get
```

3. 运行调试版本:
```bash
flutter run
```

### 一键构建脚本

项目提供了一键构建脚本`build_release.bat`，可同时构建所有平台的发布版本:

```bash
.\build_release.bat
```

脚本会自动完成以下任务:
1. 清理旧的构建文件
2. 获取项目依赖
3. 构建Web、Windows和Android版本
4. 将构建产物汇总到`shell-output`目录

### 单独构建特定平台

#### Android

```bash
flutter build apk --release
```

#### Windows

```bash
flutter config --enable-windows-desktop
flutter build windows --release
```

#### Web

```bash
flutter config --enable-web
flutter build web --release
```

### 技术细节

- **状态管理**: 使用Flutter的StatefulWidget
- **数据存储**: 使用shared_preferences进行本地数据持久化
- **日期时间**: 使用intl包格式化日期和时间
- **链接处理**: 使用url_launcher处理外部链接

## 自定义应用

### 修改应用名称

编辑以下文件:
- Android: `android/app/src/main/AndroidManifest.xml` 中的 `android:label`
- Windows: `windows/runner/main.cpp` 中的 `window.Create(L"点名表", origin, size)`
- iOS: `ios/Runner/Info.plist` 中的 `CFBundleDisplayName`
- Web: `web/index.html` 中的 `<title>` 标签

### 修改应用包名

1. 编辑 `android/app/build.gradle.kts` 中的 `namespace` 和 `applicationId`
2. 更新 Kotlin 文件的包名
3. 确保 `AndroidManifest.xml` 文件中的包名一致

### 更改应用图标

1. 将图标文件放在 `assets/icon/` 目录下
2. 在 `pubspec.yaml` 中更新 `flutter_launcher_icons` 配置
3. 运行 `flutter pub run flutter_launcher_icons` 更新所有平台的图标

## 贡献指南

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

## 许可证

本项目基于MIT许可证 - 详情请查看[LICENSE](https://github.com/afoim/roll_call_app/blob/main/LICENSE)文件。

## 联系方式

AcoFork - https://link.me/acofork

项目链接: [https://github.com/afoim/roll_call_app](https://github.com/afoim/roll_call_app) 
