import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { EnvBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar, StatusBadge } from '../common/components/Common';

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
    return this.list.filter((e: EnvBean) => e.name.includes(kw) || e.value.includes(kw));
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

  @Builder
  EnvCell(e: EnvBean) {
    Column({ space: 5 }) {
      Row() {
        Text(e.name).fontSize(17).fontColor($r('app.color.text_primary'))
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '55%' });
        if (e.disabled) {
          Column() {
            StatusBadge({ title: '已禁用', badgeColor: '#FB5858', lightBg: '#1AFB5858' });
          }.margin({ left: 7 });
        }
        Blank().layoutWeight(1);
        Text(this.reveal ? '明文' : '密文').fontSize(10)
          .fontColor($r('app.color.brand_color'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor($r('app.color.brand_color_light'))
          .borderRadius(10)
          .onClick(() => { this.reveal = !this.reveal; });
      }
      .width('100%');

      Text(this.reveal ? e.value : '••••••••')
        .fontSize(14).fontColor($r('app.color.text_desc'))
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%');

      if (e.remarks.length > 0) {
        Text(e.remarks).fontSize(12).fontColor($r('app.color.text_desc'))
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%');
      }

      Row({ space: 20 }) {
        Text(e.disabled ? '启用' : '禁用').fontSize(13).fontColor($r('app.color.brand_color'))
          .onClick(() => { this.toggle(e); });
        Text('编辑').fontSize(13).fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            router.pushUrl({ url: 'pages/EnvEditPage', params: { bean: JSON.stringify(e) } }).catch(() => {});
          });
        Text('删除').fontSize(13).fontColor($r('app.color.danger_color'))
          .onClick(() => { this.remove(e); });
      }
      .width('100%').justifyContent(FlexAlign.End)
      .padding({ top: 2 });
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    .backgroundColor(Color.White);
  }

  build() {
    Column() {
      PageBar({ title: '环境变量' });

      Column() {
        TextInput({ placeholder: '搜索', text: this.search })
          .height(36).borderRadius(10).backgroundColor(Color.White)
          .padding({ left: 12, right: 12 })
          .placeholderColor($r('app.color.text_desc')).placeholderFont({ size: 14 })
          .fontSize(15).fontColor($r('app.color.text_primary'))
          .onChange((v: string) => { this.search = v; });
      }
      .width('100%')
      .backgroundColor('#F1F1F1')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 });

      if (this.loading) {
        LoadingView();
      } else if (this.filtered().length === 0) {
        EmptyView({ message: '暂无环境变量' });
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List() {
            ForEach(this.filtered(), (e: EnvBean) => {
              ListItem() {
                this.EnvCell(e);
              }
            }, (e: EnvBean) => this.ident(e));
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
        .onRefreshing(() => { this.load(true); });
      }

      Button('+ 新增变量')
        .width('100%').height(46).margin({ left: 15, right: 15, bottom: 10, top: 8 })
        .fontSize(15)
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(20)
        .onClick(() => { router.pushUrl({ url: 'pages/EnvEditPage' }).catch(() => {}); });
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
