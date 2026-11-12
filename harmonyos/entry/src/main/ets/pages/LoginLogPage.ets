import { Api } from '../common/api/Api';
import { LoginLogBean } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { LoadingView, EmptyView } from '../common/components/Common';
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
      Row() {
        Text('登录日志').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1);
        Button('刷新').height(36).onClick(() => { this.load(); });
      }.padding(12);

      if (this.loading) {
        LoadingView();
      } else if (this.list.length === 0) {
        EmptyView('暂无登录日志');
      } else {
        List({ space: 10 }) {
          ForEach(this.list, (log: LoginLogBean, i: number) => {
            ListItem() {
              Column({ space: 6 }) {
                Row() {
                  Text(log.ip || '-').fontSize(15).layoutWeight(1)
                    .fontColor($r('app.color.text_primary'));
                  Text(log.status === 0 ? '成功' : '失败')
                    .fontSize(12).fontColor(log.status === 0 ? $r('app.color.success_color') : $r('app.color.danger_color'));
                }.width('100%');
                Text(log.address || log.platform || '-').fontSize(12)
                  .fontColor($r('app.color.text_secondary'));
                Text(formatTime(log.timestamp)).fontSize(12)
                  .fontColor($r('app.color.text_secondary'));
              }
              .width('100%').padding(14).backgroundColor(Color.White).borderRadius(12);
            }
          }, (log: LoginLogBean, i: number) => `${i}-${log.ip}-${log.timestamp}`);
        }
        .layoutWeight(1).padding({ left: 12, right: 12, bottom: 12 });
      }
    }
    .width('100%').height('100%');
  }
}
