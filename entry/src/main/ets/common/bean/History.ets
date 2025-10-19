export default class History {
  // 主键
  id: number = 0

  // 网页标题
  title: string

  // 网页的 url
  url: string

  timestamp: string

  constructor(title: string, url: string, timestamp: string) {
    this.title = title
    this.url = url
    this.timestamp = timestamp
  }

  setId(id: number) {
    this.id = id
  }
}