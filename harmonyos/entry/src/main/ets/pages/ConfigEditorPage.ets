import router from '@ohos.router';
import webview from '@ohos.web.webview';
import { Api } from '../common/api/Api';
import { toast } from '../common/components/Toast';
import { LoadingView, PrimaryButton } from '../common/components/Common';
import { CodeMirrorEditor, WebCodeBridge } from '../common/components/CodeMirrorEditor';

@Entry
@Component
struct ConfigEditorPage {
  @State fileName: string = '';
  @State content: string = '';
  @State loading: boolean = false;
  @State saving: boolean = false;
  @State theme: string = 'dracula';
  private api: Api = new Api();
  private webCtrl: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['name'] !== undefined) {
      this.fileName = params['name'].toString();
      this.loadContent();
    }
  }

  async loadContent(): Promise<void> {
    this.loading = true;
    const resp = await this.api.configContent(this.fileName);
    this.loading = false;
    if (resp.success) {
      this.content = resp.data ?? '';
      this.webCtrl.runJavaScript(`setCode(${JSON.stringify(this.content)})`);
    } else {
      toast(resp.message);
    }
  }

  private async save(): Promise<void> {
    this.saving = true;
    let text = this.content;
    try {
      const r: Object = await this.webCtrl.runJavaScript('getCode()');
      text = WebCodeBridge.unwrapResult(r, this.content);
    } catch (e) {
      // 兜底：沿用本地缓存内容
    }
    const resp = await this.api.saveFile(this.fileName, text);
    this.saving = false;
    if (resp.success) {
      toast('保存成功');
      router.back();
    } else {
      toast(resp.message);
    }
  }

  private toggleTheme(): void {
    this.theme = this.theme === 'dracula' ? 'default' : 'dracula';
    this.webCtrl.runJavaScript(`setTheme(${JSON.stringify(this.theme)})`);
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.fileName).fontSize(18).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary')).layoutWeight(1).maxLines(1);
        Button(this.theme === 'dracula' ? '浅色' : '深色').height(32).fontSize(13)
          .onClick(() => { this.toggleTheme(); });
      }.margin({ top: 16 });

      if (this.loading) {
        LoadingView();
      } else {
        CodeMirrorEditor({ code: this.content, controller: this.webCtrl, theme: this.theme })
          .layoutWeight(1).borderRadius(12).clip(true);
      }

      PrimaryButton({ label: this.saving ? '保存中…' : '保存', btnEnabled: !this.saving, onTap: () => { this.save(); } });
    }
    .width('100%').height('100%').padding(20)
    .backgroundColor($r('app.color.bg_page'));
  }
}
