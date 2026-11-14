/** 通用 UI 组件：加载态、空态、卡片、主按钮、分组标题。 */

@Component
export struct LoadingView {
  @State message: string = '加载中…';

  build() {
    Column({ space: 12 }) {
      LoadingProgress().width(40).height(40).color($r('app.color.brand_color'));
      Text(this.message).fontSize(14).fontColor($r('app.color.text_secondary'));
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center);
  }
}

@Component
export struct EmptyView {
  @State message: string = '暂无数据';

  build() {
    Column({ space: 10 }) {
      Text('📭').fontSize(40);
      Text(this.message).fontSize(14).fontColor($r('app.color.text_secondary'));
    }
    .width('100%').padding(40).justifyContent(FlexAlign.Center);
  }
}

@Component
export struct PrimaryButton {
  @State label: string = '确定';
  @State btnEnabled: boolean = true;
  onTap: () => void = () => {};

  build() {
    Button(this.label)
      .width('100%').height(48)
      .fontSize(16).fontColor(Color.White)
      .backgroundColor(this.btnEnabled ? $r('app.color.brand_color') : '#9DB8F5')
      .borderRadius(12)
      .onClick(() => {
        if (this.btnEnabled) {
          this.onTap();
        }
      });
  }
}

@Component
export struct Cell {
  @State title: string = '';
  @State desc: string = '';
  @State showArrow: boolean = true;
  onTap?: () => void;

  build() {
    Row() {
      Column({ space: 4 }) {
        if (this.title.length > 0) {
          Text(this.title).fontSize(16).fontColor($r('app.color.text_primary')).maxLines(1);
        }
        if (this.desc.length > 0) {
          Text(this.desc).fontSize(13).fontColor($r('app.color.text_secondary')).maxLines(2);
        }
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

      if (this.showArrow) {
        Text('›').fontSize(22).fontColor($r('app.color.text_secondary'));
      }
    }
    .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(Color.White)
    .onClick(() => { if (this.onTap) { this.onTap(); } });
  }
}
