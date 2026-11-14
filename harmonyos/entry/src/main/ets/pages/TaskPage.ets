import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { TaskBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';
import { formatTime } from '../common/utils/DateFmt';

@Component
export struct TaskPage {
  @State list: TaskBean[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  @State search: string = '';
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load(false);
  }

  async load(pull: boolean): Promise<void> {
    if (pull) { this.refreshing = true; } else { this.loading = true; }
    const resp = await this.api.crons();
    this.loading = false;
    this.refreshing = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  private filtered(): TaskBean[] {
    const kw = this.search.trim();
    if (kw.length === 0) {
      return this.list;
    }
    return this.list.filter((t: TaskBean) => t.name.includes(kw));
  }

  private ident(t: TaskBean): string {
    return t.sId.length > 0 ? t.sId : `${t.id}`;
  }

  async run(t: TaskBean): Promise<void> {
    const resp = await this.api.runCrons([this.ident(t)]);
    toast(resp.success ? '已触发运行' : resp.message);
    this.load(false);
  }

  async stop(t: TaskBean): Promise<void> {
    const resp = await this.api.stopCrons([this.ident(t)]);
    toast(resp.success ? '已停止' : resp.message);
    this.load(false);
  }

  async remove(t: TaskBean): Promise<void> {
    const resp = await this.api.deleteCrons([this.ident(t)]);
    toast(resp.success ? '已删除' : resp.message);
    this.load(false);
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        TextInput({ placeholder: '搜索任务', text: this.search })
          .layoutWeight(1).height(40).borderRadius(10).backgroundColor(Color.White)
          .onChange((v: string) => { this.search = v; });
        Button('刷新').height(40).onClick(() => { this.load(false); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.filtered().length === 0) {
        EmptyView({ message: '暂无定时任务' });
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List({ space: 10 }) {
            ForEach(this.filtered(), (t: TaskBean) => {
              ListItem() {
                Column({ space: 8 }) {
                  Row() {
                    Column({ space: 4 }) {
                      Text(t.name).fontSize(16).fontWeight(FontWeight.Medium)
                        .fontColor($r('app.color.text_primary')).maxLines(1);
                      Text(t.schedule).fontSize(13).fontColor($r('app.color.text_secondary'));
                    }.alignItems(HorizontalAlign.Start).layoutWeight(1);
                    Text(t.running ? '运行中' : '已停止')
                      .fontSize(12).fontColor(t.running ? $r('app.color.success_color') : $r('app.color.text_secondary'));
                  }.width('100%');

                  Text(`上次执行：${formatTime(t.lastExecutionTime)}`)
                    .fontSize(12).fontColor($r('app.color.text_secondary'));

                  Row({ space: 8 }) {
                    Button(t.running ? '停止' : '运行').height(32).fontSize(13)
                      .onClick(() => {
                        if (t.running) { this.stop(t); } else { this.run(t); }
                      });
                    Button('日志').height(32).fontSize(13)
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/TaskLogPage', params: { id: this.ident(t), name: t.name } });
                      });
                    Button('编辑').height(32).fontSize(13)
                      .onClick(() => {
                        router.pushUrl({ url: 'pages/TaskEditPage', params: { bean: JSON.stringify(t) } });
                      });
                    Button('删除').height(32).fontSize(13).fontColor($r('app.color.danger_color'))
                      .onClick(() => { this.remove(t); });
                  }
                }
                .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12);
              }
            }, (t: TaskBean) => this.ident(t));
          }
          .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
        }
        .onRefreshing(() => { this.load(true); });
      }

      Button('+ 新增任务')
        .width('92%').height(46).margin(12)
        .backgroundColor($r('app.color.brand_color'))
        .onClick(() => { router.pushUrl({ url: 'pages/TaskEditPage' }); });
    }
    .width('100%').height('100%');
  }
}
