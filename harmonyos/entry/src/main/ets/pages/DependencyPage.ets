import { Api } from '../common/api/Api';
import { DependencyBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';

@Entry
@Component
struct DependencyPage {
  @State tabs: string[] = ['nodejs', 'python3', 'linux'];
  @State current: number = 0;
  @State list: DependencyBean[] = [];
  @State loading: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    const resp = await this.api.dependencies(this.tabs[this.current]);
    this.loading = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  async reinstall(d: DependencyBean): Promise<void> {
    const ident = d.sId.length > 0 ? d.sId : `${d.id}`;
    const resp = await this.api.reinstallDependency(ident);
    toast(resp.success ? '已触发重装' : resp.message);
    this.load();
  }

  async viewLog(d: DependencyBean): Promise<void> {
    const ident = d.sId.length > 0 ? d.sId : `${d.id}`;
    const resp = await this.api.dependencyLog(ident);
    toast(resp.success ? (resp.data ?? '暂无日志') : resp.message);
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        ForEach(this.tabs, (t: string, i: number) => {
          Text(t)
            .fontSize(13).padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(8)
            .backgroundColor(this.current === i ? $r('app.color.brand_color') : Color.White)
            .fontColor(this.current === i ? Color.White : $r('app.color.text_secondary'))
            .onClick(() => { this.current = i; this.load(); });
        });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView('暂无依赖');
      } else {
        List({ space: 10 }) {
          ForEach(this.list, (d: DependencyBean) => {
            ListItem() {
              Column({ space: 6 }) {
                Row() {
                  Text(d.name).fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1)
                    .fontColor($r('app.color.text_primary'));
                  Text(d.status === 1 ? '安装中' : '已安装')
                    .fontSize(12).fontColor($r('app.color.text_secondary'));
                }.width('100%');
                if (d.remark.length > 0) {
                  Text(d.remark).fontSize(12).fontColor($r('app.color.text_secondary'));
                }
                Row({ space: 8 }) {
                  Button('重装').size(ButtonSize.Small).onClick(() => { this.reinstall(d); });
                  Button('日志').size(ButtonSize.Small).onClick(() => { this.viewLog(d); });
                }
              }
              .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12);
            }
          }, (d: DependencyBean) => `${d.sId}-${d.id}`);
        }
        .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
      }
    }
    .width('100%').height('100%');
  }
}
