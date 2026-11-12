import { webview } from '@ohos.web.webview';

/**
 * 基于 WebView 的 CodeMirror 代码编辑器封装（对齐原 Flutter 端 WebView 编辑器方案）。
 * - setCode：回填代码
 * - getCode：读取当前编辑器内容
 * - setTheme：dracula / default
 * - setMode：shell / javascript / python / yaml
 * 依赖 rawfile/codemirror.html；CDN 加载失败时自动退化为原生 textarea 读写。
 */
@Component
export struct CodeMirrorEditor {
  @State code: string = '';
  @State theme: string = 'dracula';
  controller: webview.WebviewController = new webview.WebviewController();
  private inited: boolean = false;

  private jsArg(text: string): string {
    return JSON.stringify(text == null ? '' : text);
  }

  setCode(text: string): void {
    this.code = text;
    if (this.inited) {
      this.controller.runJavaScript(`setCode(${this.jsArg(text)})`);
    }
  }

  async getCode(): Promise<string> {
    try {
      const res = await this.controller.runJavaScriptReturningResult('getCode()');
      return res ? res.toString() : this.code;
    } catch (e) {
      return this.code;
    }
  }

  setTheme(name: string): void {
    this.theme = name;
    if (this.inited) {
      this.controller.runJavaScript(`setTheme(${this.jsArg(name)})`);
    }
  }

  setMode(mode: string): void {
    if (this.inited) {
      this.controller.runJavaScript(`setMode(${this.jsArg(mode)})`);
    }
  }

  build() {
    Web({ src: $rawfile('codemirror.html'), controller: this.controller })
      .width('100%')
      .height('100%')
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .onPageEnd(() => {
        this.inited = true;
        this.controller.runJavaScript(`setTheme(${this.jsArg(this.theme)})`);
        this.controller.runJavaScript(`setCode(${this.jsArg(this.code)})`);
      });
  }
}
