import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { RawMap, getString, getNumber } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';

@Entry
@Component
struct SubscribePage {
  @State list: RawMap[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load(false);
  }

  async load(pull: boolean): Promise<void> {
    if (pull) { this.refreshing = true; } else { this.loading = true; }
    const resp = await this.api.subscribes();
    this.loading = false;
    this.refreshing = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  async remove(item: RawMap): Promise<void> {
    const id = getNumber(item, 'id');
    const resp = await this.api.deleteSubscribe(id);
    toast(resp.success ? '已删除' : resp.message);
    this.load(false);
  }

  private edit(item: RawMap): void {
    router.pushUrl({ url: 'pages/SubscribeEditPage', params: { bean: JSON.stringify(item) } });
  }

  build() {
    Column() {
      Row() {
        Text('订阅管理').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('新增').height(36).backgroundColor($r('app.color.brand_color'))
          .onClick(() => { router.pushUrl({ url: 'pages/SubscribeEditPage' }); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView({ message: '暂无订阅' });
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List({ space: 10 }) {
            ForEach(this.list, (item: RawMap) => {
              ListItem() {
                Column({ space: 6 }) {
                  Text(getString(item, 'name') || getString(item, 'alias')).fontSize(16)
                    .fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).maxLines(1);
                  Text(getString(item, 'url')).fontSize(12)
                    .fontColor($r('app.color.text_secondary')).maxLines(2);
                  Text(`规则：${getString(item, 'schedule') || getString(item, 'interval_schedule')}`)
                    .fontSize(12).fontColor($r('app.color.text_secondary'));
                  Row({ space: 8 }) {
                    Button('编辑').height(32).fontSize(13).onClick(() => { this.edit(item); });
                    Button('删除').height(32).fontSize(13).fontColor($r('app.color.danger_color'))
                      .onClick(() => { this.remove(item); });
                  }
                }
                .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12);
              }
            }, (item: RawMap) => `${getNumber(item, 'id')}-${getString(item, 'name')}`);
          }
          .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
        }
        .onRefresh(() => { this.load(true); });
      }
    }
    .width('100%').height('100%');
  }
}
