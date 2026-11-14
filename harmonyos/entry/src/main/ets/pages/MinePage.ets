import router from '@ohos.router';
import { AppStore } from '../common/store/AppStore';
import { toast } from '../common/components/Toast';
import { PrimaryButton } from '../common/components/Common';
import { AppIcon, LogoMark } from '../common/components/Icons';

interface MenuEntry {
  title: string;
  icon: string;
  route: string;
}

@Component
export struct MinePage {
  @State host: string = '';
  @State username: string = '';
  private groupA: MenuEntry[] = [
    { title: '订阅管理', icon: 'subscribe', route: 'pages/SubscribePage' },
    { title: '依赖管理', icon: 'package', route: 'pages/DependencyPage' },
    { title: '脚本管理', icon: 'script', route: 'pages/ScriptPage' },
    { title: '任务日志', icon: 'book', route: 'pages/TaskLogPage' },
    { title: '登录日志', icon: 'shield', route: 'pages/LoginLogPage' }
  ];
  private groupB: MenuEntry[] = [
    { title: '应用密钥 AppKey', icon: 'key', route: 'pages/AppKeyPage' },
    { title: '修改密码', icon: 'lock', route: 'pages/ChangePasswordPage' },
    { title: '系统设置', icon: 'gear', route: 'pages/SettingPage' },
    { title: '关于', icon: 'info', route: 'pages/AboutPage' }
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

  @Builder
  MenuRow(m: MenuEntry) {
    Row() {
      AppIcon({ name: m.icon, size: 21, iconColor: $r('app.color.brand_color') });
      Text(m.title).fontSize(15).fontColor($r('app.color.text_primary'))
        .margin({ left: 13 }).layoutWeight(1);
      AppIcon({ name: 'chev', size: 15, iconColor: '#C8C8C8' });
    }
    .width('100%').height(52)
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White)
    .onClick(() => { router.pushUrl({ url: m.route }).catch(() => {}); });
  }

  @Builder
  MenuCard(menus: MenuEntry[]) {
    Column() {
      ForEach(menus, (m: MenuEntry, idx: number) => {
        if (idx > 0) {
          Divider().strokeWidth(0.5).color($r('app.color.divider_color'))
            .margin({ left: 49 });
        }
        this.MenuRow(m);
      }, (m: MenuEntry) => m.route);
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .clip(true);
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 顶部账户区：绿色渐变 + 青龙 Logo
          Row() {
            Column({ space: 6 }) {
              Text(this.username || '未登录').fontSize(20).fontWeight(FontWeight.Medium)
                .fontColor(Color.White).maxLines(1);
              Text(this.host).fontSize(13).fontColor('#DFF5E6').maxLines(1);
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1);

            LogoMark({ size: 56, markRadius: 12, bg: '#FFFFFF', fg: $r('app.color.brand_color') });
          }
          .width('100%').padding({ left: 18, right: 18, top: 22, bottom: 22 })
          .linearGradient({
            angle: 90,
            colors: [[$r('app.color.gradient_start'), 0], [$r('app.color.gradient_end'), 1]]
          });

          Column({ space: 10 }) {
            this.MenuCard(this.groupA);
            this.MenuCard(this.groupB);

            PrimaryButton({ label: '退出登录', onTap: () => { this.logout(); } })
              .margin({ top: 8 });

            Text('APP 不会收集任何关于您的信息')
              .fontSize(12).fontColor($r('app.color.text_desc'))
              .textAlign(TextAlign.Center)
              .padding({ top: 2, bottom: 16 });
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 12 });
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'));
  }
}
