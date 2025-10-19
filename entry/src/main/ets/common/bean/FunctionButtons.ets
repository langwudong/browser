import webview from '@ohos.web.webview';
import {ForwardButton} from "./ForwardButton";
import {BackButton} from "./BackButton"
import { SettingButton } from './SettingButton';
import { PagesButton } from './PagesButton';
import { PrivateButton } from './PrivateButton';

@Component
export struct FunctionButtons {
  // 绑定当前页面是否可回退
  // 绑定当前页面是否可前进
  @Link isBacked: boolean
  @Link isForward: boolean

  @Consume webviewController: webview.WebviewController

  build() {
    Row() {
      BackButton()
        .opacity(this.isBacked? 1 : 0.5)
        .enabled(this.isBacked)
        .onClick(() => {
          try {
            if (this.webviewController.accessBackward()) {
              this.webviewController.backward()
            }
          } catch (error) {
            // TODO: Implement error handling.
            console.log("页面后退发生错误：" + error)
          }
        })
      ForwardButton()
        .opacity(this.isForward? 1 : 0.5)
        .enabled(this.isForward)
        .onClick(() => {
          try {
            if (this.webviewController.accessForward()) {
              this.webviewController.forward()
            }
          } catch (error) {
            // TODO: Implement error handling.
            console.log("页面前进发生错误：" + error)
          }
        })
      PagesButton()
      PrivateButton()
      SettingButton()
    }
    .width("100%")
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceAround)
  }
}