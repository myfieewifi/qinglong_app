import router from '@ohos.router';
import { AppStore } from '../common/store/AppStore';
import { toast } from '../common/components/Toast';

interface MenuEntry {
  title: string;
  icon: string;
  route: string;
}

@Component
export struct MinePage {
  @State host: string = '';
  @State username: string = '';
  private menus: MenuEntry[] = [
    { title: '订阅管理', icon: '🔁', route: 'pages/SubscribePage' },
    { title: '依赖管理', icon: '📦', route: 'pages/DependencyPage' },
    { title: '脚本管理', icon: '📜', route: 'pages/ScriptPage' },
    { title: '任务日志', icon: '📒', route: 'pages/TaskLogPage' },
    { title: '登录日志', icon: '🔐', route: 'pages/LoginLogPage' },
    { title: '应用密钥 AppKey', icon: '🗝', route: 'pages/AppKeyPage' },
    { title: '修改密码', icon: '🛠', route: 'pages/ChangePasswordPage' },
    { title: '关于', icon: 'ℹ️', route: 'pages/AboutPage' }
  ];

  aboutToAppear(): void {
    const cur = AppStore.getInstance().current;
    this.host = cur ? cur.host : '';
    this.username = cur ? cur.username : '';
  }

  private async logout(): Promise<void> {
    await AppStore.getInstance().logoutCurrent();
    toast('已退出登录');
    router.replaceUrl({ url: 'pages/LoginPage' }).catch(() => {});
  }

  build() {
    Column() {
      // 顶部账户区：绿色渐变（对齐 Flutter 我的页头部）
      Column({ space: 6 }) {
        Text(this.username || '未登录').fontSize(20).fontWeight(FontWeight.Medium)
          .fontColor(Color.White);
        Text(this.host).fontSize(13).fontColor('#DFF5E6').maxLines(1);
      }
      .width('100%').padding({ left: 15, right: 15, top: 18, bottom: 18 })
      .alignItems(HorizontalAlign.Start)
      .linearGradient({
        angle: 90,
        colors: [[$r('app.color.gradient_start'), 0], [$r('app.color.gradient_end'), 1]]
      });

      List() {
        ForEach(this.menus, (m: MenuEntry) => {
          ListItem() {
            Row() {
              Text(m.icon).fontSize(18).margin({ right: 12 });
              Text(m.title).fontSize(16).fontColor($r('app.color.text_primary')).layoutWeight(1);
              Text('›').fontSize(20).fontColor($r('app.color.text_desc'));
            }
            .width('100%').padding({ left: 16, right: 16, top: 15, bottom: 15 })
            .backgroundColor(Color.White)
            .onClick(() => { router.pushUrl({ url: m.route }).catch(() => {}); });
          }
        });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.divider_color'),
        startMargin: 46,
        endMargin: 0
      });

      Button('退出登录')
        .width('100%').height(46).margin({ left: 15, right: 15, bottom: 16 })
        .fontSize(15)
        .fontColor($r('app.color.danger_color')).backgroundColor(Color.White)
        .borderRadius(20)
        .onClick(() => { this.logout(); });
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'));
  }
}
