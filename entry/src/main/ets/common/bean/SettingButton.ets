import SettingDialog from "../../view/SettingDialog"

@Component
export struct SettingButton {
  @State defaultImage: Resource = $r("app.media.gear_setting_settings_wheel_icon")

  @State isMenuOpen: boolean = false

  @State rotateAngle: number = 0

  dialogController: CustomDialogController = new CustomDialogController({
    builder: SettingDialog(),
    alignment: DialogAlignment.Bottom,
    offset: {dx: 0, dy: "-9%"}
  })

  build() {
    Button({type: ButtonType.Capsule}) {
      Column() {
        Image(this.defaultImage)
          .width(30)
          .height(30)
          .rotate({ z: 1, angle: this.rotateAngle })
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      }
    }
    .width(40)
    .height(40)
    .backgroundColor("#00FFFFFF")
    .animation({
      duration: 50,
    })
    .onClick(() => {
      if (this.dialogController) {
        this.dialogController.open()
      }
    })
  }
}
