import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import window from '@ohos.window';
import { router } from '@ohos.router';
import { AppStore } from '../common/store/AppStore';
import { HttpClient } from '../common/http/HttpClient';
import { Logger } from '../common/utils/Logger';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      await AppStore.getInstance().init(this.context);
    } catch (e) {
      Logger.e('AppStore init failed: ' + (e as Error).message);
    }

    HttpClient.getInstance().setUnauthorizedHandler(() => {
      AppStore.getInstance().logoutCurrent();
      router.replaceUrl({ url: 'pages/LoginPage' }).catch(() => {
        Logger.w('redirect to login failed');
      });
    });
    Logger.d('EntryAbility onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/LoginPage', (err) => {
      if (err.code) {
        Logger.e('loadContent failed: ' + JSON.stringify(err));
      }
    });
  }

  onDestroy(): void {
    Logger.d('EntryAbility onDestroy');
  }
}
