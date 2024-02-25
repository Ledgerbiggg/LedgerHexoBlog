---
title: influxdb-client-go/v2客户端连接influxdb
tags:
  - go每日一库
  - influxdb-client-go/v2
---

## 简介

- InfluxDB是一个开源的时序数据库，主要用于处理时间序列数据。它被设计用来处理大规模的时间序列数据，如应用程序指标、系统监控、传感器数据等。InfluxDB具有高度优化的存储结构和查询引擎，使其能够高效地存储和查询时间序列数据。

## 快速使用

1. 安装

```shell
go get "github.com/influxdata/influxdb-client-go/v2"
```

1. 创建

```go
func init() {
	Client = influxdb2.NewClient("http://xxx:8086", "xxx")
}
```

1. 随机插入数据一些

```go
func TestConn2(t *testing.T) {
	// 创建用于写入数据的WriteAPI
	writeAPI := Client.WriteAPIBlocking("ledger", "test")
	// 创建一个包含"cpu"测量和一些标签的新数据点
	for i := 0; i < 200; i++ {
		p := influxdb2.NewPointWithMeasurement("cpu10003").
			AddTag("host", "server01").
			AddTag("region", "us").
			AddField("value", rand.Intn(100)+1).
			SetTime(time.Now().Add(-time.Duration(i) * time.Minute))
		// 异步写入数据点
		err := writeAPI.WritePoint(context.Background(), p)
		if err != nil {
			fmt.Printf("写入数据时发生错误: %s\n", err.Error())
			return
		}
	}
}
```

1. 简单查看一下

![img](https://img2.imgtp.com/2024/02/25/o2munnxa.png)

1. 查询语法

from: 指定数据源，通常是一个桶（bucket）。

range: 定义查询的时间范围。

filter: 过滤数据，类似于 SQL 中的 WHERE 子句。

group: 对数据进行分组，可以按标签、时间等进行分组。

aggregateWindow: 在时间窗口内对数据进行聚合。

pivot: 透视操作，将表格数据重新排列。

map: 对数据进行转换或添加新的列。

sort: 对数据进行排序。

limit: 限制返回的结果数量。

keep: 选择要保留的列。

yield: 生成结果集。

1. 举例

```sql
from(bucket: "test")
    // 时间过滤
    |> range(start: -1d)
    // 筛选数据（测量条件，tag条件）
    |> filter(fn: (r) => r["_measurement"] == "cpu10003" and r["host"] == "server01" and r["region"] == "us")
    // 窗口函数（求和）
    |> aggregateWindow(every: 1h, fn: sum, createEmpty: false)
    // 重新排列数据的列
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    // _time时间排序
    |> sort(columns:["_time"], desc: true)
    // 取一个
    |> top(n: 1)
    // 过滤列
    |> keep(columns: ["_time", "host", "region", "value"])
    // 执行
    |> yield(name: "test_search")
```

![img](https://img2.imgtp.com/2024/02/25/yAqpSSSU.png)

1. 使用api

```go
func TestQ(t *testing.T) {
	queryAPI := Client.QueryAPI("ledger")
	fromString := "from(bucket: \"test\")"
	rangeString := "|> range(start: -1d)"
	filter := "|> filter(fn: (r) => r[\"_measurement\"] == \"cpu10003\" and r[\"host\"] == \"server01\" and r[\"region\"] == \"us\")"
	aggregateWindow := "|> aggregateWindow(every: 1h, fn: sum, createEmpty: false)"
	pivot := "|> pivot(rowKey: [\"_time\"], columnKey: [\"_field\"], valueColumn: \"_value\")"
	sort := "|> sort(columns: [\"_time\"], desc: true)"
	top := "|> top(n: 1)"
	keep := "|> keep(columns: [\"_time\", \"host\", \"region\", \"value\"])"
	yield := "|> yield(name: \"test_search\")"
	query := fromString + rangeString + filter + aggregateWindow + pivot + sort + top + keep + yield
	result, err := queryAPI.Query(context.Background(), query)
	if err != nil {
		fmt.Printf("查询数据时发生错误: %s\n", err.Error())
		return
	}
	for result.Next() {
		fmt.Println("=============", result.Record().Time(), result.Record().ValueByKey("value"))
	}
	if result.Err() != nil {
		fmt.Printf("处理查询结果时发生错误: %s\n", result.Err().Error())
		return
	}
}
```

![img](https://img2.imgtp.com/2024/02/25/9CbykIPZ.png)


