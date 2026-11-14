import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { HttpResponse, LoginBean } from '../common/model/Models';
import { AppStore, AccountInfo } from '../common/store/AppStore';
import { toast } from '../common/components/Toast';
import { PrimaryButton } from '../common/components/Common';
import { Logger } from '../common/utils/Logger';

@Entry
@Component
struct LoginPage {
  @State host: string = '';
  @State username: string = '';
  @State password: string = '';
  @State twoFactor: string = '';
  @State needTwoFactor: boolean = false;
  @State loading: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    if (AppStore.getInstance().isLogin) {
      router.replaceUrl({ url: 'pages/HomePage' }).catch(() => {});
    }
  }

  private normalizeHost(): string {
    let h = this.host.trim();
    if (h.length === 0) {
      return h;
    }
    if (!h.startsWith('http://') && !h.startsWith('https://')) {
      h = 'http://' + h;
    }
    return h.replace(/\/+$/, '');
  }

  private async submit(): Promise<void> {
    const host = this.normalizeHost();
    if (host.length === 0 || this.username.trim().length === 0) {
      toast('请填写面板地址和用户名');
      return;
    }
    this.loading = true;
    try {
      let resp: HttpResponse<LoginBean>;
      if (this.needTwoFactor) {
        resp = await this.api.loginTwo(host, this.username.trim(), this.password, this.twoFactor.trim());
      } else {
        resp = await this.api.login(host, this.username.trim(), this.password);
      }

      if (resp.success && resp.data && resp.data.token.length > 0) {
        const account = new AccountInfo();
        account.host = host;
        account.username = this.username.trim();
        account.token = resp.data.token;
        account.twoFactorActivated = resp.data.twoFactorActivated;
        await AppStore.getInstance().upsert(account);
        toast('登录成功');
        router.replaceUrl({ url: 'pages/HomePage' }).catch(() => {});
      } else {
        const msg = resp.message || '登录失败';
        if (msg.includes('two-factor') || msg.includes('两步') || msg.includes('2FA')) {
          this.needTwoFactor = true;
          toast('请输入两步验证码');
        } else {
          toast(msg);
        }
      }
    } catch (e) {
      Logger.e('login error: ' + (e as Error).message);
      toast('网络异常，请检查面板地址');
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 渐变头部（对齐 Flutter 亮色主题 App Bar 渐变）
      Column({ space: 10 }) {
        Text('青龙客户端')
          .fontSize(26).fontWeight(FontWeight.Medium)
          .fontColor(Color.White);

        Text('连接你的青龙面板')
          .fontSize(14).fontColor('#DFF5E6');
      }
      .width('100%').padding({ top: 70, bottom: 46 })
      .alignItems(HorizontalAlign.Center)
      .linearGradient({
        angle: 90,
        colors: [[$r('app.color.gradient_start'), 0], [$r('app.color.gradient_end'), 1]]
      });

      Column({ space: 16 }) {
        TextInput({ placeholder: '面板地址，如 http://192.168.1.1:5700', text: this.host })
          .height(44).borderRadius(4).padding({ left: 10, right: 10 })
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E4E4E4' })
          .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
          .fontSize(14).fontColor($r('app.color.text_primary'))
          .onChange((v: string) => { this.host = v; });

        TextInput({ placeholder: '用户名', text: this.username })
          .height(44).borderRadius(4).padding({ left: 10, right: 10 })
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E4E4E4' })
          .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
          .fontSize(14).fontColor($r('app.color.text_primary'))
          .onChange((v: string) => { this.username = v; });

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .height(44).borderRadius(4).padding({ left: 10, right: 10 })
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E4E4E4' })
          .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
          .fontSize(14).fontColor($r('app.color.text_primary'))
          .onChange((v: string) => { this.password = v; });

        if (this.needTwoFactor) {
          TextInput({ placeholder: '两步验证码', text: this.twoFactor })
            .height(44).borderRadius(4).padding({ left: 10, right: 10 })
            .backgroundColor(Color.White)
            .border({ width: 1, color: '#E4E4E4' })
            .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
            .fontSize(14).fontColor($r('app.color.text_primary'))
            .onChange((v: string) => { this.twoFactor = v; });
        }

        PrimaryButton({ label: this.loading ? '登录中…' : '登录', btnEnabled: !this.loading, onTap: () => { this.submit(); } });

        Text('支持账号密码登录；如开启两步验证，登录后补充验证码。')
          .fontSize(12).fontColor($r('app.color.text_desc'))
          .textAlign(TextAlign.Center);
      }
      .width('100%').padding({ left: 20, right: 20, top: 26 })
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1);
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
