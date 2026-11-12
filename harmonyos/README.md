# 青龙客户端 · 鸿蒙原生版（HarmonyOS NEXT / ArkTS）

- **应用名称**：青龙客户端　**版本**：1.0.0　**作者**：孟云
- 基于 [hicongcn/qinglong_app](https://github.com/hicongcn/qinglong_app)（Flutter 版）移植的 **纯血鸿蒙原生客户端**，使用 ArkTS + ArkUI 重写，对接开源面板 [whyour/qinglong](https://github.com/whyour/qinglong) 的 REST 接口。
- 许可证：**AGPL-3.0**。本工程为原 AGPL 项目的衍生作品，继续以 AGPL-3.0 开源，禁止闭源商用。

> 三端 monorepo 总览、功能对齐差异与 CI 前置条件见仓库根目录 `README.md` 与 `docs/DIFF.md`。

## 一、技术栈

| 项 | 选型 |
| --- | --- |
| 系统 | HarmonyOS NEXT（纯血鸿蒙），Stage Model，目标 API 13（5.0.1(13)） |
| 语言 / UI | ArkTS / ArkUI 声明式 |
| 网络 | `@ohos.net.http`（对应原工程 Dio + Token 拦截器） |
| 存储 | `@ohos.data.preferences`（多账号 / Token 持久化） |
| 编辑器 | WebView 内嵌 CodeMirror 5（`rawfile/codemirror.html`） |
| 三方依赖 | 无 ohpm 三方库，全部使用系统能力，降低适配风险 |
| 状态管理 | `@State` / `AppStorage` 轻量实现，未引入 Riverpod 等价框架 |

## 二、目录结构

```
harmonyos/
├── entry/src/main/ets/
│   ├── entryability/EntryAbility.ets   # 入口 Ability，初始化存储 / 401 登出
│   ├── common/
│   │   ├── http/        # HttpClient、Urls（端点）、拦截逻辑
│   │   ├── model/       # ArkTS 数据模型与响应包装
│   │   ├── api/Api.ets # 接口封装（对应原 api.dart）
│   │   ├── store/      # 多账号会话存储
│   │   ├── utils/       # JSON 取值、日志、时间格式化
│   │   ├── components/ # 通用组件、Toast、CardItem、CodeMirrorEditor
│   │   └── StyleConst.ets # 全局配色 / 间距 / 圆角规范
│   └── pages/          # 登录、四 Tab 主页及各业务 / 编辑表单页面
├── entry/src/main/resources/rawfile/codemirror.html
├── build-profile.json5 / oh-package.json5 / hvigorfile.ts
└── LICENSE             # AGPL-3.0
```

## 三、已实现功能

- **账号**：账号密码登录、两步验证、Client ID/Secret 登录、多账号本地保存、401 自动登出、退出登录、修改密码。
- **定时任务**：列表 / 搜索 / 下拉刷新 / 运行 / 停止 / 编辑 / 新增 / 删除 / 即时日志；脚本命令使用 CodeMirror 高亮编辑。
- **环境变量**：列表 / 搜索 / 下拉刷新 / 明文切换 / 启用禁用 / 编辑 / 新增 / 删除。
- **配置文件**：文件列表 / 内容读取 / CodeMirror 高亮编辑保存，深浅主题切换。
- **订阅管理**：列表 / 下拉刷新 / 新增 / 编辑表单（类型、定时方式、Cron / 间隔、分支、拉取凭据、白黑名单、依赖、后缀、前后置命令）/ 删除。
- **依赖管理**：Node.js / Python3 / Linux 三类切换 / 重装 / 查看日志 / 删除。
- **脚本管理**：目录树浏览 / 内容预览与保存 / 新建文件夹（接口层已具备）。
- **日志**：任务即时日志、登录日志。
- **应用密钥 AppKey**：列表 / 下拉刷新 / 新增 / 编辑表单（七项权限多选）/ 复制密钥 / 重置 / 删除。
- **我的**：面板信息、功能菜单导航、关于页（版本 1.0.0、作者孟云）、检查更新。

## 四、未移植 / 降级项（与原 Flutter 版的差异）

| 原工程能力 | 鸿蒙版处理 |
| --- | --- |
| 侧滑删除、长按操作菜单 | 未接入，当前以列表按钮操作为主 |
| 列表拖拽排序 | API 13 受限，原生拖拽重排在 API 14 才有增强 |
| 脚本 / 配置上传下载 | 接口层已留位，尚未接入 `@ohos.file.picker` 选择与落盘 |
| CodeMirror 离线化 | 当前从 jsDelivr CDN 加载，需 `INTERNET` 权限；可将 css/js 打入 `rawfile` 改本地引用 |
| 视觉逐像素还原 | 用 ArkUI 基础组件复刻，未还原原版图标、字体排版、动效与 Lottie |
| iCloud 备份 | 未移植（鸿蒙无 iCloud 对等能力） |
| 指纹 / 生物识别登录 | 未移植，保留账号密码 + 本地会话 |
| 内购 / SVIP / 赞助、消息推送、桌面角标、商店评分跳转 | 未移植 |

## 五、本地编译（DevEco Studio）

1. 安装 DevEco Studio（支持 API 13 / HarmonyOS 5.0 及以上）。
2. `File > Open` 导入 `harmonyos/` 目录，等待 SDK 与 ohpm 依赖同步完成。
3. 若提示 SDK 版本不一致，在 `File > Project Structure` 中把 `compatibleSdkVersion` 对齐本机 SDK。
4. 连接开发者模式设备或本地模拟器，点击运行；命令行等价操作：

```bash
ohpm install --all
hvigorw assembleHap --mode module -p product=default -p buildMode=debug --no-daemon
```

产物位于 `entry/build/default/outputs/default/`。

## 六、GitHub Actions 构建

工作流位于仓库根目录：`.github/workflows/harmonyos.yml`。SDK 获取 / 环境配置参考公开仓库 [harmonyos-dev/hos-sdk](https://github.com/harmonyos-dev/hos-sdk)：

1. 从 hos-sdk latest release 拉取 `commandline-tools-linux-*.zip`；
2. `sdkmgr install toolchains:9 OpenHarmony/toolchains:9 --accept-license`；
3. 配置 `HOS_SDK_HOME`，`ohpm install --all`；
4. `hvigor --mode module -p product=default assembleHap --no-daemon --accept-license`；
5. 产物 `qinglong-client-harmonyos-hap`（Artifact）；打 `v*` tag 时自动附加到 Release。

> 说明：hos-sdk 提供的是 OpenHarmony toolchains；与纯血 HarmonyOS NEXT 商业 SDK 的兼容性需首次跑通后核对。默认产出未签名 HAP，真机安装需调试 Profile / 发布证书（工作流末尾预留签名步骤）。

## 七、接口与鉴权说明

- 端点分两套：普通账号登录走 `/api/*`，AppKey（client_id / secret）登录走 `/open/*`，对应原 `url.dart`。
- 请求头自动携带桌面 UA、`Content-Type: application/json`；非白名单接口附加时间戳 `t` 与 `Authorization: Bearer <token>`。
- 响应统一解析 `{ code, data, message }`；`401` 清除当前账号并回登录页。
- 登录白名单：`/api/user/login`、`/api/login`、`/api/user/two-factor/login`、`/open/auth/token`。

## 八、合规与隐私

- 本工程不内置任何广告、推广二维码、第三方埋点或账号密码上报；网络请求仅发往你填写的青龙面板地址。
- 沿用原工程 **AGPL-3.0**，二次分发必须保留源码开放声明。
- 本工程在无鸿蒙 SDK 的环境中静态生成，**未经 hvigor 实际编译**；首次构建可能需修正类型 / API 细节。
