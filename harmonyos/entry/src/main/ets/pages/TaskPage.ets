import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { TaskBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar, RunningBadge, StatusBadge } from '../common/components/Common';
import { formatTime } from '../common/utils/DateFmt';

interface TabEntry {
  title: string;
}

@Component
export struct TaskPage {
  @State list: TaskBean[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  @State search: string = '';
  @State segIndex: number = 0;
  private tabs: TabEntry[] = [
    { title: '全部' },
    { title: '运行中' },
    { title: '从未运行' },
    { title: '已禁用' }
  ];
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

  private inTab(t: TaskBean): boolean {
    if (this.segIndex === 1) {
      return t.running;
    }
    if (this.segIndex === 2) {
      return !t.running && t.lastExecutionTime === 0;
    }
    if (this.segIndex === 3) {
      return t.isDisabled === 1;
    }
    return true;
  }

  private filtered(): TaskBean[] {
    const kw = this.search.trim();
    return this.list.filter((t: TaskBean) => {
      if (!this.inTab(t)) {
        return false;
      }
      if (kw.length === 0) {
        return true;
      }
      return t.name.includes(kw) || t.command.includes(kw) || t.schedule.includes(kw);
    });
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

  @Builder
  TaskCell(t: TaskBean) {
    Column({ space: 5 }) {
      Row() {
        Text(t.name).fontSize(17).fontColor($r('app.color.text_primary'))
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '60%' });
        if (t.running) {
          RunningBadge().margin({ left: 7 });
        }
        if (t.isDisabled === 1) {
          Column() {
            StatusBadge({ title: '已禁用', badgeColor: '#FB5858', lightBg: '#1AFB5858' });
          }.margin({ left: 7 });
        }
        Blank().layoutWeight(1);
        Text(t.lastExecutionTime === 0 ? '-' : formatTime(t.lastExecutionTime))
          .fontSize(12).fontColor($r('app.color.text_desc')).maxLines(1);
      }
      .width('100%');

      Text(t.schedule).fontSize(14).fontColor($r('app.color.text_desc'))
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%');

      Text(t.command).fontSize(14).fontColor($r('app.color.text_desc'))
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%');

      Row({ space: 20 }) {
        Text(t.running ? '停止' : '运行').fontSize(13).fontColor($r('app.color.brand_color'))
          .onClick(() => {
            if (t.running) { this.stop(t); } else { this.run(t); }
          });
        Text('日志').fontSize(13).fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            router.pushUrl({ url: 'pages/TaskLogPage', params: { id: this.ident(t), name: t.name } }).catch(() => {});
          });
        Text('编辑').fontSize(13).fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            router.pushUrl({ url: 'pages/TaskEditPage', params: { bean: JSON.stringify(t) } }).catch(() => {});
          });
        Text('删除').fontSize(13).fontColor($r('app.color.danger_color'))
          .onClick(() => { this.remove(t); });
      }
      .width('100%').justifyContent(FlexAlign.End)
      .padding({ top: 2 });
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
    .backgroundColor(t.isPinned === 1 ? '#F2FBF5' : Color.White);
  }

  build() {
    Column() {
      PageBar({ title: '定时任务' });

      // 搜索区：Flutter SearchCell —— 白底圆角输入框浮在浅灰底上
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

      // 分段筛选：下划线指示器（对齐 Flutter TabBar）
      Row() {
        ForEach(this.tabs, (item: TabEntry) => {
          Column() {
            Text(item.title)
              .fontSize(14)
              .fontColor(this.segIndex === this.tabs.indexOf(item) ? $r('app.color.brand_color') : '#999999');
          }
          .layoutWeight(1).height(40).justifyContent(FlexAlign.Center)
          .border({ width: { bottom: 2 }, color: { bottom: this.segIndex === this.tabs.indexOf(item) ? $r('app.color.brand_color') : Color.Transparent } })
          .onClick(() => { this.segIndex = this.tabs.indexOf(item); });
        }, (item: TabEntry) => item.title);
      }
      .width('100%')
      .backgroundColor($r('app.color.tabbar_bg'));

      if (this.loading) {
        LoadingView();
      } else if (this.filtered().length === 0) {
        EmptyView({ message: '暂无定时任务' });
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List() {
            ForEach(this.filtered(), (t: TaskBean) => {
              ListItem() {
                this.TaskCell(t);
              }
            }, (t: TaskBean) => this.ident(t));
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

      Button('+ 新增任务')
        .width('100%').height(46).margin({ left: 15, right: 15, bottom: 10, top: 8 })
        .fontSize(15)
        .backgroundColor($r('app.color.brand_color'))
        .borderRadius(20)
        .onClick(() => { router.pushUrl({ url: 'pages/TaskEditPage' }).catch(() => {}); });
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
