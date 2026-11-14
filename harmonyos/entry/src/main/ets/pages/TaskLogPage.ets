import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar } from '../common/components/Common';

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
    Column() {
      PageBar({
        title: this.taskName.length > 0 ? this.taskName : '任务日志',
        showBack: true,
        actionTitle: '刷新',
        onAction: () => { this.loadLog(); }
      });

      if (this.loading) {
        LoadingView();
      } else if (this.content.length === 0) {
        EmptyView({ message: '暂无日志' });
      } else {
        Scroll() {
          Text(this.content)
            .fontSize(13).fontFamily('monospace')
            .fontColor($r('app.color.text_primary')).width('100%');
        }
        .layoutWeight(1).backgroundColor(Color.White).padding(12)
        .margin({ top: 8 });
      }
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
