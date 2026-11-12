# 三端功能 / UI 对齐差异清单

> 基线：开源仓库 [hicongcn/qinglong_app](https://github.com/hicongcn/qinglong_app)（Flutter，version 3.0.0+300）。
> 本仓库版本：青龙客户端 1.0.0，作者孟云。

## 一、总体结论

| 端 | 代码形态 | 功能完整度 | 说明 |
| --- | --- | --- | --- |
| Android | 原 Flutter 工程原样纳入 | 与原版一致 | 全量 Dart 业务代码、资源、页面均保留 |
| iOS | 原 Flutter 工程原样纳入 | 与原版一致 | 同上；真机安装需签名 |
| 鸿蒙 NEXT | ArkTS 原生独立重写 | 核心模块全覆盖，细节有降级 | 接口契约对齐原版；部分交互 / 视觉未逐像素还原 |

## 二、鸿蒙端已对齐

### 网络与账号
- 登录：账号密码、两步验证、Client ID / Secret 三种方式（对应 `/api/user/login`、`/api/user/two-factor/login`、`/open/auth/token`）。
- 请求头 Bearer Token、UA、时间戳 `t`；响应体 `{ code, data, message }` 统一解析。
- 401 自动清除账号并回到登录页；多账号偏好存储。

### 业务模块
- 定时任务：列表、搜索、运行 / 停止、置顶 / 取消、启用 / 禁用、编辑、删除、日志查看。
- 环境变量：列表、搜索、明文 / 密文切换、启用 / 禁用、编辑、删除。
- 配置文件：文件列表、内容读取、保存。
- 订阅：列表、新增 / 编辑表单、删除；字段对齐原版 `name/type/url/branch/schedule_type/schedule/interval_schedule/pull_type/pull_option/whitelist/blacklist/dependences/extensions/sub_before/sub_after`。
- 依赖管理：Node.js / Python3 / Linux 三类、重装、日志、删除。
- 脚本管理：文件 / 目录树、内容读取与保存、新建文件夹（接口层已具备）。
- 日志：任务日志列表、详情；登录日志。
- AppKey：列表、新增 / 编辑表单（`crons/envs/configs/scripts/logs/dependencies/system` 七项权限）、复制密钥、重置、删除。
- 我的：修改密码、检查更新、关于页。

### 本轮补齐的交互 / 编辑器
- 列表下拉刷新：任务、变量、订阅、AppKey 页接入 `Refresh` 容器。
- CodeMirror WebView 编辑器：配置文件编辑、任务命令编辑共用同一组件；支持深浅主题切换；CDN 加载失败时退化为原生 textarea 读写。
- 全局配色规范：品牌色 `#1677FF`、页面背景 `#F7F8FA`、卡片白底 12 圆角轻投影、文字三级层级；统一 `Style` 常量与 `CardItem` 组件。

## 三、鸿蒙端未对齐 / 已降级

| 项 | 现状 | 备注 |
| --- | --- | --- |
| 侧滑删除（ListSwipe） | 未接入，删除走按钮 | API 13 可实现，但本轮以按钮操作为主 |
| 长按操作菜单 | 未接入，操作走按钮 | 同上 |
| 列表拖拽排序 | 未实现 | ArkUI 原生拖拽重排在 API 14 才有增强；API 13 受限 |
| 脚本 / 配置上传下载 | 接口层已留位，页面未接 `@ohos.file.picker` 上传与落盘下载 | 需在文件列表页接入系统选择器 |
| CodeMirror 离线化 | 当前从 jsDelivr CDN 加载 | 需 `ohos.permission.INTERNET`；可把 css/js 打入 `rawfile` 改本地引用 |
| 视觉逐像素还原 | 用 ArkUI 基础组件复刻，未还原原版图标、字体排版、间距细节与 Lottie 动画 | 图标需从原版 `assets/images/` 导出到 `base/media/` 后逐一替换 |
| 动效 / 过渡 | 原版页面过渡、按压反馈未移植 | — |
| iCloud 备份 | 未移植 | 原版为 iOS 能力，鸿蒙无对应 |
| 指纹 / 生物识别登录 | 未移植 | 需接 `@ohos.userIAM` 或本地认证能力 |
| 内购 / 会员、推送、桌面角标、商店评分跳转 | 未移植 | 部分为原版移除或平台不适用能力 |
| 订阅 alias 自动生成 | 鸿蒙侧未计算别名 | 提交时不附带 `alias`，由服务端按规则生成 |

## 四、Android / iOS 端说明

- `flutter/` 目录保留原版全部功能与 UI，仅做以下元信息调整：
  - 应用显示名：青龙客户端（Android `android:label`、iOS `CFBundleDisplayName`）。
  - 版本：`pubspec.yaml` → `1.0.0+1`；iOS `MARKETING_VERSION = 1.0.0`、`CURRENT_PROJECT_VERSION = 1`。
  - 作者：pubspec `author: 孟云`。
- Android `applicationId` 保持原版 `work.master.qinglongapp`，未改动。
- iOS 公开 CI 无证书，只能出未签名 `.app`；签名 IPA 需配置 Apple 证书与描述文件。

## 五、CI 前置条件与未验证项

1. **鸿蒙 SDK**：`harmonyos.yml` 从 [hos-sdk](https://github.com/harmonyos-dev/hos-sdk) latest release 取 Linux 命令行工具；release 资产命名、`sdkmgr` 命令、toolchains 版本以实际 release 为准。hos-sdk 提供 OpenHarmony toolchains，与纯血 HarmonyOS NEXT 商业 SDK 的兼容性未在本地验证。
2. **签名**：三条流水线默认产出未签名产物（APK 可自签；iOS `.app` 未签名；HAP 未签名）。真机安装分别需要：Android 调试 / 发布签名、Apple 证书 + Profile、鸿蒙调试 Profile / 发布证书。
3. **编译未实测**：本仓库在无 Flutter SDK、无 Xcode、无鸿蒙 SDK 的环境中静态生成；鸿蒙 ArkTS 未经 hvigor 实编，首次构建可能需修正类型 / API 细节。
4. **Flutter 版本**：原工程 Dart SDK 约束 `>=2.18.0 <3.0.0`，CI 默认使用 Flutter 3.7.12；若放宽约束可升级 Flutter 版本。
