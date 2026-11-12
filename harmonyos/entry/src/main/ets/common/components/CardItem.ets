import { Style } from '../StyleConst';

/** 统一卡片容器：白底、12 圆角、轻投影，对齐原 Flutter 卡片观感。 */
@Component
export struct CardItem {
  @BuilderParam content: () => void;
  onClick?: () => void;

  build() {
    Column() {
      this.content();
    }
    .width('100%')
    .padding(Style.paddingCard)
    .borderRadius(Style.radiusCard)
    .backgroundColor($r('app.color.bg_card'))
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      if (this.onClick) { this.onClick(); }
    });
  }
}
