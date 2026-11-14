import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { TaskBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar, RunningBadge, StatusBadge, SegmentControl, SearchCapsule } from '../common/components/Common';
import { formatTime } from '../common/utils/DateFmt';

@Component
export struct TaskPage {
  @State list: TaskBean[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  @State search: string = '';
  @State segIndex: number = 0;
  private tabs: string[] = ['全部', '运行中', '从未运行', '已禁用'];
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
        Text(t.name).fontSize(16).fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: '55%' });
        if (t.running) {
          RunningBadge().margin({ left: 7 });
        }
        if (t.isDisabled === 1) {
          StatusBadge({ title: '已禁用', badgeColor: '#FB5858', lightBg: '#00FB5858' })
            .margin({ left: 7 });
        }
        Blank().layoutWeight(1);
        Text(t.lastExecutionTime === 0 ? '-' : formatTime(t.lastExecutionTime))
          .fontSize(12).fontColor($r('app.color.text_desc')).maxLines(1);
      }
      .width('100%');

      Text(t.schedule).fontSize(13).fontColor($r('app.color.text_secondary'))
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%');

      Text(t.command).fontSize(13).fontColor($r('app.color.text_desc'))
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
    .padding({ left: 15, right: 15, top: 12, bottom: 12 })
    .backgroundColor(t.isPinned === 1 ? '#F2FBF5' : Color.White);
  }

  build() {
    Column() {
      PageBar({
        title: '定时任务',
        actionIcon: 'plus',
        onAction: () => { router.pushUrl({ url: 'pages/TaskEditPage' }).catch(() => {}); }
      });

      // 搜索胶囊：白底圆角浮在页面浅灰底上
      Column() {
        SearchCapsule({
          search: this.search,
          onSearch: (v: string) => { this.search = v; }
        });
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 8, bottom: 8 });

      // 分段筛选：iOS 式灰底白色选中块
      Column() {
        SegmentControl({
          titles: this.tabs,
          segIndex: this.segIndex,
          onChange: (idx: number) => { this.segIndex = idx; }
        });
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 8 });

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
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
