import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { ConfigBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar } from '../common/components/Common';
import { AppIcon } from '../common/components/Icons';

@Component
export struct ConfigPage {
  @State list: ConfigBean[] = [];
  @State loading: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    const resp = await this.api.configFiles();
    this.loading = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  build() {
    Column() {
      PageBar({ title: '配置文件' });

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView({ message: '暂无配置文件' });
      } else {
        List() {
          ForEach(this.list, (c: ConfigBean) => {
            ListItem() {
              Row() {
                AppIcon({ name: 'script', size: 21, iconColor: $r('app.color.brand_color') });
                Column({ space: 3 }) {
                  Text(c.title).fontSize(16).fontColor($r('app.color.text_primary')).maxLines(1);
                  Text(c.value).fontSize(13).fontColor($r('app.color.text_desc')).maxLines(1);
                }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 12 });

                AppIcon({ name: 'chev', size: 16, iconColor: '#C8C8C8' }).margin({ left: 8 });
              }
              .width('100%')
              .padding({ left: 15, right: 15, top: 13, bottom: 13 })
              .backgroundColor(Color.White)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ConfigEditorPage', params: { name: c.title } }).catch(() => {});
              });
            }
          }, (c: ConfigBean) => `${c.title}-${c.value}`);
        }
        .width('100%').layoutWeight(1)
        .scrollBar(BarState.Off)
        .divider({
          strokeWidth: 0.5,
          color: $r('app.color.divider_color'),
          startMargin: 15,
          endMargin: 0
        });
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
