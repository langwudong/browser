import History from '../common/bean/History'
import { HistoryGroup } from '../common/constants/CommonConstants'
import HistoryItem from './HistoryItem'

@CustomDialog
export default struct PagesDialog {
  @Consume("historyMap") historyMap: Map<string, History[]>
  @Consume("pagesDialogShowed") @Watch("onClicked") isClicked: boolean

  @State historyGroups: HistoryGroup[] = []

  dialogController: CustomDialogController

  async aboutToAppear() {
    await this.loadHistoryData()
  }

  async loadHistoryData() {
    try {
      this.historyGroups = []
      this.historyGroups = Array.from(this.historyMap.entries()).map((item) => ({
        date: item[0],
        histories: item[1]
      } as HistoryGroup))
      console.info("成功加载历史记录")
    } catch (error) {
      console.error('加载历史数据异常:', error)
    }
  }

  formatted(date: string) {
    const today = this.getFormattedDate(new Date())
    const yesterday = this.getFormattedDate(new Date(Date.now() - 24 * 60 * 60 * 1000))

    let displayText: string

    if (date === today) {
      displayText = "今天"
    } else if (date === yesterday) {
      displayText = "昨天"
    } else {
      // 格式化其他日期为年月日
      let dateParts = date.split("_")
      displayText = `${dateParts[0]}年${parseInt(dateParts[1])}月${parseInt(dateParts[2])}日`
    }

    return displayText
  }

  getFormattedDate(date: Date) {
    const year = date.getFullYear()
    // 月份从0开始，所以要 +1
    const month = date.getMonth() + 1
    const day = date.getDate()

    return `${year}_${month.toString().padStart(2, '0')}_${day.toString().padStart(2, '0')}`
  }

  onClicked() {
    this.dialogController.close()
  }

  @Builder ListGroupHeader(date: string) {
    Text(this.formatted(date))
      .fontSize(17)
      .fontColor("#45A5FF")
      .margin({ left: 20, top: 5, bottom: 5})
  }

  build() {
    Column() {
      Text("浏览记录")
        .fontSize(15)
        .margin({top: 20, bottom: 20})
      List() {
        ForEach(this.historyGroups, (group: HistoryGroup) => {
          ListItemGroup({header: this.ListGroupHeader(group.date)}) {
            ForEach(group.histories, (history: History) => {
              ListItem() {
                HistoryItem({ title: history.title, url: history.url })
              }
            })
          }
        })
      }
      // 合适的高度保证所有记录都能显示完整
      .height("90%")
      .width("100%")
      .backgroundColor("#00000000")
    }
    .width("100%")
    .height("100%")
  }
}