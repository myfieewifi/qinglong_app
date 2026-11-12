/**
 * 青龙面板接口端点。对应原工程 url.dart。
 * useSecret=true 表示使用 AppKey(client_id/secret) 登录，走 /open 前缀；
 * 普通账号密码登录走 /api 前缀。
 */

export class Urls {
  static readonly LOGIN: string = '/api/user/login';
  static readonly LOGIN_OLD: string = '/api/login';
  static readonly LOGIN_TWO: string = '/api/user/two-factor/login';
  static readonly LOGIN_BY_CLIENT: string = '/open/auth/token';
  static readonly USER: string = '/api/user';
  static readonly SYSTEM: string = '/api/system';

  /** 登录白名单：不带 Authorization、不加时间戳参数。 */
  static inWhiteList(path: string): boolean {
    return path === Urls.LOGIN || path === Urls.LOGIN_BY_CLIENT ||
      path === Urls.LOGIN_TWO || path === Urls.LOGIN_OLD;
  }

  private static prefix(secret: boolean): string {
    return secret ? '/open' : '/api';
  }

  static crons(secret: boolean): string { return `${Urls.prefix(secret)}/crons`; }
  static cronDetail(id: string, secret: boolean): string { return `${Urls.prefix(secret)}/crons/${id}`; }
  static cronRun(secret: boolean): string { return `${Urls.prefix(secret)}/crons/run`; }
  static cronStop(secret: boolean): string { return `${Urls.prefix(secret)}/crons/stop`; }
  static cronPin(secret: boolean): string { return `${Urls.prefix(secret)}/crons/pin`; }
  static cronUnpin(secret: boolean): string { return `${Urls.prefix(secret)}/crons/unpin`; }
  static cronEnable(secret: boolean): string { return `${Urls.prefix(secret)}/crons/enable`; }
  static cronDisable(secret: boolean): string { return `${Urls.prefix(secret)}/crons/disable`; }
  static cronLog(id: string, secret: boolean): string { return `${Urls.prefix(secret)}/crons/${id}/log`; }

  static envs(secret: boolean): string { return `${Urls.prefix(secret)}/envs`; }
  static envMove(id: string, secret: boolean): string { return `${Urls.prefix(secret)}/envs/${id}/move`; }
  static envEnable(secret: boolean): string { return `${Urls.prefix(secret)}/envs/enable`; }
  static envDisable(secret: boolean): string { return `${Urls.prefix(secret)}/envs/disable`; }

  static configFiles(secret: boolean): string { return `${Urls.prefix(secret)}/configs/files`; }
  static configContent(name: string, secret: boolean): string { return `${Urls.prefix(secret)}/configs/${name}`; }
  static configSave(secret: boolean): string { return `${Urls.prefix(secret)}/configs/save`; }

  static subscribes(secret: boolean): string { return `${Urls.prefix(secret)}/subscriptions`; }
  static subscribeRun(secret: boolean): string { return `${Urls.prefix(secret)}/subscriptions/run`; }
  static subscribeStop(secret: boolean): string { return `${Urls.prefix(secret)}/subscriptions/stop`; }
  static subscribeEnable(secret: boolean): string { return `${Urls.prefix(secret)}/subscriptions/enable`; }
  static subscribeDisable(secret: boolean): string { return `${Urls.prefix(secret)}/subscriptions/disable`; }

  static dependencies(secret: boolean): string { return `${Urls.prefix(secret)}/dependencies`; }
  static depForce(secret: boolean): string { return `${Urls.prefix(secret)}/dependencies/force`; }
  static depReinstall(secret: boolean): string { return `${Urls.prefix(secret)}/dependencies/reinstall`; }
  static depLog(id: string, secret: boolean): string { return `${Urls.prefix(secret)}/dependencies/${id}`; }

  static scripts(secret: boolean): string { return `${Urls.prefix(secret)}/scripts`; }
  static scriptFiles(secret: boolean): string { return `${Urls.prefix(secret)}/scripts/files`; }

  static logs(secret: boolean): string { return `${Urls.prefix(secret)}/logs`; }
  static loginLog(secret: boolean): string { return `${Urls.prefix(secret)}/user/login-log`; }
  static appKeys(secret: boolean): string { return `${Urls.prefix(secret)}/apps`; }
  static appKeyReset(id: string): string { return `/api/apps/${id}/reset-secret`; }
  static updateCheck(secret: boolean): string { return `${Urls.prefix(secret)}/system/update-check`; }
}
