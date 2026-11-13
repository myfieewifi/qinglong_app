# 青龙客户端

- **应用名称**：青龙客户端
- **版本号**：1.0.0（build 1）
- **作者**：孟云
- **许可证**：AGPL-3.0（衍生自 [hicongcn/qinglong_app](https://github.com/hicongcn/qinglong_app)，后端面板 [whyour/qinglong](https://github.com/whyour/qinglong)）

本仓库是一个同时收纳 **Android、iOS、鸿蒙（HarmonyOS NEXT）** 三端代码的 monorepo，并为三端分别提供 GitHub Actions 打包流水线。

---

## 一、仓库结构

```
qinglong-client/
├── flutter/                     # Android / iOS 端（原 Flutter 工程纳入）
│   ├── lib/                     # Dart 业务源码（216 个文件）
│   ├── android/                # Android 壳，applicationId work.master.qinglongapp
│   ├── ios/                    # iOS 壳，显示名「青龙客户端」
│   ├── assets/
│   └── pubspec.yaml             # version 1.0.0+1，author 孟云
│
├── harmonyos/                   # 鸿蒙端（ArkTS 原生重写，独立工程）
│   ├── entry/src/main/ets/
│   │   ├── common/             # 网络层、模型、存储、工具、通用组件、编辑器
│   │   └── pages/               # 各业务页面 + 订阅/AppKey 编辑表单
│   ├── entry/src/main/resources/rawfile/codemirror.html
│   ├── build-profile.json5      # API 13（5.0.1(13)），versionName 1.0.0
│   └── oh-package.json5         # version 1.0.0，author 孟云
│
├── .github/workflows/
│   ├── flutter-android.yml      # Flutter 构建 release APK
│   ├── flutter-ios.yml          # macOS 构建 iOS 归档（默认未签名）
│   └── harmonyos.yml             # setup-ohos 安装鸿蒙命令行工具 + hvigorw 构建 HAP
│
├── docs/
│   └── DIFF.md                   # 三端功能 / UI 对齐差异与已知限制
└── LICENSE                       # AGPL-3.0 全文
```

## 二、三端出包边界（务必先读）

> **这不是「一份代码一次编译出 APK + IPA + HAP」的工程。**

| 端 | 代码来源 | 构建链 | 产物 |
| --- | --- | --- | --- |
| Android | `flutter/` 原 Flutter 工程 | Flutter + Gradle | release APK |
| iOS | `flutter/` 原 Flutter 工程 | Flutter + Xcode/CocoaPods | `.app` / 签名后 IPA |
| 鸿蒙 NEXT | `harmonyos/` ArkTS 独立工程 | hvigor + OpenHarmony/鸿蒙 SDK | HAP |

- Flutter 官方只覆盖 Android / iOS / Web / 桌面，**不包含鸿蒙**；纯血 HarmonyOS NEXT 上必须用 ArkTS 原生开发，因此鸿蒙端是独立重写的第二套代码。
- 两条构建链相互独立：Flutter 流水线不碰鸿蒙，鸿蒙流水线不碰 Flutter。

## 三、GitHub Actions 打包

### 1. Android（`flutter-android.yml`）
- 触发：push 到 `main/master`、打 `v*` tag、手动触发。
- Runner：`ubuntu-latest`；自动安装 Flutter 3.7.12、JDK 17，`flutter pub get` 后 `flutter build apk --release`。
- 产物：`qinglong-client-android-apk`（Artifact）；打 tag 时自动附加到 Release。

### 2. iOS（`flutter-ios.yml`）
- Runner：`macos-latest`；`pod install` 后构建。
- **公开 Runner 无 Apple 开发者证书，默认以 `--no-codesign` 构建未签名 `.app`**，不能直接安装到真机。
- 要出可安装的签名 IPA，需在仓库 **Secrets** 配置：开发者证书 `.p12`、描述文件、证书密码，并启用工作流末尾注释掉的签名 / `flutter build ipa` 步骤。

### 3. 鸿蒙 NEXT（`harmonyos.yml`）
- Runner 本身没有鸿蒙 SDK，工作流用 Marketplace 的 [ErBWs/setup-ohos](https://github.com/marketplace/actions/setup-harmonyos-tools) 自动安装鸿蒙命令行工具（含 `hvigorw` / `ohpm` / SDK，版本 `5.0.13.200`，与 `compatibleSdkVersion 5.0.1(13)` 同代）。
- 流程：安装 `libgl1` → `setup-ohos` → `ohpm install --all` → `hvigorw assembleHap`。
- 产物：`qinglong-client-harmonyos-hap`（Artifact，未签名 HAP）。
- **限制**：HAP 默认未签名，真机安装需调试 Profile / 发布证书，可在 DevEco Studio 中签名或用 `hdc` / `hap-sign` 自行处理。

## 四、本地构建前置条件

| 端 | 前置环境 |
| --- | --- |
| Android | Flutter SDK 3.7.x、Android SDK / NDK、JDK 17 |
| iOS | macOS、Xcode、CocoaPods、Apple 开发者签名（真机安装） |
| 鸿蒙 | DevEco Studio 5.x、HarmonyOS SDK API 13、ohpm、hvigor；调试签名用于侧载 |

## 五、合规说明

- 本仓库三端代码均为原 **AGPL-3.0** 项目的衍生作品，继续以 **AGPL-3.0** 开源：修改、分发、网络提供服务均需公开源码。
- 作者署名「孟云」仅作为元信息标注，**不替换、不豁免** AGPL-3.0 许可证。
- 应用仅用于管理你自己部署的青龙面板，不内置广告、推广或第三方上报。

## 六、未在本地编译验证的声明

本仓库在无 Flutter SDK、无 Xcode、无鸿蒙 SDK 的环境中静态整理生成：
- 鸿蒙 ArkTS 工程**未经过 hvigor 实际编译**，首次在 DevEco / CI 跑通时可能出现类型标注、系统 API 签名层面的报错，需按提示逐条修正；
- Flutter 工程为原仓库原样纳入，其能否在所选 Flutter 版本下直接构建，需在首次 CI 中核对；
- 三端与原工程的功能 / UI 对齐差距详见 [`docs/DIFF.md`](docs/DIFF.md)。
