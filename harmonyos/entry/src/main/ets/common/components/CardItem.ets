/** 统一卡片容器：白底、12 圆角、轻投影。 */
@Component
export struct CardItem {
  @BuilderParam content: () => void;
  onClick?: () => void;

  build() {
    Column() {
      this.content();
    }
    .width('100%')
    .padding(12)
    .borderRadius(12)
    .backgroundColor($r('app.color.bg_card'))
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      if (this.onClick) { this.onClick(); }
    });
  }
}
