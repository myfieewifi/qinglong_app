import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { EnvBean, asMap } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { PrimaryButton } from '../common/components/Common';

@Entry
@Component
struct EnvEditPage {
  @State name: string = '';
  @State value: string = '';
  @State remarks: string = '';
  @State sId: string = '';
  @State envId: number = 0;
  @State saving: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['bean'] !== undefined) {
      const bean = EnvBean.fromJson(asMap(JSON.parse(params['bean'].toString()) as Object));
      this.name = bean.name;
      this.value = bean.value;
      this.remarks = bean.remarks;
      this.sId = bean.sId;
      this.envId = bean.id;
    }
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      toast('请填写变量名');
      return;
    }
    this.saving = true;
    const payload: Record<string, Object> = {
      'name': this.name.trim(),
      'value': this.value,
      'remarks': this.remarks
    };
    if (this.sId.length > 0) {
      payload['_id'] = this.sId;
      payload['id'] = this.envId;
    }
    const resp = await this.api.saveEnv(payload);
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
      Text(this.sId.length > 0 ? '编辑变量' : '新增变量')
        .fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 16 });

      TextInput({ placeholder: '变量名', text: this.name })
        .height(48).borderRadius(12).backgroundColor(Color.White)
        .onChange((v: string) => { this.name = v; });

      TextArea({ placeholder: '变量值', text: this.value })
        .height(140).borderRadius(12).backgroundColor(Color.White)
        .onChange((v: string) => { this.value = v; });

      TextInput({ placeholder: '备注（可选）', text: this.remarks })
        .height(48).borderRadius(12).backgroundColor(Color.White)
        .onChange((v: string) => { this.remarks = v; });

      PrimaryButton({ label: this.saving ? '保存中…' : '保存', btnEnabled: !this.saving, onTap: () => { this.save(); } });
    }
    .width('100%').height('100%').padding(20)
    .backgroundColor($r('app.color.bg_page'));
  }
}
