/** 轻量日志封装，对应原工程 logger。 */
const TAG: string = 'QingLong';

export class Logger {
  static d(msg: string): void {
    console.info(`[${TAG}] ${msg}`);
  }

  static e(msg: string): void {
    console.error(`[${TAG}] ${msg}`);
  }

  static w(msg: string): void {
    console.warn(`[${TAG}] ${msg}`);
  }
}
