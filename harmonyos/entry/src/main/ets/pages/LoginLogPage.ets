import { Api } from '../common/api/Api';
import { LoginLogBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView, PageBar } from '../common/components/Common';
import { formatTime } from '../common/utils/DateFmt';

@Entry
@Component
struct LoginLogPage {
  @State list: LoginLogBean[] = [];
  @State loading: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    const resp = await this.api.loginLogs();
    this.loading = false;
    if (resp.success && resp.data) {
      this.list = resp.data;
    } else {
      toast(resp.message || '加载失败');
    }
  }

  build() {
    Column() {
      PageBar({ title: '登录日志', showBack: true });

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView({ message: '暂无登录日志' });
      } else {
        List() {
          ForEach(this.list, (log: LoginLogBean, i: number) => {
            ListItem() {
              Column({ space: 6 }) {
                Row() {
                  Text(log.ip || '-').fontSize(15).layoutWeight(1)
                    .fontColor($r('app.color.text_primary'));
                  Text(log.status === 0 ? '成功' : '失败')
                    .fontSize(12).fontColor(log.status === 0 ? $r('app.color.success_color') : $r('app.color.danger_color'));
                }.width('100%');
                Text(log.address || log.platform || '-').fontSize(13)
                  .fontColor($r('app.color.text_desc'));
                Text(formatTime(log.timestamp)).fontSize(12)
                  .fontColor($r('app.color.text_desc'));
              }
              .width('100%').padding({ left: 15, right: 15, top: 10, bottom: 10 })
              .backgroundColor(Color.White);
            }
          }, (log: LoginLogBean, i: number) => `${i}-${log.ip}-${log.timestamp}`);
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
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
