import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { RawMap, getString, getNumber } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';
import pasteboard from '@ohos.pasteboard';

@Entry
@Component
struct AppKeyPage {
  @State list: RawMap[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load(false);
  }

  async load(pull: boolean): Promise<void> {
    if (pull) { this.refreshing = true; } else { this.loading = true; }
    const resp = await this.api.appKeys();
    this.loading = false;
    this.refreshing = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  private ident(item: RawMap): string {
    return getString(item, '_id') || `${getNumber(item, 'id')}`;
  }

  async copySecret(item: RawMap): Promise<void> {
    const secret = getString(item, 'secret') || getString(item, 'client_secret');
    if (secret.length === 0) {
      toast('暂无密钥');
      return;
    }
    const data = pasteboard.createPlainTextData(secret);
    await pasteboard.getSystemPasteboard().setData(data);
    toast('已复制密钥');
  }

  async reset(item: RawMap): Promise<void> {
    const resp = await this.api.resetAppKey(this.ident(item));
    toast(resp.success ? '已重置密钥' : resp.message);
    this.load(false);
  }

  async remove(item: RawMap): Promise<void> {
    const resp = await this.api.deleteAppKeys([this.ident(item)]);
    toast(resp.success ? '已删除' : resp.message);
    this.load(false);
  }

  private edit(item: RawMap): void {
    router.pushUrl({ url: 'pages/AppKeyEditPage', params: { bean: JSON.stringify(item) } });
  }

  build() {
    Column() {
      Row() {
        Text('应用密钥 AppKey').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('新增').height(36).backgroundColor($r('app.color.brand_color'))
          .onClick(() => { router.pushUrl({ url: 'pages/AppKeyEditPage' }); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView({ message: '暂无 AppKey' });
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List({ space: 10 }) {
            ForEach(this.list, (item: RawMap) => {
              ListItem() {
                Column({ space: 6 }) {
                  Text(getString(item, 'name')).fontSize(16).fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary')).maxLines(1);
                  Text(`Client ID：${getString(item, 'client_id') || getString(item, 'appId')}`)
                    .fontSize(12).fontColor($r('app.color.text_secondary'));
                  Row({ space: 8 }) {
                    Button('编辑').height(32).fontSize(13).onClick(() => { this.edit(item); });
                    Button('复制密钥').height(32).fontSize(13).onClick(() => { this.copySecret(item); });
                    Button('重置').height(32).fontSize(13).onClick(() => { this.reset(item); });
                    Button('删除').height(32).fontSize(13).fontColor($r('app.color.danger_color'))
                      .onClick(() => { this.remove(item); });
                  }
                }
                .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12);
              }
            }, (item: RawMap) => this.ident(item));
          }
          .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
        }
        .onRefreshing(() => { this.load(true); });
      }
    }
    .width('100%').height('100%');
  }
}
