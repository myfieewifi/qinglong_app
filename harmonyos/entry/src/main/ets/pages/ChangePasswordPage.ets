import router from '@ohos.router';
import { Api } from '../common/api/Api';
import { AppStore } from '../common/store/AppStore';
import { toast } from '../common/components/Toast';
import { PrimaryButton, PageBar } from '../common/components/Common';

@Entry
@Component
struct ChangePasswordPage {
  @State username: string = '';
  @State password: string = '';
  @State confirm: string = '';
  @State saving: boolean = false;
  private api: Api = new Api();

  aboutToAppear(): void {
    this.username = AppStore.getInstance().current?.username ?? '';
  }

  private async save(): Promise<void> {
    if (this.password.length === 0) {
      toast('请输入新密码');
      return;
    }
    if (this.password !== this.confirm) {
      toast('两次密码不一致');
      return;
    }
    this.saving = true;
    const resp = await this.api.updatePassword(this.username, this.password);
    this.saving = false;
    if (resp.success) {
      toast('密码已修改');
      router.back();
    } else {
      toast(resp.message);
    }
  }

  build() {
    Column() {
      PageBar({ title: '修改密码', showBack: true });

      Column({ space: 16 }) {
        TextInput({ placeholder: '用户名', text: this.username })
          .height(44).borderRadius(4).padding({ left: 10, right: 10 })
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#E4E4E4' })
          .enabled(false)
          .fontSize(14).fontColor($r('app.color.text_secondary'));

        TextInput({ placeholder: '新密码', text: this.password })
          .type(InputType.Password)
          .height(44).borderRadius(4).padding({ left: 10, right: 10 })
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E4E4E4' })
          .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
          .fontSize(14).fontColor($r('app.color.text_primary'))
          .onChange((v: string) => { this.password = v; });

        TextInput({ placeholder: '确认新密码', text: this.confirm })
          .type(InputType.Password)
          .height(44).borderRadius(4).padding({ left: 10, right: 10 })
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E4E4E4' })
          .placeholderColor($r('app.color.text_hint')).placeholderFont({ size: 14 })
          .fontSize(14).fontColor($r('app.color.text_primary'))
          .onChange((v: string) => { this.confirm = v; });

        PrimaryButton({ label: this.saving ? '保存中…' : '保存', btnEnabled: !this.saving, onTap: () => { this.save(); } });
      }
      .width('100%').layoutWeight(1)
      .padding({ left: 20, right: 20, top: 20, bottom: 20 });
    }
    .width('100%').height('100%')
    .backgroundColor($r('app.color.bg_page'));
  }
}
