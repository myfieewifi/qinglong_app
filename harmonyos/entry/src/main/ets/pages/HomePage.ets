import { TaskPage } from './TaskPage';
import { EnvPage } from './EnvPage';
import { ConfigPage } from './ConfigPage';
import { MinePage } from './MinePage';

interface TabItem {
  key: number;
  title: string;
  icon: string;
}

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0;
  private tabs: TabItem[] = [
    { key: 0, title: '定时任务', icon: '⏱' },
    { key: 1, title: '环境变量', icon: '🔤' },
    { key: 2, title: '配置文件', icon: '📁' },
    { key: 3, title: '我的', icon: '👤' }
  ];

  @Builder
  TabPane() {
    if (this.currentIndex === 0) {
      TaskPage();
    } else if (this.currentIndex === 1) {
      EnvPage();
    } else if (this.currentIndex === 2) {
      ConfigPage();
    } else {
      MinePage();
    }
  }

  build() {
    Column() {
      Column() {
        this.TabPane();
      }.layoutWeight(1).width('100%');

      Row() {
        ForEach(this.tabs, (item: TabItem) => {
          Column({ space: 4 }) {
            Text(item.icon).fontSize(22)
              .fontColor(this.currentIndex === item.key ? $r('app.color.brand_color') : $r('app.color.text_secondary'));
            Text(item.title).fontSize(11)
              .fontColor(this.currentIndex === item.key ? $r('app.color.brand_color') : $r('app.color.text_secondary'));
          }
          .layoutWeight(1).height('100%').justifyContent(FlexAlign.Center)
          .onClick(() => { this.currentIndex = item.key; });
        });
      }
      .width('100%').height(64).backgroundColor(Color.White)
      .border({ width: { top: 0.5 }, color: { top: $r('app.color.divider_color') } });
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_page'));
  }
}
