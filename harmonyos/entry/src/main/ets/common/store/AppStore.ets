import dataPreferences from '@ohos.data.preferences';
import { Logger } from '../utils/Logger';

/** 单个面板账号信息。 */
export class AccountInfo {
  host: string = '';
  username: string = '';
  token: string = '';
  twoFactorActivated: boolean = false;
  useSecret: boolean = false;
  lastAddress: string = '';

  toJson(): Record<string, Object> {
    return {
      'host': this.host,
      'username': this.username,
      'token': this.token,
      'twoFactorActivated': this.twoFactorActivated,
      'useSecret': this.useSecret,
      'lastAddress': this.lastAddress
    };
  }

  static fromJson(m: Record<string, Object>): AccountInfo {
    const a = new AccountInfo();
    a.host = m['host'] ? m['host'].toString() : '';
    a.username = m['username'] ? m['username'].toString() : '';
    a.token = m['token'] ? m['token'].toString() : '';
    a.twoFactorActivated = m['twoFactorActivated'] === true;
    a.useSecret = m['useSecret'] === true;
    a.lastAddress = m['lastAddress'] ? m['lastAddress'].toString() : '';
    return a;
  }
}

const STORE_NAME: string = 'qinglong_store';
const KEY_ACCOUNTS: string = 'accounts';
const KEY_CURRENT: string = 'current_index';

/** 全局账号 / 会话存储：内存态 + preferences 持久化。 */
export class AppStore {
  private static instance: AppStore | null = null;
  private pref: dataPreferences.Preferences | null = null;
  accounts: AccountInfo[] = [];
  currentIndex: number = -1;

  static getInstance(): AppStore {
    if (!AppStore.instance) {
      AppStore.instance = new AppStore();
    }
    return AppStore.instance;
  }

  async init(context: Context): Promise<void> {
    this.pref = await dataPreferences.getPreferences(context, STORE_NAME);
    const raw = this.pref.getString(KEY_ACCOUNTS, '[]');
    try {
      const arr = JSON.parse(raw) as Object[];
      this.accounts = arr.map((x: Object): AccountInfo =>
        AccountInfo.fromJson(x as Record<string, Object>));
    } catch (e) {
      Logger.e('parse accounts failed: ' + (e as Error).message);
      this.accounts = [];
    }
    this.currentIndex = this.pref.getSync(KEY_CURRENT, -1) as number;
    if (this.currentIndex < 0 || this.currentIndex >= this.accounts.length) {
      this.currentIndex = this.accounts.length > 0 ? 0 : -1;
    }
    this.syncAppStorage();
  }

  private syncAppStorage(): void {
    const cur = this.current;
    AppStorage.setOrCreate('currentHost', cur ? cur.host : '');
    AppStorage.setOrCreate('currentToken', cur ? cur.token : '');
    AppStorage.setOrCreate('currentUsername', cur ? cur.username : '');
  }

  get current(): AccountInfo | null {
    if (this.currentIndex >= 0 && this.currentIndex < this.accounts.length) {
      return this.accounts[this.currentIndex];
    }
    return null;
  }

  get isLogin(): boolean {
    const cur = this.current;
    return cur !== null && cur.token.length > 0;
  }

  private async persist(): Promise<void> {
    if (!this.pref) {
      return;
    }
    await this.pref.set(KEY_ACCOUNTS, JSON.stringify(this.accounts.map(a => a.toJson())));
    await this.pref.set(KEY_CURRENT, this.currentIndex);
    await this.pref.flush();
    this.syncAppStorage();
  }

  /** 新增或更新账号（按 host+username 匹配）。 */
  async upsert(account: AccountInfo, switchTo: boolean = true): Promise<void> {
    const idx = this.accounts.findIndex(a =>
      a.host === account.host && a.username === account.username);
    if (idx >= 0) {
      this.accounts[idx] = account;
      if (switchTo) {
        this.currentIndex = idx;
      }
    } else {
      this.accounts.push(account);
      if (switchTo) {
        this.currentIndex = this.accounts.length - 1;
      }
    }
    await this.persist();
  }

  async remove(index: number): Promise<void> {
    if (index < 0 || index >= this.accounts.length) {
      return;
    }
    this.accounts.splice(index, 1);
    if (this.currentIndex === index) {
      this.currentIndex = this.accounts.length > 0 ? 0 : -1;
    } else if (this.currentIndex > index) {
      this.currentIndex -= 1;
    }
    await this.persist();
  }

  async switchTo(index: number): Promise<void> {
    if (index >= 0 && index < this.accounts.length) {
      this.currentIndex = index;
      await this.persist();
    }
  }

  async logoutCurrent(): Promise<void> {
    if (this.currentIndex >= 0) {
      await this.remove(this.currentIndex);
    }
  }
}
