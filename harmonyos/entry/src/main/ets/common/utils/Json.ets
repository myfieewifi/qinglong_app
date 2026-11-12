/**
 * JSON 安全取值工具。ArkTS 严格模式下不允许直接对 Object 取字段，
 * 统一通过这里做类型收窄与默认值兜底。
 */

export type JsonMap = Record<string, Object>;

export function asMap(v: Object | undefined | null): JsonMap {
  if (v && typeof v === 'object') {
    return v as JsonMap;
  }
  return {};
}

export function getString(map: JsonMap, key: string, def: string = ''): string {
  const v = map[key];
  if (v === undefined || v === null) {
    return def;
  }
  return v.toString();
}

export function getNumber(map: JsonMap, key: string, def: number = 0): number {
  const v = map[key];
  if (v === undefined || v === null) {
    return def;
  }
  if (typeof v === 'number') {
    return v as number;
  }
  const n = Number(v);
  return Number.isNaN(n) ? def : n;
}

export function getBool(map: JsonMap, key: string, def: boolean = false): boolean {
  const v = map[key];
  if (v === undefined || v === null) {
    return def;
  }
  if (typeof v === 'boolean') {
    return v as boolean;
  }
  return v.toString() === '1' || v.toString().toLowerCase() === 'true';
}

export function getArray(map: JsonMap, key: string): Object[] {
  const v = map[key];
  if (Array.isArray(v)) {
    return v as Object[];
  }
  return [];
}
