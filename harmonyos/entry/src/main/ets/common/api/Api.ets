import http from '@ohos.net.http';
import { HttpClient } from '../http/HttpClient';
import { Urls } from '../http/Urls';
import { AppStore } from '../store/AppStore';
import {
  HttpResponse, LoginBean, UserBean, SystemBean, TaskBean, EnvBean, ConfigBean,
  DependencyBean, ScriptNode, TaskLogNode, LoginLogBean, JsonMap, RawMap,
  asMap, parseList
} from '../model/Models';

type Parser<T> = (data: Object) => T;

function beanParser<T>(ctor: (m: JsonMap) => T): Parser<T> {
  return (data: Object): T => ctor(asMap(data));
}

function listParser<T>(ctor: (m: JsonMap) => T): Parser<T[]> {
  return (data: Object): T[] => {
    const arr = Array.isArray(data) ? data as Object[] : [];
    return arr.map((x: Object): T => ctor(asMap(x)));
  };
}

function stringParser(): Parser<string> {
  return (data: Object): string => data.toString();
}

function emptyParser(): Parser<boolean> {
  return (): boolean => true;
}

/** 接口封装，对应原工程 api.dart。 */
export class Api {
  private http: HttpClient = HttpClient.getInstance();

  private secret(): boolean {
    const cur = AppStore.getInstance().current;
    return cur ? cur.useSecret : false;
  }

  // ===== 账号 / 系统 =====

  login(host: string, username: string, password: string): Promise<HttpResponse<LoginBean>> {
    const body: Record<string, Object> = { 'username': username, 'password': password };
    return this.http.request<LoginBean>(http.RequestMethod.POST, Urls.LOGIN, {},
      body, beanParser(LoginBean.fromJson), host);
  }

  loginTwo(host: string, username: string, password: string, code: string):
    Promise<HttpResponse<LoginBean>> {
    const body: Record<string, Object> =
      { 'username': username, 'password': password, 'code': code };
    return this.http.request<LoginBean>(http.RequestMethod.PUT, Urls.LOGIN_TWO, {},
      body, beanParser(LoginBean.fromJson), host);
  }

  loginByClientId(host: string, clientId: string, secret: string):
    Promise<HttpResponse<LoginBean>> {
    const query: Record<string, string> =
      { 'client_id': clientId, 'client_secret': secret };
    return this.http.request<LoginBean>(http.RequestMethod.GET, Urls.LOGIN_BY_CLIENT,
      query, null, beanParser(LoginBean.fromJson), host);
  }

  user(): Promise<HttpResponse<UserBean>> {
    return this.http.get<UserBean>(Urls.USER, {}, beanParser(UserBean.fromJson));
  }

  system(): Promise<HttpResponse<SystemBean>> {
    return this.http.get<SystemBean>(Urls.SYSTEM, {}, beanParser(SystemBean.fromJson));
  }

  updatePassword(username: string, password: string): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'username': username, 'password': password };
    return this.http.put<boolean>(Urls.USER, body, emptyParser());
  }

  checkUpdate(): Promise<HttpResponse<RawMap>> {
    return this.http.get<RawMap>(Urls.updateCheck(this.secret()), {}, (d: Object) => asMap(d));
  }

  // ===== 定时任务 =====

  crons(): Promise<HttpResponse<TaskBean[]>> {
    const query: Record<string, string> = { 'searchValue': '' };
    return this.http.get<TaskBean[]>(Urls.crons(this.secret()),
      query, listParser(TaskBean.fromJson));
  }

  saveTask(payload: Record<string, Object>): Promise<HttpResponse<boolean>> {
    return this.http.post<boolean>(Urls.crons(this.secret()), payload, emptyParser());
  }

  deleteCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.del<boolean>(Urls.crons(this.secret()), body, emptyParser());
  }

  runCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.post<boolean>(Urls.cronRun(this.secret()), body, emptyParser());
  }

  stopCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.post<boolean>(Urls.cronStop(this.secret()), body, emptyParser());
  }

  pinCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.post<boolean>(Urls.cronPin(this.secret()), body, emptyParser());
  }

  unpinCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.post<boolean>(Urls.cronUnpin(this.secret()), body, emptyParser());
  }

  enableCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.post<boolean>(Urls.cronEnable(this.secret()), body, emptyParser());
  }

  disableCrons(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'crons': ids };
    return this.http.post<boolean>(Urls.cronDisable(this.secret()), body, emptyParser());
  }

  cronLog(id: string): Promise<HttpResponse<string>> {
    return this.http.get<string>(Urls.cronLog(id, this.secret()), {}, stringParser());
  }

  // ===== 环境变量 =====

  envs(search: string): Promise<HttpResponse<EnvBean[]>> {
    const query: Record<string, string> = { 'searchValue': search };
    return this.http.get<EnvBean[]>(Urls.envs(this.secret()), query,
      listParser(EnvBean.fromJson));
  }

  saveEnv(payload: Record<string, Object>): Promise<HttpResponse<boolean>> {
    return this.http.post<boolean>(Urls.envs(this.secret()), payload, emptyParser());
  }

  deleteEnvs(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'ids': ids };
    return this.http.del<boolean>(Urls.envs(this.secret()), body, emptyParser());
  }

  enableEnvs(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'ids': ids };
    return this.http.post<boolean>(Urls.envEnable(this.secret()), body, emptyParser());
  }

  disableEnvs(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'ids': ids };
    return this.http.post<boolean>(Urls.envDisable(this.secret()), body, emptyParser());
  }

  moveEnv(id: string, from: number, to: number): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'from': from, 'to': to };
    return this.http.put<boolean>(Urls.envMove(id, this.secret()), body, emptyParser());
  }

  // ===== 配置文件 =====

  configFiles(): Promise<HttpResponse<ConfigBean[]>> {
    return this.http.get<ConfigBean[]>(Urls.configFiles(this.secret()), {},
      listParser(ConfigBean.fromJson));
  }

  configContent(name: string): Promise<HttpResponse<string>> {
    return this.http.get<string>(Urls.configContent(name, this.secret()), {}, stringParser());
  }

  saveFile(name: string, content: string): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'name': name, 'content': content };
    return this.http.post<boolean>(Urls.configSave(this.secret()), body, emptyParser());
  }

  // ===== 订阅 =====

  subscribes(): Promise<HttpResponse<RawMap[]>> {
    return this.http.get<RawMap[]>(Urls.subscribes(this.secret()), {},
      (d: Object) => parseList(Array.isArray(d) ? d as Object[] : []));
  }

  saveSubscribe(payload: Record<string, Object>): Promise<HttpResponse<boolean>> {
    return this.http.post<boolean>(Urls.subscribes(this.secret()), payload, emptyParser());
  }

  deleteSubscribe(id: number): Promise<HttpResponse<boolean>> {
    return this.http.del<boolean>(`${Urls.subscribes(this.secret())}/${id}`, null, emptyParser());
  }

  runSubscribes(ids: number[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'ids': ids };
    return this.http.post<boolean>(Urls.subscribeRun(this.secret()), body, emptyParser());
  }

  stopSubscribes(ids: number[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'ids': ids };
    return this.http.post<boolean>(Urls.subscribeStop(this.secret()), body, emptyParser());
  }

  enableSubscribe(id: number): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'id': id };
    return this.http.post<boolean>(Urls.subscribeEnable(this.secret()), body, emptyParser());
  }

  disableSubscribe(id: number): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'id': id };
    return this.http.post<boolean>(Urls.subscribeDisable(this.secret()), body, emptyParser());
  }

  // ===== 依赖 =====

  dependencies(type: string): Promise<HttpResponse<DependencyBean[]>> {
    const query: Record<string, string> = { 'type': type };
    return this.http.get<DependencyBean[]>(Urls.dependencies(this.secret()), query,
      listParser(DependencyBean.fromJson));
  }

  addDependency(list: Record<string, Object>[]): Promise<HttpResponse<string>> {
    const body: Record<string, Object> = { 'list': list };
    return this.http.post<string>(Urls.dependencies(this.secret()), body, stringParser());
  }

  reinstallDependency(id: string): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'id': id };
    return this.http.post<boolean>(Urls.depReinstall(this.secret()), body, emptyParser());
  }

  dependencyLog(id: string): Promise<HttpResponse<string>> {
    return this.http.get<string>(Urls.depLog(id, this.secret()), {}, stringParser());
  }

  deleteDependencies(sIds: string[], ids: number[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'sIds': sIds, 'ids': ids };
    return this.http.del<boolean>(Urls.dependencies(this.secret()), body, emptyParser());
  }

  // ===== 脚本 =====

  scripts(): Promise<HttpResponse<ScriptNode[]>> {
    return this.http.get<ScriptNode[]>(Urls.scriptFiles(this.secret()), {},
      listParser(ScriptNode.fromJson));
  }

  scriptDetail(name: string, path: string): Promise<HttpResponse<string>> {
    const p = path ? `${path}/${name}` : name;
    return this.http.get<string>(`${Urls.scripts(this.secret())}/${encodeURIComponent(p)}`,
      {}, stringParser());
  }

  saveScript(name: string, path: string, content: string): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'name': name, 'path': path, 'content': content };
    return this.http.post<boolean>(Urls.scripts(this.secret()), body, emptyParser());
  }

  deleteScript(name: string, path: string): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'name': name, 'path': path };
    return this.http.del<boolean>(Urls.scripts(this.secret()), body, emptyParser());
  }

  addScriptFolder(name: string, path: string): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'name': name, 'path': path, 'isFolder': true };
    return this.http.post<boolean>(Urls.scripts(this.secret()), body, emptyParser());
  }

  // ===== 日志 =====

  taskLogs(): Promise<HttpResponse<TaskLogNode[]>> {
    return this.http.get<TaskLogNode[]>(Urls.logs(this.secret()), {},
      listParser(TaskLogNode.fromJson));
  }

  taskLogDetail(name: string, path: string): Promise<HttpResponse<string>> {
    return this.http.get<string>(`${Urls.logs(this.secret())}/${encodeURIComponent(path)}/${encodeURIComponent(name)}`,
      {}, stringParser());
  }

  loginLogs(): Promise<HttpResponse<LoginLogBean[]>> {
    return this.http.get<LoginLogBean[]>(Urls.loginLog(this.secret()), {},
      listParser(LoginLogBean.fromJson));
  }

  // ===== AppKey =====

  appKeys(): Promise<HttpResponse<RawMap[]>> {
    return this.http.get<RawMap[]>(Urls.appKeys(this.secret()), {},
      (d: Object) => parseList(Array.isArray(d) ? d as Object[] : []));
  }

  saveAppKey(payload: Record<string, Object>): Promise<HttpResponse<boolean>> {
    return this.http.post<boolean>(Urls.appKeys(this.secret()), payload, emptyParser());
  }

  deleteAppKeys(ids: string[]): Promise<HttpResponse<boolean>> {
    const body: Record<string, Object> = { 'ids': ids };
    return this.http.del<boolean>(Urls.appKeys(this.secret()), body, emptyParser());
  }

  resetAppKey(id: string): Promise<HttpResponse<boolean>> {
    return this.http.post<boolean>(Urls.appKeyReset(id), {}, emptyParser());
  }
}
