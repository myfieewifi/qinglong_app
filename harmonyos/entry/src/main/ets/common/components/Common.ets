/** 通用 UI 组件：浅灰导航栏、iOS 分段选择器、搜索胶囊、加载态、空态、渐变主按钮、单元格、状态角标。对齐安卓端截图视觉。 */
import router from '@ohos.router';
import { AppIcon } from './Icons';

/** 顶部导航栏：浅灰底 #F2F2F2，黑色粗体居中标题 17，左侧绿色返回箭头，右侧绿色文字/图标操作。 */
@Component
export struct PageBar {
  @State title: string = '';
  @State showBack: boolean = false;
  @State actionTitle: string = '';
  @State actionIcon: string = '';
  onAction: () => void = () => {};

  build() {
    Row() {
      Row() {
        if (this.showBack) {
          AppIcon({ name: 'back', size: 22, iconColor: $r('app.color.brand_color'),
            onTap: () => { router.back(); } });
        }
      }
      .width(48).height('100%').justifyContent(FlexAlign.Center);

      Text(this.title)
        .fontSize(17).fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1).textAlign(TextAlign.Center)
        .layoutWeight(1);

      Row() {
        if (this.actionTitle.length > 0) {
          Text(this.actionTitle).fontSize(16).fontColor($r('app.color.brand_color'))
            .onClick(() => { this.onAction(); });
        } else if (this.actionIcon.length > 0) {
          AppIcon({ name: this.actionIcon, size: 20, iconColor: $r('app.color.brand_color'),
            onTap: () => { this.onAction(); } });
        }
      }
      .width(48).height('100%').justifyContent(FlexAlign.Center);
    }
    .width('100%').height(52)
    .backgroundColor($r('app.color.bar_bg'));
  }
}

/** iOS 式分段选择器：灰色圆角容器 + 白色圆角选中块 + 黑字。 */
@Component
export struct SegmentControl {
  @State titles: string[] = [];
  @Prop segIndex: number = 0;
  onChange: (idx: number) => void = (idx: number) => {};

  build() {
    Row() {
      ForEach(this.titles, (t: string, idx: number) => {
        Column() {
          if (this.segIndex === idx) {
            Column() {
              Text(t).fontSize(13).fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary')).maxLines(1);
            }
            .width('100%').height('100%').justifyContent(FlexAlign.Center)
            .backgroundColor(Color.White)
            .borderRadius(7)
            .shadow({ radius: 3, color: '#14000000', offsetY: 1 });
          } else {
            Column() {
              Text(t).fontSize(13).fontColor('#333333').maxLines(1);
            }
            .width('100%').height('100%').justifyContent(FlexAlign.Center);
          }
        }
        .layoutWeight(1).height('100%')
        .onClick(() => { this.onChange(idx); });
      }, (t: string) => t);
    }
    .width('100%').height(32)
    .padding(2)
    .backgroundColor($r('app.color.segment_bg'))
    .borderRadius(8);
  }
}

/** 灰底白色圆角胶囊搜索框：placeholder 居中带放大镜。 */
@Component
export struct SearchCapsule {
  @State search: string = '';
  @State hint: string = '搜索';
  onSearch: (v: string) => void = (v: string) => {};

  build() {
    Stack({ alignContent: Alignment.Center }) {
      TextInput({ text: this.search })
        .height(34).borderRadius(17).backgroundColor(Color.White)
        .padding({ left: 14, right: 14 })
        .fontSize(14).fontColor($r('app.color.text_primary'))
        .onChange((v: string) => { this.search = v; this.onSearch(v); });

      if (this.search.length === 0) {
        Row({ space: 5 }) {
          AppIcon({ name: 'search', size: 14, iconColor: '#B9B9B9' });
          Text(this.hint).fontSize(14).fontColor('#B9B9B9');
        }
        .hitTestBehavior(HitTestMode.Transparent);
      }
    }
    .width('100%').height(34);
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

/** 主按钮：绿色渐变胶囊（对齐安卓端登录/退出按钮）。 */
@Component
export struct PrimaryButton {
  @State label: string = '确定';
  @State btnEnabled: boolean = true;
  onTap: () => void = () => {};

  build() {
    Button(this.label)
      .width('100%').height(46)
      .fontSize(16).fontColor(Color.White)
      .borderRadius(23)
      .linearGradient({
        angle: 90,
        colors: [[$r('app.color.gradient_start'), 0], [$r('app.color.gradient_end'), 1]]
      })
      .opacity(this.btnEnabled ? 1 : 0.5)
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
        AppIcon({ name: 'chev', size: 16, iconColor: '#C8C8C8' }).margin({ left: 8 });
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

/** 描边文字角标（已启用/已禁用等）：彩字 + 同色细描边，圆角 4。 */
@Component
export struct StatusBadge {
  @State title: string = '';
  @State badgeColor: ResourceStr = '#FB5858';
  @State lightBg: ResourceStr = '#00FB5858';

  build() {
    Text(this.title)
      .fontSize(11).fontColor(this.badgeColor)
      .padding({ left: 5, right: 5, top: 2, bottom: 2 })
      .backgroundColor(this.lightBg)
      .borderRadius(4)
      .border({ width: 1, color: this.badgeColor });
  }
}
