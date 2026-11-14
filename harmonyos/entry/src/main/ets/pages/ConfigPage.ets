import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { ConfigBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';

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
      Row() {
        Text('配置文件').fontSize(18).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).layoutWeight(1);
        Button('刷新').height(40).onClick(() => { this.load(); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView({ message: '暂无配置文件' });
      } else {
        List({ space: 10 }) {
          ForEach(this.list, (c: ConfigBean, index: number) => {
            ListItem() {
              Row() {
                Text('📄').fontSize(20).margin({ right: 10 });
                Column({ space: 4 }) {
                  Text(c.title).fontSize(16).fontColor($r('app.color.text_primary')).maxLines(1);
                  Text(c.value).fontSize(12).fontColor($r('app.color.text_secondary')).maxLines(1);
                }.alignItems(HorizontalAlign.Start).layoutWeight(1);
                Text('›').fontSize(20).fontColor($r('app.color.text_secondary'));
              }
              .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ConfigEditorPage', params: { name: c.title } });
              });
            }
          }, (c: ConfigBean) => `${c.title}-${c.value}`);
        }
        .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
      }
    }
    .width('100%').height('100%');
  }
}
