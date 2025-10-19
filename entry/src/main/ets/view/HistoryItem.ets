import webview from '@ohos.web.webview'
@Component
export default struct HistoryItem {
  @State title: string = ""
  @State url: string = ""
  @State translateX: number = 0
  @State deleteIcon: Resource = $r("app.media.trash_icon")
  @State showDeleteIcon: boolean = false

  @Consume("pagesDialogShowed") isClicked: boolean
  @Consume("webIsSearched") isSearched: boolean
  @Consume webviewController: webview.WebviewController

  build() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Column() {
          Text(this.title === ""? this.url : this.title)
            .width("100%")
            .margin({ top: 5 })
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          Text(this.url)
            .width("100%")
            .margin({ top: 5 })
            .fontSize(10)
            .textAlign(TextAlign.Start)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
        }
        .padding({ left: 15, right: 15 })
        .margin({ bottom: 5 })
      }
      .margin({ left: 15, right: 15, bottom: 2 })
      .borderRadius("40px")
      .backgroundColor(Color.White)
      .shadow({ radius: 5, color: Color.Gray })
      .onClick(() => {
        this.isClicked = ! this.isClicked
        this.isSearched = true
        this.webviewController.loadUrl(this.url)
      })

      // 删除按钮
      Button({ type: ButtonType.Circle }) {
        Image(this.deleteIcon)
          .width(30)
          .height(30)
      }
      .height(30)
      .width(30)
      .onClick(() => {
        // 这里处理删除逻辑
        console.log('删除项目:', this.title)
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .offset({ x: this.translateX })
    .gesture(
      SwipeGesture({
        direction: SwipeDirection.Horizontal,
      })
      .onAction((event: GestureEvent) => {
        if (event.offsetX < 0) {
          // 向左滑动显示删除按钮
          this.translateX = -80
          this.showDeleteIcon = true
        } else if (event.offsetX > 0) {
          // 向右滑动隐藏删除按钮
          this.translateX = 0
          this.showDeleteIcon = false
        }
      })
    )
  }
}