import { Cell } from '../common/components/Common';

@Entry
@Component
struct SettingPage {
  @State darkMode: boolean = false;
  @State largeFont: boolean = false;

  build() {
    Column({ space: 1 }) {
      Row() {
        Text('深色模式').fontSize(16).layoutWeight(1)
          .fontColor($r('app.color.text_primary'));
        Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
          .onChange((v: boolean) => { this.darkMode = v; });
      }
      .width('100%').padding(16).backgroundColor(Color.White);

      Row() {
        Text('大字体').fontSize(16).layoutWeight(1)
          .fontColor($r('app.color.text_primary'));
        Toggle({ type: ToggleType.Switch, isOn: this.largeFont })
          .onChange((v: boolean) => { this.largeFont = v; });
      }
      .width('100%').padding(16).backgroundColor(Color.White)
      .margin({ top: 1 });

      Cell({ title: '关于', desc: '版本与开源协议', showArrow: true });
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'))
    .padding({ top: 12 });
  }
}
