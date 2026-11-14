import { Api } from '../common/api/Api';
import { ScriptNode } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';

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
      Row() {
        Text('脚本管理').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('刷新').height(36).onClick(() => { this.load(); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.flat.length === 0) {
        EmptyView({ message: '暂无脚本' });
      } else {
        List({ space: 10 }) {
          ForEach(this.flat, (node: ScriptNode) => {
            ListItem() {
              Row() {
                Text(node.children.length > 0 ? '📁' : '📜').fontSize(18).margin({ right: 10 });
                Text(node.title).fontSize(15).layoutWeight(1)
                  .fontColor($r('app.color.text_primary')).maxLines(1);
              }
              .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12)
              .onClick(() => { this.open(node); });
            }
          }, (node: ScriptNode) => `${node.parent}/${node.title}`);
        }
        .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
      }

      if (this.preview.length > 0) {
        Scroll() {
          Text(this.preview).fontSize(13).fontFamily('monospace').width('100%');
        }
        .height(180).padding(12).backgroundColor(Color.White)
        .borderRadius(12).margin({ left: 12, right: 12, bottom: 12 });
      }
    }
    .width('100%').height('100%');
  }
}
