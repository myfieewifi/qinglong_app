import { Api } from '../common/api/Api';
import { ScriptNode } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar } from '../common/components/Common';

@Entry
@Component
struct ScriptPage {
  @State list: ScriptNode[] = [];
  @State flat: ScriptNode[] = [];
  @State loading: boolean = false;
  @State preview: string = '';
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load();
  }

  private flatten(nodes: ScriptNode[], out: ScriptNode[]): void {
    nodes.forEach((n: ScriptNode) => {
      out.push(n);
      if (n.children.length > 0) {
        this.flatten(n.children, out);
      }
    });
  }

  async load(): Promise<void> {
    this.loading = true;
    const resp = await this.api.scripts();
    this.loading = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
      this.flat = [];
      this.flatten(this.list, this.flat);
    } else {
      toast(resp.message || '加载失败');
    }
  }

  async open(node: ScriptNode): Promise<void> {
    if (node.children.length > 0) {
      return;
    }
    const resp = await this.api.scriptDetail(node.title, node.parent);
    if (resp.success) {
      this.preview = resp.data ?? '';
    } else {
      toast(resp.message);
    }
  }

  build() {
    Column() {
      PageBar({ title: '脚本管理', showBack: true });

      if (this.loading) {
        LoadingView();
      } else if (this.flat.length === 0) {
        EmptyView({ message: '暂无脚本' });
      } else {
        List() {
          ForEach(this.flat, (node: ScriptNode) => {
            ListItem() {
              Row() {
                Text(node.children.length > 0 ? '📁' : '📜').fontSize(18).margin({ right: 10 });
                Text(node.title).fontSize(15).layoutWeight(1)
                  .fontColor($r('app.color.text_primary')).maxLines(1);
              }
              .width('100%').padding({ left: 15, right: 15, top: 13, bottom: 13 })
              .backgroundColor(Color.White)
              .onClick(() => { this.open(node); });
            }
          }, (node: ScriptNode) => `${node.parent}/${node.title}`);
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

      if (this.preview.length > 0) {
        Scroll() {
          Text(this.preview).fontSize(13).fontFamily('monospace').width('100%');
        }
        .height(180).padding(12).backgroundColor(Color.White)
        .borderRadius(12).margin({ left: 15, right: 15, bottom: 12 });
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
