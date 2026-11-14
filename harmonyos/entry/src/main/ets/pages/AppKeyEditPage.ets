import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { RawMap, getString, getNumber, asMap } from '../common/model/Models';
import { toast } from '../common/components/Toast';
import { PrimaryButton, PageBar } from '../common/components/Common';

interface ScopeOption {
  key: string;
  label: string;
}

const SCOPE_OPTIONS: ScopeOption[] = [
  { key: 'crons', label: '定时任务' },
  { key: 'envs', label: '环境变量' },
  { key: 'configs', label: '配置文件' },
  { key: 'scripts', label: '脚本管理' },
  { key: 'logs', label: '任务日志' },
  { key: 'dependencies', label: '依赖管理' },
  { key: 'system', label: '系统信息' }
];

/** AppKey 新增 / 编辑表单，字段对齐原 Flutter add_appkey_page.dart。 */
@Entry
@Component
struct AppKeyEditPage {
  @State keyId: string = '';
  @State isEdit: boolean = false;
  @State name: string = '';
  @State selected: string[] = [];
  @State saving: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['bean'] !== undefined) {
      const bean = asMap(JSON.parse(params['bean'].toString()) as Object);
      this.isEdit = true;
      this.keyId = getString(bean, '_id') || `${getNumber(bean, 'id')}`;
      this.name = getString(bean, 'name');
      const scopes = bean['scopes'] as Object[];
      if (Array.isArray(scopes)) {
        this.selected = scopes.map((s: Object): string => s.toString());
      }
    }
  }

  private toggle(scope: string): void {
    const idx = this.selected.indexOf(scope);
    if (idx >= 0) {
      this.selected.splice(idx, 1);
    } else {
      this.selected.push(scope);
    }
  }

  private async submit(): Promise<void> {
    if (this.name.trim().length === 0) {
      toast('请输入名称');
      return;
    }
    if (this.selected.length === 0) {
      toast('请至少选择一项权限');
      return;
    }
    this.saving = true;
    const data: Record<string, Object> = {
      'name': this.name.trim(),
      'scopes': this.selected
    };
    if (this.isEdit) {
      data['_id'] = this.keyId;
    }
    const resp = await this.api.saveAppKey(data);
    this.saving = false;
    if (resp.success) {
      toast('保存成功');
      router.back();
    } else {
      toast(resp.message);
    }
  }

  build() {
    Column() {
      PageBar({ title: this.isEdit ? '编辑 AppKey' : '新增 AppKey', showBack: true });

      Column({ space: 14 }) {
        Scroll() {
          Column({ space: 12 }) {
            TextInput({ placeholder: '名称', text: this.name })
              .height(44).borderRadius(4).padding({ left: 10, right: 10 })
              .backgroundColor(Color.White)
              .border({ width: 1, color: '#E4E4E4' })
              .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
              .fontSize(14).fontColor($r('app.color.text_primary'))
              .onChange((v: string) => { this.name = v; });

            Text('权限范围').fontSize(14).fontColor($r('app.color.text_secondary'));
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(SCOPE_OPTIONS, (opt: ScopeOption) => {
                Button(opt.label).height(32).fontSize(13).margin(5)
                  .backgroundColor(this.selected.indexOf(opt.key) >= 0 ? $r('app.color.brand_color') : Color.White)
                  .fontColor(this.selected.indexOf(opt.key) >= 0 ? Color.White : $r('app.color.text_primary'))
                  .onClick(() => { this.toggle(opt.key); });
              });
            }
          }.width('100%');
        }.layoutWeight(1).scrollBar(BarState.Auto).padding({ left: 20, right: 20, top: 16 });

        PrimaryButton({ label: this.saving ? '保存中…' : '保存', btnEnabled: !this.saving, onTap: () => { this.submit(); } })
          .margin({ left: 20, right: 20, bottom: 20 });
      }
      .width('100%').layoutWeight(1);
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
