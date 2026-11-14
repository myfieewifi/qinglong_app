import promptAction from '@ohos.promptAction';

/** 轻提示，对应原工程 fluttertoast / toast()。 */
export function toast(message: string): void {
  promptAction.showToast({ message: message, duration: 2000 });
}
