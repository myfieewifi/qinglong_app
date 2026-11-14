import router from '@ohos.router';
import { AppStore } from '../common/store/AppStore';
import { toast } from '../common/components/Toast';
import { PageBar, PrimaryButton } from '../common/components/Common';
import { AppIcon } from '../common/components/Icons';

@Entry
@Component
struct SettingPage {
  @State darkMode: boolean = false;
  @State largeFont: boolean = false;

  private async logout(clearAll: boolean): Promise<void> {
    const store = AppStore.getInstance();
    if (clearAll) {
      while (store.accounts.length > 0) {
        await store.remove(0);
      }
    } else {
      await store.logoutCurrent();
    }
    toast(clearAll ? '已退出并清空本地数据' : '已退出登录');
    router.replaceUrl({ url: 'pages/LoginPage' }).catch(() => {});
  }

  @Builder
  SectionLabel(label: string) {
    Text(label).fontSize(13).fontColor('#9A9A9A')
      .margin({ left: 22, top: 16, bottom: 8 });
  }

  @Builder
  SwitchRow(icon: string, title: string, isOn: boolean, onChange: (v: boolean) => void) {
    Row() {
      AppIcon({ name: icon, iconSize: 21, iconColor: $r('app.color.brand_color') });
      Text(title).fontSize(16).fontColor($r('app.color.text_primary'))
        .margin({ left: 13 }).layoutWeight(1);
      Toggle({ type: ToggleType.Switch, isOn: isOn })
        .selectedColor($r('app.color.brand_color'))
        .onChange((v: boolean) => { onChange(v); });
    }
    .width('100%').height(54)
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White);
  }

  @Builder
  LinkRow(icon: string, title: string, onTap: () => void) {
    Row() {
      AppIcon({ name: icon, iconSize: 21, iconColor: $r('app.color.brand_color') });
      Text(title).fontSize(16).fontColor($r('app.color.text_primary'))
        .margin({ left: 13 }).layoutWeight(1);
      AppIcon({ name: 'chev', iconSize: 15, iconColor: '#C8C8C8' });
    }
    .width('100%').height(54)
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White)
    .onClick(() => { onTap(); });
  }

  build() {
    Column() {
      PageBar({ title: '系统设置', showBack: true });

      Scroll() {
        Column() {
          this.SectionLabel('通用功能');

          Column() {
            this.SwitchRow('moon', '黑色主题', this.darkMode, (v: boolean) => { this.darkMode = v; });
            Divider().strokeWidth(0.5).color($r('app.color.divider_color')).margin({ left: 49 });
            this.SwitchRow('abc', '大字体', this.largeFont, (v: boolean) => { this.largeFont = v; });
            Divider().strokeWidth(0.5).color($r('app.color.divider_color')).margin({ left: 49 });
            this.LinkRow('info', '关于', () => {
              router.pushUrl({ url: 'pages/AboutPage' }).catch(() => {});
            });
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(10)
          .clip(true);

          PrimaryButton({ label: '退出登录', onTap: () => { this.logout(false); } })
            .margin({ top: 24 });

          PrimaryButton({ label: '退出登录并清空本地数据', onTap: () => { this.logout(true); } })
            .margin({ top: 12 });
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 30 })
        .alignItems(HorizontalAlign.Start);
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'));
  }
}
