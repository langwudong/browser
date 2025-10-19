import { router } from '@kit.ArkUI';

@Entry
@Component
struct StartPage {
  // 在页面构建完成后启动定时器
  aboutToAppear() {
    // 默认 2 秒后跳转
    setTimeout(() => {
      router.replaceUrl({
        url: "pages/Index"
      }, router.RouterMode.Single, (err) => {
        if (err) {
          console.error(`跳转异常, 异常代码: ${err.code}, 异常信息: ${err.message}`);
        }
      });
    }, 2000);
  }

  build() {
    // 构建你的Logo页面UI
    Column() {
      Image($r('app.media.app_icon'))
        .width(100)
        .height(100)
      Text("小狐狸浏览器")
        .fontSize(20)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}