import relationalStore from '@ohos.data.relationalStore'
import History from '../common/bean/History'

export default class RdbUtils {
  // 关系型数据库
  private static rdbStore: relationalStore.RdbStore

  static setStore(store: relationalStore.RdbStore) {
    RdbUtils.rdbStore = store
  }

  static getStore(): relationalStore.RdbStore {
    return RdbUtils.rdbStore
  }

  static async executeSql(sql: string) {
    return RdbUtils.getStore().executeSql(sql)
  }

  static async createDateTable() {
    const sql = `CREATE TABLE IF NOT EXISTS date_table (
      date TEXT PRIMARY KEY
    )`

    try {
      await RdbUtils.executeSql(sql)
    } catch (error) {
      // TODO: Implement error handling.
      console.error("执行 sql1 语句异常：" + error)
    }
  }

  static async createHistoryTable(tableName: string) {
    tableName = "history_" + tableName
    const sql = `CREATE TABLE IF NOT EXISTS ${tableName} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      url TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )`

    try {
      await RdbUtils.executeSql(sql)
    } catch (error) {
      // TODO: Implement error handling.
      console.error("执行 sql2 语句异常：" + error.code)
    }
  }

  static async insertDate(date: string) {
    const predicates = new relationalStore.RdbPredicates("date_table")

    predicates.equalTo("date", date);

    let resultSet: relationalStore.ResultSet

    try {
      resultSet = await RdbUtils.getStore().query(predicates, ["date"]);

      if (resultSet.rowCount <= 0) {
        const valueBucket: relationalStore.ValuesBucket = {
          "date": date
        }

        // 在日期表中插入当前日期
        RdbUtils.getStore().insert("date_table", valueBucket)
      }

      resultSet.close()
    } catch (error) {
      console.error("插入日期异常：" + error)
    }

    // 按天分表
    await RdbUtils.createHistoryTable(date)
  }

  static async insertHistory(tableName: string, history: History) {
    tableName = "history_" + tableName
    const valueBucket: relationalStore.ValuesBucket = {
      "title": history.title,
      "url": history.url,
      "timestamp": history.timestamp
    }
    return RdbUtils.getStore().insert(tableName, valueBucket)
  }

  static async queryAllDate() {
    const predicates = new relationalStore.RdbPredicates("date_table")

    let dateList: string[] = []

    let resultSet: relationalStore.ResultSet

    try {
      resultSet = await RdbUtils.getStore().query(predicates)

      console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`)

      while (resultSet.goToNextRow()) {
        dateList.unshift(resultSet.getString(resultSet.getColumnIndex("date")))
      }

      // 释放数据集的内存，若不释放可能会引起 fd 泄露与内存泄露
      resultSet.close()
    } catch (error) {
      console.error(`查询异常，失败代码： ${error.code}，失败信息： ${error.message}`);
    }

    return dateList
  }

  static async queryHistoriesByDate(date: string) {
    date = "history_" + date
    let predicates = new relationalStore.RdbPredicates(date);

    let histories: History[] = []

    RdbUtils.getStore().query(predicates, []).then(async (resultSet: relationalStore.ResultSet) => {
      console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`)

      try {
        while (resultSet.goToNextRow()) {
          const id = resultSet.getLong(resultSet.getColumnIndex("id"));
          const title = resultSet.getString(resultSet.getColumnIndex("title"));
          const url = resultSet.getString(resultSet.getColumnIndex("url"));
          const timestamp = resultSet.getString(resultSet.getColumnIndex("timestamp"));

          console.info(`查询到记录：id = ${id}, title = ${title}, url = ${url}, timestamp = ${timestamp}`)

          let history: History = new History(title, url, timestamp)
          history.setId(id)

          histories.unshift(history)
        }
      } catch (error) {
        console.error(`查询异常，失败代码： ${error.code}，失败信息： ${error.message}`);
      } finally {
        // 释放数据集的内存，若不释放可能会引起 fd 泄露与内存泄露
        resultSet.close()
      }
    })

    return histories
  }

  // 根据 id 删除对应数据表中的记录
  static async deleteById(date: string, id: number) {
    let predicates = new relationalStore.RdbPredicates(date);
    predicates.equalTo("id", id)
    return RdbUtils.getStore().delete(predicates);
  }

  static async deleteByDate(date: string) {
    let predicates = new relationalStore.RdbPredicates(date);
    return RdbUtils.getStore().delete(predicates);
  }

  static async deleteAll() {
    const dateList: string[] = await RdbUtils.queryAllDate()
    dateList.forEach((date: string) => {
      const sql = `DROP TABLE IF EXISTS ${date}`
      RdbUtils.executeSql(sql)
    })

    RdbUtils.executeSql(`DROP TABLE IF EXISTS date_table`)
  }
}