import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { EnvBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';

@Component
export struct EnvPage {
  @State list: EnvBean[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  @State search: string = '';
  @State reveal: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load(false);
  }

  async load(pull: boolean): Promise<void> {
    if (pull) { this.refreshing = true; } else { this.loading = true; }
    const resp = await this.api.envs(this.search.trim());
    this.loading = false;
    this.refreshing = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  private filtered(): EnvBean[] {
    const kw = this.search.trim();
    if (kw.length === 0) {
      return this.list;
    }
    return this.list.filter((e: EnvBean) => e.name.includes(kw));
  }

  private ident(e: EnvBean): string {
    return e.sId.length > 0 ? e.sId : `${e.id}`;
  }

  async toggle(e: EnvBean): Promise<void> {
    const resp = e.disabled ? await this.api.enableEnvs([this.ident(e)]) :
      await this.api.disableEnvs([this.ident(e)]);
    toast(resp.success ? '操作成功' : resp.message);
    this.load(false);
  }

  async remove(e: EnvBean): Promise<void> {
    const resp = await this.api.deleteEnvs([this.ident(e)]);
    toast(resp.success ? '已删除' : resp.message);
    this.load(false);
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        TextInput({ placeholder: '搜索变量', text: this.search })
          .layoutWeight(1).height(40).borderRadius(10).backgroundColor(Color.White)
          .onChange((v: string) => { this.search = v; });
        Button(this.reveal ? '隐藏' : '明文').height(40)
          .onClick(() => { this.reveal = !this.reveal; });
        Button('刷新').height(40).onClick(() => { this.load(false); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.filtered().length === 0) {
        EmptyView({ message: '暂无环境变量' });
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List({ space: 10 }) {
            ForEach(this.filtered(), (e: EnvBean) => {
              ListItem() {
                Column({ space: 8 }) {
                  Row() {
                    Column({ space: 4 }) {
                      Text(e.name).fontSize(16).fontWeight(FontWeight.Medium)
                        .fontColor($r('app.color.text_primary')).maxLines(1);
                      Text(this.reveal ? e.value : '••••••••')
                        .fontSize(13).fontColor($r('app.color.text_secondary')).maxLines(1);
                      if (e.remarks.length > 0) {
                        Text(e.remarks).fontSize(12).fontColor($r('app.color.text_secondary'));
                      }
                    }.alignItems(HorizontalAlign.Start).layoutWeight(1);
                    Text(e.disabled ? '已禁用' : '启用')
                      .fontSize(12).fontColor(e.disabled ? $r('app.color.text_secondary') : $r('app.color.success_color'));
                  }.width('100%');

                  Row({ space: 8 }) {
                    Button(e.disabled ? '启用' : '禁用').height(32).fontSize(13)
                      .onClick(() => { this.toggle(e); });
                    Button('编辑').height(32).fontSize(13)
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/EnvEditPage', params: { bean: JSON.stringify(e) } });
                      });
                    Button('删除').height(32).fontSize(13).fontColor($r('app.color.danger_color'))
                      .onClick(() => { this.remove(e); });
                  }
                }
                .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12);
              }
            }, (e: EnvBean) => this.ident(e));
          }
          .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
        }
        .onRefresh(() => { this.load(true); });
      }

      Button('+ 新增变量')
        .width('92%').height(46).margin(12)
        .backgroundColor($r('app.color.brand_color'))
        .onClick(() => { router.pushUrl({ url: 'pages/EnvEditPage' }); });
    }
    .width('100%').height('100%');
  }
}
