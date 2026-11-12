import { router } from '@ohos.router';
import { Api } from '../common/api/Api';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';

@Entry
@Component
struct TaskLogPage {
  @State taskId: string = '';
  @State taskName: string = '';
  @State content: string = '';
  @State loading: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.taskId = params['id'] !== undefined ? params['id'].toString() : '';
      this.taskName = params['name'] !== undefined ? params['name'].toString() : '';
    }
    if (this.taskId.length > 0) {
      this.loadLog();
    }
  }

  async loadLog(): Promise<void> {
    this.loading = true;
    const resp = await this.api.cronLog(this.taskId);
    this.loading = false;
    if (resp.success) {
      this.content = resp.data ?? '';
    } else {
      toast(resp.message);
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.taskName.length > 0 ? this.taskName : '任务日志')
          .fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('刷新').height(36).onClick(() => { this.loadLog(); });
      }.margin({ top: 16 });

      if (this.loading) {
        LoadingView();
      } else if (this.content.length === 0) {
        EmptyView('暂无日志');
      } else {
        Scroll() {
          Text(this.content)
            .fontSize(13).fontFamily('monospace')
            .fontColor($r('app.color.text_primary')).width('100%');
        }
        .layoutWeight(1).backgroundColor(Color.White).borderRadius(12).padding(12);
      }
    }
    .width('100%').height('100%').padding(20)
    .backgroundColor($r('app.color.bg_page'));
  }
}
