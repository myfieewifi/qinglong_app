/** 通用 UI 组件：渐变导航栏、加载态、空态、主按钮、单元格、状态角标。对齐 Flutter 版青龙视觉。 */
import router from '@ohos.router';

/** 顶部导航栏：亮色主题下为 #5DD16F→#099657 渐变，白字 17，左右操作位。 */
@Component
export struct PageBar {
  @State title: string = '';
  @State showBack: boolean = false;
  @State actionTitle: string = '';
  onAction: () => void = () => {};

  build() {
    Row() {
      Row() {
        if (this.showBack) {
          Text('‹').fontSize(26).fontColor(Color.White)
            .onClick(() => { router.back(); });
        }
      }
      .width(44).height('100%').justifyContent(FlexAlign.Center);

      Text(this.title)
        .fontSize(17).fontWeight(FontWeight.Medium)
        .fontColor(Color.White).maxLines(1).textAlign(TextAlign.Center)
        .layoutWeight(1);

      Row() {
        if (this.actionTitle.length > 0) {
          Text(this.actionTitle).fontSize(15).fontColor(Color.White)
            .onClick(() => { this.onAction(); });
        }
      }
      .width(56).height('100%').justifyContent(FlexAlign.End).padding({ right: 14 });
    }
    .width('100%').height(50)
    .linearGradient({
      angle: 90,
      colors: [[$r('app.color.gradient_start'), 0], [$r('app.color.gradient_end'), 1]]
    });
  }
}

@Component
export struct LoadingView {
  @State message: string = '加载中…';

  build() {
    Column({ space: 12 }) {
      LoadingProgress().width(36).height(36).color($r('app.color.brand_color'));
      Text(this.message).fontSize(14).fontColor($r('app.color.text_desc'));
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center);
  }
}

@Component
export struct EmptyView {
  @State message: string = '暂无数据';

  build() {
    Column({ space: 10 }) {
      Text(this.message).fontSize(14).fontColor($r('app.color.text_desc'));
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
      .width('100%').height(46)
      .fontSize(16).fontColor(Color.White)
      .backgroundColor(this.btnEnabled ? $r('app.color.brand_color') : $r('app.color.btn_disabled'))
      .borderRadius(20)
      .onClick(() => {
        if (this.btnEnabled) {
          this.onTap();
        }
      });
  }
}

/** 白底单元格：标题 #1A1A1A 16，说明 #B3B3B3 13，右箭头，贴边分割线风格。 */
@Component
export struct Cell {
  @State title: string = '';
  @State desc: string = '';
  @State showArrow: boolean = true;
  onTap?: () => void;

  build() {
    Row() {
      Column({ space: 3 }) {
        if (this.title.length > 0) {
          Text(this.title).fontSize(16).fontColor($r('app.color.text_primary')).maxLines(1);
        }
        if (this.desc.length > 0) {
          Text(this.desc).fontSize(13).fontColor($r('app.color.text_desc')).maxLines(2);
        }
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

      if (this.showArrow) {
        Text('›').fontSize(22).fontColor($r('app.color.text_desc')).margin({ left: 8 });
      }
    }
    .width('100%').padding({ left: 15, right: 15, top: 13, bottom: 13 })
    .backgroundColor(Color.White)
    .onClick(() => { if (this.onTap) { this.onTap(); } });
  }
}

/** 运行中角标：主色 10% 底 + 1px 描边 + 小菊花，字号 10。 */
@Component
export struct RunningBadge {
  build() {
    Row({ space: 3 }) {
      LoadingProgress().width(12).height(12).color($r('app.color.brand_color'));
      Text('运行中').fontSize(10).fontColor($r('app.color.brand_color'));
    }
    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
    .backgroundColor($r('app.color.brand_color_light'))
    .borderRadius(2)
    .border({ width: 1, color: $r('app.color.brand_color') });
  }
}

/** 彩色文字角标（已禁用/已启用等）。 */
@Component
export struct StatusBadge {
  @State title: string = '';
  @State badgeColor: ResourceStr = '#FB5858';
  @State lightBg: ResourceStr = '#1AFB5858';

  build() {
    Text(this.title)
      .fontSize(10).fontColor(this.badgeColor)
      .padding({ left: 4, right: 4, top: 2, bottom: 2 })
      .backgroundColor(this.lightBg)
      .borderRadius(2)
      .border({ width: 1, color: this.badgeColor });
  }
}
