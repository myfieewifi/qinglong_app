import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { RawMap, getString, getNumber, asMap } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { PrimaryButton, PageBar } from '../common/components/Common';

/** 订阅新增 / 编辑表单，字段对齐原 Flutter add_subscribe_page.dart。 */
@Entry
@Component
struct SubscribeEditPage {
  @State subId: number = 0;
  @State isEdit: boolean = false;
  @State name: string = '';
  @State url: string = '';
  @State branch: string = '';
  @State type: string = 'public';          // public | single | private
  @State scheduleType: string = 'cron';    // cron | interval
  @State cron: string = '';
  @State intervalValue: string = '';
  @State intervalUnit: string = 'days';     // days | hours | minutes | seconds
  @State pullType: string = 'privateKey'; // privateKey | userName
  @State username: string = '';
  @State password: string = '';
  @State privateKey: string = '';
  @State whitelist: string = '';
  @State blacklist: string = '';
  @State dependences: string = '';
  @State extensions: string = '';
  @State subBefore: string = '';
  @State subAfter: string = '';
  @State saving: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['bean'] !== undefined) {
      const bean = asMap(JSON.parse(params['bean'].toString()) as Object);
      this.isEdit = true;
      this.subId = getNumber(bean, 'id');
      this.name = getString(bean, 'name');
      this.url = getString(bean, 'url');
      this.branch = getString(bean, 'branch');
      this.type = getString(bean, 'type') || 'public';
      this.scheduleType = getString(bean, 'schedule_type') || 'cron';
      this.cron = getString(bean, 'schedule');
      this.whitelist = getString(bean, 'whitelist');
      this.blacklist = getString(bean, 'blacklist');
      this.dependences = getString(bean, 'dependences');
      this.extensions = getString(bean, 'extensions');
      this.subBefore = getString(bean, 'sub_before');
      this.subAfter = getString(bean, 'sub_after');
      const interval = bean['interval_schedule'] as RawMap;
      if (interval) {
        this.intervalValue = getString(interval, 'value');
        this.intervalUnit = getString(interval, 'type') || 'days';
      }
      const pullOption = bean['pull_option'] as RawMap;
      if (pullOption) {
        this.username = getString(pullOption, 'username');
        this.password = getString(pullOption, 'password');
        this.privateKey = getString(pullOption, 'private_key');
      }
    }
  }

  private unitCode(label: string): string {
    if (label === '时') { return 'hours'; }
    if (label === '分') { return 'minutes'; }
    if (label === '秒') { return 'seconds'; }
    return 'days';
  }

  private unitLabel(code: string): string {
    if (code === 'hours') { return '时'; }
    if (code === 'minutes') { return '分'; }
    if (code === 'seconds') { return '秒'; }
    return '天';
  }

  private async submit(): Promise<void> {
    if (this.url.trim().length === 0) {
      toast('请填写订阅地址');
      return;
    }
    this.saving = true;
    const params: Record<string, Object> = {
      'name': this.name.trim(),
      'type': this.type,
      'schedule_type': this.scheduleType,
      'url': this.url.trim()
    };
    if (this.isEdit) {
      params['id'] = this.subId;
    }
    if (this.scheduleType === 'cron') {
      params['schedule'] = this.cron.trim();
    } else {
      const intervalSchedule: Record<string, Object> = {
        'type': this.intervalUnit,
        'value': parseInt(this.intervalValue, 10) || 0
      };
      params['interval_schedule'] = intervalSchedule;
    }
    if (this.type === 'private') {
      params['pull_type'] = this.pullType;
      if (this.pullType === 'userName') {
        const pullOption: Record<string, Object> =
          { 'username': this.username, 'password': this.password };
        params['pull_option'] = pullOption;
      } else {
        const pullOption: Record<string, Object> = { 'private_key': this.privateKey };
        params['pull_option'] = pullOption;
      }
    }
    if (this.type !== 'single') {
      params['branch'] = this.branch.trim();
      params['whitelist'] = this.whitelist.trim();
      params['blacklist'] = this.blacklist.trim();
      params['dependences'] = this.dependences.trim();
      params['extensions'] = this.extensions.trim();
      params['sub_before'] = this.subBefore.trim();
      params['sub_after'] = this.subAfter.trim();
    }
    const resp = await this.api.saveSubscribe(params);
    this.saving = false;
    if (resp.success) {
      toast('保存成功');
      router.back();
    } else {
      toast(resp.message);
    }
  }

  @Builder
  Seg(options: string[], current: string, onPick: (v: string) => void) {
    Row({ space: 8 }) {
      ForEach(options, (opt: string) => {
        Button(opt).height(32).fontSize(13)
          .backgroundColor(current === opt ? $r('app.color.brand_color') : Color.White)
          .fontColor(current === opt ? Color.White : $r('app.color.text_primary'))
          .onClick(() => { onPick(opt); });
      });
    }
  }

  build() {
    Column() {
      PageBar({ title: this.isEdit ? '编辑订阅' : '新增订阅', showBack: true });

      Column({ space: 14 }) {
        Scroll() {
        Column({ space: 12 }) {
          TextInput({ placeholder: '名称（可选）', text: this.name })
            .height(48).borderRadius(12).backgroundColor(Color.White)
            .onChange((v: string) => { this.name = v; });
          TextInput({ placeholder: '订阅地址 URL', text: this.url })
            .height(48).borderRadius(12).backgroundColor(Color.White)
            .onChange((v: string) => { this.url = v; });

          Row({ space: 10 }) {
            Text('类型').width(70).fontSize(14);
            this.Seg(['public', 'single', 'private'], this.type, (v) => { this.type = v; });
          };

          Row({ space: 10 }) {
            Text('定时方式').width(70).fontSize(14);
            this.Seg(['cron', 'interval'], this.scheduleType, (v) => { this.scheduleType = v; });
          };

          if (this.scheduleType === 'cron') {
            TextInput({ placeholder: 'Cron 表达式，如 0 9 * * *', text: this.cron })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.cron = v; });
          } else {
            Row({ space: 10 }) {
              TextInput({ placeholder: '间隔数值', text: this.intervalValue })
                .height(48).borderRadius(12).backgroundColor(Color.White).layoutWeight(1)
                .onChange((v: string) => { this.intervalValue = v; });
              this.Seg(['天', '时', '分', '秒'], this.unitLabel(this.intervalUnit),
                (label) => { this.intervalUnit = this.unitCode(label); });
            }
          }

          if (this.type === 'private') {
            Row({ space: 10 }) {
              Text('拉取方式').width(70).fontSize(14);
              this.Seg(['privateKey', 'userName'], this.pullType, (v) => { this.pullType = v; });
            };
            if (this.pullType === 'userName') {
              TextInput({ placeholder: '用户名', text: this.username })
                .height(48).borderRadius(12).backgroundColor(Color.White)
                .onChange((v: string) => { this.username = v; });
              TextInput({ placeholder: '密码', text: this.password })
                .height(48).borderRadius(12).backgroundColor(Color.White)
                .onChange((v: string) => { this.password = v; });
            } else {
              TextInput({ placeholder: 'SSH 私钥', text: this.privateKey })
                .height(80).borderRadius(12).backgroundColor(Color.White)
                .onChange((v: string) => { this.privateKey = v; });
            }
          }

          if (this.type !== 'single') {
            TextInput({ placeholder: '分支（可选）', text: this.branch })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.branch = v; });
            TextInput({ placeholder: '白名单（可选，逗号分隔）', text: this.whitelist })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.whitelist = v; });
            TextInput({ placeholder: '黑名单（可选，逗号分隔）', text: this.blacklist })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.blacklist = v; });
            TextInput({ placeholder: '依赖包（可选）', text: this.dependences })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.dependences = v; });
            TextInput({ placeholder: '脚本后缀（可选）', text: this.extensions })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.extensions = v; });
            TextInput({ placeholder: '执行前置命令（可选）', text: this.subBefore })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.subBefore = v; });
            TextInput({ placeholder: '执行后置命令（可选）', text: this.subAfter })
              .height(48).borderRadius(12).backgroundColor(Color.White)
              .onChange((v: string) => { this.subAfter = v; });
          }
        }.width('100%');
      }.layoutWeight(1).scrollBar(BarState.Auto).padding({ left: 20, right: 20, top: 16 });

      PrimaryButton({ label: this.saving ? '保存中…' : '保存', btnEnabled: !this.saving, onTap: () => { this.submit(); } })
        .margin({ left: 20, right: 20, bottom: 20 });
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
