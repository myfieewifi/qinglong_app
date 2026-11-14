import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { HttpResponse, LoginBean } from '../common/model/Models';
import { AppStore, AccountInfo } from '../common/store/AppStore';
import { toast } from '../common/components/Toast';
import { PrimaryButton } from '../common/components/Common';
import { LogoMark } from '../common/components/Icons';
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

  /** 下划线式输入行：左标签 + 右输入框。 */
  @Builder
  FieldRow(label: string, ph: string, isSecret: boolean, idx: number) {
    Row() {
      Text(label).fontSize(15).fontColor($r('app.color.text_secondary'))
        .width(56);
      TextInput({ placeholder: ph, text: idx === 0 ? this.host :
        (idx === 1 ? this.username : (idx === 2 ? this.password : this.twoFactor)) })
        .backgroundColor(Color.Transparent)
        .layoutWeight(1).height(46)
        .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
        .fontSize(15).fontColor($r('app.color.text_primary'))
        .type(isSecret ? InputType.Password : InputType.Normal)
        .onChange((v: string) => {
          if (idx === 0) { this.host = v; }
          else if (idx === 1) { this.username = v; }
          else if (idx === 2) { this.password = v; }
          else { this.twoFactor = v; }
        });
    }
    .width('100%').height(50)
    .border({ width: { bottom: 1 }, color: { bottom: '#E7E7E7' } });
  }

  build() {
    Column() {
      // 顶部：左标题 + 右 Logo（对齐安卓端截图）
      Row() {
        Text('账号登录')
          .fontSize(24).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'));

        Blank().layoutWeight(1);

        LogoMark({ size: 46, markRadius: 10 });
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 64, bottom: 30 });

      Column({ space: 6 }) {
        this.FieldRow('域名', '如 http://192.168.1.1:5700', false, 0);
        this.FieldRow('账户', '请输入用户名', false, 1);
        this.FieldRow('密码', '请输入密码', true, 2);

        if (this.needTwoFactor) {
          this.FieldRow('验证码', '两步验证码', false, 3);
        }

        PrimaryButton({
          label: this.loading ? '登录中…' : '登录',
          btnEnabled: !this.loading,
          onTap: () => { this.submit(); }
        })
          .margin({ top: 30 });

        Text('支持账号密码登录；如开启两步验证，登录后补充验证码。')
          .fontSize(12).fontColor($r('app.color.text_desc'))
          .textAlign(TextAlign.Center)
          .margin({ top: 6 });
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);
    }
    .width('100%').height('100%')
    .backgroundColor(Color.White);
  }
}
