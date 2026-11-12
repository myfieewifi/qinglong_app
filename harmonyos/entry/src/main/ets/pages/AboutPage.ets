import { Api } from '../common/api/Api';
import { toast } from '../common/components/Toast';

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

  build() {
    Column({ space: 14 }) {
      Text('🐉').fontSize(56).margin({ top: 40 });
      Text('青龙客户端').fontSize(20).fontWeight(FontWeight.Bold);
      Text(`版本 ${this.version}　作者：${this.author}`).fontSize(14)
        .fontColor($r('app.color.text_secondary'));

      Column({ space: 8 }) {
        Text('开源仓库：hicongcn/qinglong_app（Flutter 原版）')
          .fontSize(13).fontColor($r('app.color.text_secondary'));
        Text('鸿蒙版：ArkTS 原生移植，遵循 AGPL-3.0 协议')
          .fontSize(13).fontColor($r('app.color.text_secondary'));
        Text('后端：whyour/qinglong 开源面板')
          .fontSize(13).fontColor($r('app.color.text_secondary'));
      }
      .padding(20).backgroundColor(Color.White).borderRadius(12).margin({ top: 16 });

      Button('检查更新').width('92%').height(46)
        .backgroundColor($r('app.color.brand_color'))
        .onClick(() => { this.checkUpdate(); });

      Text('本应用仅用于管理你自己部署的青龙面板，不内置任何推广、广告或第三方上报。')
        .fontSize(12).fontColor($r('app.color.text_secondary')).textAlign(TextAlign.Center)
        .padding(20);
    }
    .width('100%').height('100%').padding(20)
    .backgroundColor($r('app.color.bg_page'));
  }
}
