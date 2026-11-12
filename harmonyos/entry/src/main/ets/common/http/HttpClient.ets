import http from '@ohos.net.http';
import { HttpResponse, JsonMap, asMap } from '../model/Models';
import { Urls } from './Urls';
import { AppStore, AccountInfo } from '../store/AppStore';
import { Logger } from '../utils/Logger';

type Method = http.RequestMethod;

const UA: string = 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) ' +
  'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1';

/**
 * 网络封装，对应原工程 http.dart + token_interceptor.dart。
 * 基于 @ohos.net.http，每次请求实时读取当前账号，支持多账号切换。
 */
export class HttpClient {
  private static instance: HttpClient | null = null;
  private onUnauthorized: (() => void) | null = null;

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  setUnauthorizedHandler(handler: () => void): void {
    this.onUnauthorized = handler;
  }

  private current(): AccountInfo | null {
    return AppStore.getInstance().current;
  }

  private buildUrl(host: string, path: string, query: Record<string, string>): string {
    const base = host.endsWith('/') ? host.slice(0, host.length - 1) : host;
    let url = base + path;
    const keys = Object.keys(query);
    if (keys.length > 0) {
      const qs = keys.map(k => `${encodeURIComponent(k)}=${encodeURIComponent(query[k])}`).join('&');
      url += (url.includes('?') ? '&' : '?') + qs;
    }
    return url;
  }

  async request<T>(method: Method, path: string, query: Record<string, string>,
    body: Object | null, parse: (data: Object) => T, overrideHost?: string,
    overrideToken?: string): Promise<HttpResponse<T>> {
    const store = AppStore.getInstance();
    const account = store.current;
    const host = overrideHost !== undefined ? overrideHost : (account ? account.host : '');
    const token = overrideToken !== undefined ? overrideToken : (account ? account.token : '');
    if (host.length === 0) {
      return new HttpResponse<T>(false, 401, '未登录', null);
    }

    const headers: Record<string, string> = {
      'User-Agent': UA,
      'Content-Type': 'application/json;charset=UTF-8'
    };
    const finalQuery: Record<string, string> = { ...query };

    if (!Urls.inWhiteList(path)) {
      finalQuery['t'] = `${Math.floor(Date.now() / 1000)}`;
      if (token.length > 0) {
        headers['Authorization'] = 'Bearer ' + token;
      }
    }

    const url = this.buildUrl(host, path, finalQuery);
    const req = http.createHttp();
    Logger.d(`${method} ${url}`);

    try {
      const resp = await req.request(url, {
        method: method,
        header: headers,
        extraData: body === null ? undefined : JSON.stringify(body),
        connectTimeout: 50000,
        readTimeout: 50000,
        expectDataType: http.HttpDataType.STRING
      });

      if (resp.responseStatusCode === 401 && !Urls.inWhiteList(path)) {
        if (this.onUnauthorized) {
          this.onUnauthorized();
        }
        return new HttpResponse<T>(false, 401, '身份已过期，请重新登录', null);
      }

      let result: Object = resp.result as Object;
      if (typeof result === 'string') {
        const text = result as string;
        if (text.length === 0) {
          return new HttpResponse<T>(true, resp.responseStatusCode, '', null);
        }
        result = JSON.parse(text) as Object;
      }

      if (resp.responseStatusCode === 200) {
        const root: JsonMap = asMap(result);
        const code = Number(root['code'] ?? 200);
        if (code === 200) {
          const data = root['data'];
          if (data === undefined || data === null) {
            return new HttpResponse<T>(true, 200, '', null);
          }
          return new HttpResponse<T>(true, 200, '', parse(data));
        }
        const msg = root['message'] ? root['message'].toString() : '请求失败';
        return new HttpResponse<T>(false, code, msg, null);
      }

      const root2: JsonMap = asMap(result);
      const msg2 = root2['message'] ? root2['message'].toString() : `HTTP ${resp.responseStatusCode}`;
      return new HttpResponse<T>(false, resp.responseStatusCode, msg2, null);
    } catch (e) {
      Logger.e('request error: ' + (e as Error).message);
      return new HttpResponse<T>(false, 400, (e as Error).message, null);
    } finally {
      req.destroy();
    }
  }

  get<T>(path: string, query: Record<string, string>, parse: (data: Object) => T):
    Promise<HttpResponse<T>> {
    return this.request<T>(http.RequestMethod.GET, path, query, null, parse);
  }

  post<T>(path: string, body: Object | null, parse: (data: Object) => T):
    Promise<HttpResponse<T>> {
    return this.request<T>(http.RequestMethod.POST, path, {}, body, parse);
  }

  put<T>(path: string, body: Object | null, parse: (data: Object) => T):
    Promise<HttpResponse<T>> {
    return this.request<T>(http.RequestMethod.PUT, path, {}, body, parse);
  }

  del<T>(path: string, body: Object | null, parse: (data: Object) => T):
    Promise<HttpResponse<T>> {
    return this.request<T>(http.RequestMethod.DELETE, path, {}, body, parse);
  }
}
