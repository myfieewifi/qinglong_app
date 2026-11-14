import { JsonMap, asMap, getString, getNumber, getBool, getArray } from '../utils/Json';

/** 统一响应包装，对应原工程 HttpResponse<T>。 */
export class HttpResponse<T> {
  success: boolean = false;
  code: number = 0;
  message: string = '';
  data: T | null = null;

  constructor(success: boolean, code: number, message: string, data: T | null) {
    this.success = success;
    this.code = code;
    this.message = message;
    this.data = data;
  }
}

/** 登录返回。 */
export class LoginBean {
  token: string = '';
  lastip: string = '';
  lastaddr: string = '';
  lastlogon: number = 0;
  retries: number = 0;
  platform: string = '';
  twoFactorActivated: boolean = false;

  static fromJson(m: JsonMap): LoginBean {
    const b = new LoginBean();
    b.token = getString(m, 'token');
    b.lastip = getString(m, 'lastip');
    b.lastaddr = getString(m, 'lastaddr');
    b.lastlogon = getNumber(m, 'lastlogon');
    b.retries = getNumber(m, 'retries');
    b.platform = getString(m, 'platform');
    b.twoFactorActivated = getBool(m, 'twoFactorActivated');
    return b;
  }
}

/** 当前用户信息。 */
export class UserBean {
  username: string = '';
  twoFactorActivated: boolean = false;
  avatar: string = '';

  static fromJson(m: JsonMap): UserBean {
    const b = new UserBean();
    b.username = getString(m, 'username');
    b.twoFactorActivated = getBool(m, 'twoFactorActivated');
    b.avatar = getString(m, 'avatar');
    return b;
  }
}

/** 面板系统信息。 */
export class SystemBean {
  version: string = '';

  static fromJson(m: JsonMap): SystemBean {
    const b = new SystemBean();
    b.version = getString(m, 'version');
    return b;
  }
}

/** 定时任务。 */
export class TaskBean {
  id: number = 0;
  sId: string = '';
  name: string = '';
  command: string = '';
  schedule: string = '';
  status: number = 0;
  isDisabled: number = 0;
  isPinned: number = 0;
  lastExecutionTime: number = 0;
  lastRunningTime: number = 0;
  pid: string = '';
  logPath: string = '';
  createdAt: string = '';
  updatedAt: string = '';
  remarks: string = '';
  statusText: string = '';

  static fromJson(m: JsonMap): TaskBean {
    const b = new TaskBean();
    b.id = getNumber(m, 'id');
    b.sId = getString(m, '_id') || getString(m, 'sId');
    b.name = getString(m, 'name');
    b.command = getString(m, 'command');
    b.schedule = getString(m, 'schedule');
    b.status = getNumber(m, 'status');
    b.isDisabled = getNumber(m, 'isDisabled');
    b.isPinned = getNumber(m, 'isPinned');
    b.lastExecutionTime = getNumber(m, 'lastExecutionTime');
    b.lastRunningTime = getNumber(m, 'lastRunningTime');
    b.pid = getString(m, 'pid');
    b.logPath = getString(m, 'logPath');
    b.createdAt = getString(m, 'createdAt');
    b.updatedAt = getString(m, 'updatedAt');
    b.remarks = getString(m, 'remarks');
    return b;
  }

  get running(): boolean {
    return this.status === 0;
  }

  get disabled(): boolean {
    return this.isDisabled === 1;
  }
}

/** 环境变量。 */
export class EnvBean {
  id: number = 0;
  sId: string = '';
  name: string = '';
  value: string = '';
  remarks: string = '';
  status: number = 0;
  createdAt: string = '';
  updatedAt: string = '';

  static fromJson(m: JsonMap): EnvBean {
    const b = new EnvBean();
    b.id = getNumber(m, 'id');
    b.sId = getString(m, '_id') || getString(m, 'sId');
    b.name = getString(m, 'name');
    b.value = getString(m, 'value');
    b.remarks = getString(m, 'remarks');
    b.status = getNumber(m, 'status');
    b.createdAt = getString(m, 'createdAt');
    b.updatedAt = getString(m, 'updatedAt');
    return b;
  }

  get disabled(): boolean {
    return this.status === 1;
  }
}

/** 配置文件项。 */
export class ConfigBean {
  title: string = '';
  value: string = '';

  static fromJson(m: JsonMap): ConfigBean {
    const b = new ConfigBean();
    b.title = getString(m, 'title');
    b.value = getString(m, 'value');
    return b;
  }
}

/** 依赖。 */
export class DependencyBean {
  sId: string = '';
  id: number = 0;
  created: number = 0;
  createdAt: string = '';
  status: number = 0;
  type: number = 0;
  name: string = '';
  remark: string = '';
  log: string[] = [];

  static fromJson(m: JsonMap): DependencyBean {
    const b = new DependencyBean();
    b.sId = getString(m, '_id') || getString(m, 'sId');
    b.id = getNumber(m, 'id');
    b.created = getNumber(m, 'created');
    b.createdAt = getString(m, 'createdAt');
    b.status = getNumber(m, 'status');
    b.type = getNumber(m, 'type');
    b.name = getString(m, 'name');
    b.remark = getString(m, 'remark');
    b.log = getArray(m, 'log').map((x: Object): string => x.toString());
    return b;
  }
}

/** 脚本/文件树节点。 */
export class ScriptNode {
  title: string = '';
  value: string = '';
  parent: string = '';
  disabled: boolean = false;
  children: ScriptNode[] = [];

  static fromJson(m: JsonMap): ScriptNode {
    const b = new ScriptNode();
    b.title = getString(m, 'title');
    b.value = getString(m, 'value');
    b.parent = getString(m, 'parent');
    b.disabled = getBool(m, 'disabled');
    b.children = getArray(m, 'children').map((c: Object): ScriptNode =>
      ScriptNode.fromJson(asMap(c)));
    return b;
  }
}

/** 日志文件树节点。 */
export class TaskLogNode {
  name: string = '';
  title: string = '';
  value: string = '';
  type: string = '';
  key: string = '';
  parent: string = '';
  isDir: boolean = false;
  files: string[] = [];
  children: TaskLogNode[] = [];

  static fromJson(m: JsonMap): TaskLogNode {
    const b = new TaskLogNode();
    b.name = getString(m, 'name');
    b.title = getString(m, 'title');
    b.value = getString(m, 'value');
    b.type = getString(m, 'type');
    b.key = getString(m, 'key');
    b.parent = getString(m, 'parent');
    b.isDir = getBool(m, 'isDir');
    b.files = getArray(m, 'files').map((x: Object): string => x.toString());
    b.children = getArray(m, 'children').map((c: Object): TaskLogNode =>
      TaskLogNode.fromJson(asMap(c)));
    return b;
  }
}

/** 登录日志。 */
export class LoginLogBean {
  timestamp: number = 0;
  address: string = '';
  ip: string = '';
  platform: string = '';
  status: number = 0;

  static fromJson(m: JsonMap): LoginLogBean {
    const b = new LoginLogBean();
    b.timestamp = getNumber(m, 'timestamp');
    b.address = getString(m, 'address');
    b.ip = getString(m, 'ip');
    b.platform = getString(m, 'platform');
    b.status = getNumber(m, 'status');
    return b;
  }
}

/** 订阅 / AppKey 源码侧为动态 Map，鸿蒙侧保留宽松结构。 */
export type RawMap = Record<string, Object>;

export function parseList(arr: Object[]): RawMap[] {
  return arr.map((x: Object): RawMap => asMap(x));
}

export { asMap, getString, getNumber, getBool, getArray } from '../utils/Json';
export type { JsonMap } from '../utils/Json';
