import { Api } from '../common/api/Api';
import { toast } from '../common/components/Toast';
import { PageBar } from '../common/components/Common';
import { AppIcon, LogoMark } from '../common/components/Icons';

@Entry
@Component
struct AboutPage {
  @State version: string = '1.0.0';
  @State author: string = '孟云';
  private api: Api = new Api();

  private async checkUpdate(): Promise<void> {
    const resp = await this.api.checkUpdate();
    if (resp.success) {
      toast('已是最新版本');
    } else {
      toast(resp.message || '检查更新失败');
    }
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(16).fontColor($r('app.color.text_primary'));
      Blank().layoutWeight(1);
      Text(value).fontSize(16).fontColor('#B0B0B0').maxLines(1);
    }
    .width('100%').height(52)
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
      PageBar({ title: '关于软件', showBack: true });

      Scroll() {
        Column() {
          // 居中 Logo 区
          Column({ space: 10 }) {
            LogoMark({ iconSize: 84, markRadius: 20 }).margin({ top: 26 });
            Text('青龙客户端').fontSize(20).fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'));
            Text('基于青龙开源项目打造的第三方客户端')
              .fontSize(13).fontColor('#B0B0B0')
              .textAlign(TextAlign.Center);
          }
          .width('100%');

          // 信息卡：左黑右灰
          Column() {
            this.InfoRow('版本', this.version);
            Divider().strokeWidth(0.5).color($r('app.color.divider_color')).margin({ left: 15 });
            this.InfoRow('作者', this.author);
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(10)
          .clip(true)
          .margin({ top: 22 });

          // 反馈分组
          Text('反馈').fontSize(13).fontColor('#9A9A9A')
            .margin({ left: 6, top: 18, bottom: 8 })
            .width('100%');

          Column() {
            this.LinkRow('download', '下载地址', () => { toast('敬请期待'); });
            Divider().strokeWidth(0.5).color($r('app.color.divider_color')).margin({ left: 49 });
            this.LinkRow('shield', '用户协议', () => { toast('敬请期待'); });
            Divider().strokeWidth(0.5).color($r('app.color.divider_color')).margin({ left: 49 });
            this.LinkRow('plane', 'App 更新通知', () => { this.checkUpdate(); });
            Divider().strokeWidth(0.5).color($r('app.color.divider_color')).margin({ left: 49 });
            this.LinkRow('share', '分享 App', () => { toast('感谢支持'); });
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(10)
          .clip(true);

          Text('APP不会收集任何关于您的信息,使用前请仔细阅读用户协议')
            .fontSize(13).fontColor('#B0B0B0')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ top: 22, bottom: 24 });
        }
        .width('100%')
        .padding({ left: 12, right: 12 });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
