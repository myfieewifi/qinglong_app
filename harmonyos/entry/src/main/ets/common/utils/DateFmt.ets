/** 时间格式化工具，对应原工程 date_format / timeago 的常用能力。 */

export function formatTime(ts: number): string {
  if (!ts || ts <= 0) {
    return '-';
  }
  const d = new Date(ts * (ts < 10000000000 ? 1000 : 1));
  const pad = (n: number): string => n < 10 ? `0${n}` : `${n}`;
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ` +
    `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

export function timeAgo(ts: number): string {
  if (!ts || ts <= 0) {
    return '-';
  }
  const now = Date.now();
  const sec = Math.floor((now - ts * 1000) / 1000);
  if (sec < 60) {
    return '刚刚';
  }
  if (sec < 3600) {
    return `${Math.floor(sec / 60)} 分钟前`;
  }
  if (sec < 86400) {
    return `${Math.floor(sec / 3600)} 小时前`;
  }
  return `${Math.floor(sec / 86400)} 天前`;
}
