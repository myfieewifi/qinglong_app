import router from '@ohos.router';
import webview from '@ohos.web.webview';
import { Api } from '../common/api/Api';
import { TaskBean, JsonMap, asMap } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { PrimaryButton } from '../common/components/Common';
import { CodeMirrorEditor, WebCodeBridge } from '../common/components/CodeMirrorEditor';

@Entry
@Component
struct TaskEditPage {
  @State name: string = '';
  @State command: string = '';
  @State schedule: string = '';
  @State remarks: string = '';
  @State sId: string = '';
  @State taskId: number = 0;
  @State saving: boolean = false;
  private api: Api = new Api();
  private webCtrl: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['bean'] !== undefined) {
      const bean = TaskBean.fromJson(asMap(JSON.parse(params['bean'].toString()) as Object));
      this.name = bean.name;
      this.command = bean.command;
      this.schedule = bean.schedule;
      this.remarks = bean.remarks;
      this.sId = bean.sId;
      this.taskId = bean.id;
      this.webCtrl.runJavaScript(`setCode(${JSON.stringify(this.command)})`);
    }
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0 || this.schedule.trim().length === 0) {
      toast('请填写任务名称和定时规则');
      return;
    }
    let command = this.command;
    try {
      const r: Object = await this.webCtrl.runJavaScript('getCode()');
      command = WebCodeBridge.unwrapResult(r, this.command);
    } catch (e) {
      // 兜底沿用本地缓存
    }
    this.saving = true;
    const payload: Record<string, Object> = {
      'name': this.name.trim(),
      'command': command,
      'schedule': this.schedule.trim(),
      'remarks': this.remarks
    };
    if (this.sId.length > 0) {
      payload['_id'] = this.sId;
      payload['id'] = this.taskId;
    }
    const resp = await this.api.saveTask(payload);
    this.saving = false;
    if (resp.success) {
      toast('保存成功');
      router.back();
    } else {
      toast(resp.message);
    }
  }

  build() {
    Column({ space: 16 }) {
      Text(this.sId.length > 0 ? '编辑任务' : '新增任务')
        .fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 16 });

      TextInput({ placeholder: '任务名称', text: this.name })
        .height(48).borderRadius(12).backgroundColor(Color.White)
        .onChange((v: string) => { this.name = v; });

      TextInput({ placeholder: 'Cron 定时规则，如 0 9 * * *', text: this.schedule })
        .height(48).borderRadius(12).backgroundColor(Color.White)
        .onChange((v: string) => { this.schedule = v; });

      Column({ space: 6 }) {
        Text('执行脚本命令').fontSize(14).fontColor($r('app.color.text_secondary'));
        CodeMirrorEditor({ code: this.command, controller: this.webCtrl, theme: 'dracula' })
          .height(220).borderRadius(12).clip(true);
      }.width('100%');

      TextInput({ placeholder: '备注（可选）', text: this.remarks })
        .height(48).borderRadius(12).backgroundColor(Color.White)
        .onChange((v: string) => { this.remarks = v; });

      PrimaryButton({ label: this.saving ? '保存中…' : '保存', btnEnabled: !this.saving, onTap: () => { this.save(); } });
    }
    .width('100%').height('100%').padding(20)
    .backgroundColor($r('app.color.bg_page'));
  }
}
