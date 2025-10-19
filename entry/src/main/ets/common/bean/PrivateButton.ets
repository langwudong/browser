import { Prompt } from '@kit.ArkUI'

@Component
export struct PrivateButton {
  // defaultImage 用于表示默认的图标
  @State defaultImage: Resource = $r("app.media.eye_slash_fill_icon")
  // activedImage 用于表示点击后的图标
  @State activedImage: Resource = $r("app.media.eye_fill_icon")

  //从AppStore中获取持久化数据
  @StorageLink("privateMode") privateMode: boolean = false

  private message: string[] = ["无痕浏览已打开", "无痕浏览已关闭"]

  build() {
    Button({type: ButtonType.Circle}) {
      Image(!this.privateMode? this.defaultImage : this.activedImage)
        .width(30)
        .height(30)
    }
    .width(40)
    .height(40)
    .backgroundColor("#00FFFFFF")
    .onClick(() => {
      if (!this.privateMode) {
        this.privateMode = true
      } else {
        this.privateMode = false
      }
      Prompt.showToast({
        message: this.privateMode? this.message[0] : this.message[1]
      })
    })
  }
}