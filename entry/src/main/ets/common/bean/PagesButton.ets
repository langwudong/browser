import pagesDialog from "../../view/PagesDialog"

@Component
export struct PagesButton {
  // 绑定默认的图标
  @State defaultImage: Resource = $r("app.media.clone_regular")
  // 绑定点击后的图标
  @State activedImage: Resource = $r("app.media.clone_solid")

  // 默认比例
  private defaultScale: ScaleOptions = {x: 1, y: 1}
  // 点击后的比例
  private activedScale: ScaleOptions = {x: 1.2, y: 1.2}

  // 绑定默认比例，默认为原比例
  @State currentScale: ScaleOptions = this.defaultScale

  // 绑定当前自定义弹窗是否显示，默认为隐藏
  @Provide("pagesDialogShowed") isShowDialog: boolean = false

  dialogController: CustomDialogController = new CustomDialogController({
    builder: pagesDialog(),
    cancel: () => {
      this.closePagesDialog()
    }
  })

  // 当自定义弹窗隐藏后执行
  private closePagesDialog() {
    this.currentScale = { x: 1, y: 1}
    this.isShowDialog = false
  }

  build() {
    Button({type: ButtonType.Circle, stateEffect: false}) {
      Column() {
        Image(this.isShowDialog? this.activedImage : this.defaultImage)
          .width(30)
          .height(30)
      }
    }
    .width(40)
    .height(40)
    .scale(this.currentScale)
    .backgroundColor("#00FFFFFF")
    .onClick(() => {
      this.isShowDialog = !this.isShowDialog
      if (this.isShowDialog) {
        this.currentScale = this.activedScale
        if (this.dialogController){
          this.dialogController.open()
        }
      } else {
        this.currentScale = this.defaultScale
        if (this.dialogController) {
          this.dialogController.close()
        }
      }
    })
    .animation({
      duration: 50
    })
  }
}