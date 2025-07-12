import webview from '@ohos.web.webview'
import CommonConstants from "../common/constants/CommonConstants"
import { FunctionButtons } from '../view/FunctionButtons'
import History from '../common/bean/History'
import window from '@ohos.window'
import PreferenceModel from '../model/PreferenceModel'
import { inputMethod } from '@kit.IMEKit'

PersistentStorage.PersistProp("privateMode", "false")
PersistentStorage.PersistProp("currentEngineIndex", 0)
PersistentStorage.PersistProp("currentEngineName", "Bing")
PersistentStorage.PersistProp("darkMode", "false")

@Entry
@Component
struct Index {
  // 绑定搜索框内显示的url地址
  @State url: string = ""
  // 绑定 Web 组件的显示状态,默认为隐藏
  @State isShowed: Visibility = Visibility.None

  @State high: string = "10%"
  // 绑定搜索框内的文本对齐方式,默认为左对齐
  @State textAlign: TextAlign = TextAlign.Start
  // 绑定搜索框是否聚焦
  // @State isInputFocused: boolean = false
  // 绑定键盘高度
  @State keyboardHeight: number = 0
  // 绑定是否显示遮罩层
  @State isShowMask: boolean = false
  // 绑定当前页面加载进度
  @State currentProgress: number = 0
  // 绑定当前页面是否可回退
  @State isBacked: boolean = false
  // 绑定当前页面是否可前进
  @State isForwarded: boolean = false

  // 历史浏览记录
  @Provide("histories") histories: Array<History> = []

  @Provide webviewController: webview.WebviewController = new webview.WebviewController()
  // 是否进行过搜索，用于判断是否显示 Web 组件
  @Provide("webIsSearched") @Watch("onSearched") isSearched: boolean = false

  // 从 AppStore 中获取持久化数据
  // privateMode 表示当前是否为隐私模式
  @StorageLink("privateMode") privateMode: string = "false"
  // darkMode 表示当前是否为夜间模式
  @StorageLink("darkMode") darkMode: string = "false"
  // currentEngineIndex 表示当前的搜索引擎的索引
  @StorageLink("currentEngineIndex") searchEngine: number = 0

  // private browsingHistory: BrowsingHistory = new BrowsingHistory(() => {})
  private windowClass: window.Window | null = null

  // 获取输入法实例
  private inputMethodController: inputMethod.InputMethodController = inputMethod.getController()

  async aboutToAppear() {
    await PreferenceModel.getPreferencesFromStorage();
    PreferenceModel.getHistories().then(histories => {
      if (histories !== null) {
        this.histories = histories
      }
    })

    // 开启软键盘高度变化的监听
    window.getLastWindow(getContext(this), (err, data) => {
      if (err) {
        console.log(err.message)
      }
      this.windowClass = data
      this.windowClass.on("keyboardHeightChange", (data) => {
        this.keyboardHeight = data
        console.log(this.keyboardHeight.toString())
      })
    })
  }

  // 保存浏览记录
  onSaveHistory() {
    let history = new History(this.webviewController.getTitle(), this.webviewController.getUrl())

    this.histories.push(history)

    PreferenceModel.writeHistories(this.histories)
  }

  // 判断用户输入的内容是否为网址
  private checkContent(content: string) {
    if (content.endsWith(".com") || content.endsWith(".cn") || content.endsWith(".tv")) {
      return true
    } else {
      return false
    }
  }

  onSearched() {
    this.isShowed = Visibility.Visible
    this.high = "91%"
    this.textAlign = TextAlign.Center
  }

  build() {
    Flex({ direction: FlexDirection.Column , alignItems: ItemAlign.Center}) {
      Column() {
        Column() {
          if (!this.isSearched) {
            // logo 显示
            Row() {
              Image($r("app.media.app_icon"))
                .width(30)
                .height(30)
                .margin({ bottom: 25, right: 10 })
              Text(CommonConstants.APP_NAME)
                .fontSize(25)
                .fontColor(this.darkMode === "false"? Color.Black : Color.White)
                .margin({ bottom: 25 })
                .animation({
                  duration: 300
                })
            }
            .width("100%")
            .height("100%")
            .justifyContent(FlexAlign.Center)
          }
          // 网页内容区域
          Web({ src: this.url, controller: this.webviewController })
            .width("100%")
            .height("100%")
            .visibility(this.isShowed)
            .animation({
              duration: 300
            })
            .onProgressChange((event) => {
              this.currentProgress = event.newProgress
            })
            .onRefreshAccessedHistory((event) => {
              if (!event.isRefreshed && !this.privateMode) {
                this.onSaveHistory()
              }
              this.isBacked = this.webviewController.accessBackward()
              this.isForwarded = this.webviewController.accessForward()
            })
        }
        .width("100%")
        .height(this.high)
        .justifyContent(FlexAlign.Center)
        .animation({
          duration: 300
        })

        Stack({ alignContent: Alignment.Bottom }) {
          // 地址栏
          Search({ placeholder: "搜索或输入网址", value: this.url })
            .width("90%")
            .height("8%")
            .size({ height: 50 })
            .margin({ top: 5, bottom: 10, left: 5, right: 5})
            .textAlign(this.textAlign)
            .backgroundColor(this.darkMode === "false"? "#E8E8E8" : "#696969")
            .zIndex(3)
            .animation({
              duration: 300
            })
            .onClick(() => {
              // 唤起软键盘
              this.inputMethodController.showSoftKeyboard()
            })
            // 输入状态变化时
            .onEditChange((isEditing: boolean) => {
              // this.isInputFocused = isEditing;
              this.isShowMask = isEditing;
            })
            // 提交搜索时
            .onSubmit((value) => {
              if (this.checkContent(value)) {
                this.webviewController.loadUrl(value)
              } else {
                this.webviewController.loadUrl(CommonConstants.SEARCH_ENGINES[this.searchEngine].prefix + value)
              }

              this.url = this.webviewController.getOriginalUrl()

              //更改搜索框的搜索状态
              if (!this.isSearched) {
                this.isSearched = true
              }

              // 收起软键盘
              this.inputMethodController.stopInputSession()

              this.onSaveHistory()
            })
          // 网页加载进度条
          Progress({ value: this.currentProgress, type: ProgressType.Linear })
            .visibility(this.currentProgress === 100 || this.currentProgress === 0 ? Visibility.None : Visibility.Visible)
            .animation({
              duration: 100
            })
        }
      }
      .width("100%")
      .layoutWeight(11)
      .justifyContent(FlexAlign.Center)
      // 底部按钮
      FunctionButtons({ isBacked: $isBacked, isForward: $isForwarded })
        .width("100%")
        .margin({ top: 5 })
        .layoutWeight(1)
      // 遮罩层
      if (this.isShowMask) {
        Column()
          .width("100%")
          .height("100%")
          .position({ x: 0, y: 0 })
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(() => {
            // 点击外部区域时收起软键盘
            this.isShowMask = false;
            // 收起软键盘
            this.inputMethodController.stopInputSession()
          })
          .zIndex(2)
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor(this.darkMode === "false"? Color.White : "#1C1C1C")
    .animation({
      duration: 300
    })
  }
}