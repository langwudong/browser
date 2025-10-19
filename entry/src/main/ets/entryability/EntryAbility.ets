import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { relationalStore } from '@kit.ArkData';
import CommonConstants from '../common/constants/CommonConstants'
import RdbUtils from '../utils/RdbUtils';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    relationalStore.getRdbStore(this.context, CommonConstants.STORE_CONFIG, async (err, store) => {
      if (err) {
        console.error(`获取 RdbStore异常. 异常代码:${err.code}, 异常信息:${err.message}`);
        return;
      }
      console.info(`成功获取 RdbStore.`);

      //保存store, 方便后面我们对数据库的操作
      RdbUtils.setStore(store)

      await RdbUtils.createDateTable()

      // 在数据库初始化完成后加载页面
      windowStage.loadContent("pages/Start", (err) => {
        if (err.code) {
          console.error(`Failed to load the content. Code:${err.code},message:${err.message}`);
          return
        }
      })
    })
  }
}