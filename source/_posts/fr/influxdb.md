---
title: influxdb数据库
tags:
  - influxdb
  - 数据库
---
### 概念

1. **时间序列数据库：** InfluxDB专注于存储和查询时间序列数据，这使得它非常适合处理按时间排序的数据流，如传感器数据、日志事件等。
2. **标签和字段：** InfluxDB使用标签（tags）和字段（fields）来组织和查询数据。标签是用于标识和过滤数据的键值对，而字段包含实际的数值数据。
3. **测量（Measurements）：** 数据在InfluxDB中被组织成测量，每个测量包含一组相关的数据点。一个数据点由时间戳、标签和字段组成。
4. **保留策略（Retention Policies）：** InfluxDB允许你为数据指定保留策略，定义数据在数据库中的保存时间。这对于自动删除旧数据以释放空间很有用。
5. **查询语言：** InfluxDB使用类似SQL的查询语言（InfluxQL）来进行数据查询和分析。你可以执行范围查询、聚合和过滤以提取所需的信息。
6. **连续查询（Continuous Queries）：** 允许你在数据库中预定义查询，并自动定期执行这些查询以生成新的聚合数据，这对于实时分析非常有用。
7. **插件和集成：** InfluxDB支持多种插件和集成，包括Grafana、Telegraf等，以便更好地与其他工具协同工作。
8. **高性能：** InfluxDB被设计成能够高效地处理大量的写入和查询操作，以满足高度动态的数据需求。

#### 下表列出了 InfluxDB 和 MySQL 中一些常见概念的对比：

| InfluxDB         | MySQL                         | 描述                                                         |
| ---------------- | ----------------------------- | ------------------------------------------------------------ |
| Bucket           | Database                      | 存储时间序列数据的容器，类似于 MySQL 中的数据库              |
| Measurement      | Table                         | 存储时间序列数据的表，类似于 MySQL 中的表                    |
| Tag              | Index                         | 包含元数据或标签的键值对，用于标识和过滤数据                 |
| Field            | Column                        | 存储实际数据值的字段，类似于 MySQL 中的列                    |
| Point            | Row                           | 单个时间序列数据点，包括时间戳、标签和字段值                 |
| Timestamp        | DATETIME 或 TIMESTAMP         | 数据点的时间戳，表示数据点的时间                             |
| Retention Policy | N/A                           | 确定数据在系统中保存的时间范围，类似于 MySQL 中的数据保留策略 |
| Continuous Query | View                          | 预先定义的查询，自动在后台计算并写入新的数据                 |
| Kapacitor        | Stored Procedures or Triggers | 用于处理和处理数据流的实时数据处理引擎                       |

### 启动

```shell
docker run -d \
  --name influxdb \
  -p 8086:8086 \
  -v /data/influxdb/data:/var/lib/influxdb \
  -v /data/influxdb/config/influxdb.conf:/etc/influxdb/influxdb.conf \
  influxdb
```

### 使用web

1. 访问:xxxx:8086

### 使用手册

### 1. 界面一览

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701696564226-d777acdc-2583-437d-ba6f-7135b0ce4220.png)

### 2. Bucket

##### ⅰ. 创建数据库

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701696772644-04296a06-09d8-4afc-b3a0-715003a47630.png)

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701696788300-91d66f3a-9730-426f-92b2-36fcdd4014f1.png)

#### a. 插入数据

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701740600856-b6148d0e-cd84-41d4-828d-5ec5001dfb44.png)

**Tips:**

- 在InfluxDB中，如果你插入数据时没有指定时间戳，系统将使用插入数据的当前时间戳。这是InfluxDB的默认行为。
- 时间戳用于计算数据是否过期
- 数据的过期时间通常是通过设置**保留策略（Retention Policy）**来实现的,可以在创建Bucket时选择关联一个保留策略
-  InfluxDB执行数据清理的频率是由配置文件中的**compaction-interval**参数决定的，默认值是每隔10分钟。

### 3. telegraf

1. 安装telegraf(乌班图)

```shell
# 添加 Telegraf 存储库
sudo sh -c 'echo "deb https://repos.influxdata.com/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/influxdb.list'
# 导入 InfluxData GPG 密钥：
sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
# 更新软件包列表：
sudo apt update
# 安装 Telegraf：
sudo apt install telegraf
# 启动 Telegraf：
sudo systemctl start telegraf
# 如果你想确保 Telegraf 在系统启动时自动启动，可以运行：
sudo systemctl enable telegraf
# 检查 Telegraf 服务的状态：
sudo systemctl status telegraf
```

1. 配置Telegraf的输入插件

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701697568361-1714fcfe-c530-4fce-9e93-4562f28708f9.png)

1. 选择插件

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701697863190-1ccad6ba-ca9a-4451-9ce4-5fb71227e760.png)

1. 确认

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701697901758-dad7baba-abcc-4418-bfb1-97858c43a961.png)

1. 服务器上运行这两条指令(可以使用nohup后台启动)

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701697936553-6436b565-29fc-43f3-b868-b86f568638d1.png)

1. 运行

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701698078111-f0ab79a0-664f-4f4c-b6ff-ada9f3f64baf.png)

1. 查看数据收集情况

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701698123566-45a23725-d757-4569-8a55-9a570e6b8720.png)

### 4. go语言交互influxdb

![img](https://cdn.nlark.com/yuque/0/2023/png/35553992/1701698952698-36e24ef3-17b7-45b3-b814-53bd90730d85.png)

### 5. influxdb的查询语法

- **关键字及其使用的顺序:**

1. **from****:** 指定数据源，通常是一个桶（bucket）。
2. **range****:** 定义查询的时间范围。
3. **filter****:** 过滤数据，类似于 SQL 中的 WHERE 子句。
4. **group****:** 对数据进行分组，可以按标签、时间等进行分组。
5. **aggregateWindow****:** 在时间窗口内对数据进行聚合。
6. **pivot****:** 透视操作，将表格数据重新排列。
7. **map****:** 对数据进行转换或添加新的列。
8. **sort****:** 对数据进行排序。
9. **limit****:** 限制返回的结果数量。
10. **keep****:** 选择要保留的列。
11. **yield****:** 生成结果集。

- 示例

```sql
from(bucket: "your-bucket-name")
  |> range(start: -1d)
  |> filter(fn: (r) => r["_measurement"] == "temperature")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1h, fn: mean)
  |> map(fn: (r) => ({ r with _value: r._value * 1.8 + 32.0 }))
  |> sort(columns: ["_time"])
  |> limit(n: 10)
  |> keep(columns: ["_time", "_value"])
  |> yield(name: "mean_temperature")
```

### 6. 详细分析(✅常用,❎不常用)

1. **from****()**

- ✅bucket(必需): 参数，用于指定数据存储的桶（Bucket）名称。
- ❎start 和 stop（可选）: 可选参数，用于指定查询的时间范围。它们分别表示查询的开始和结束时间。如果不提供这两个参数，将查询所有时间范围内的数据。
- ❎range（可选）: 可选参数，提供了更灵活的时间范围设置，可以代替 start 和 stop 参数。它接受一个对象，包含 start 和 stop 属性。
- ❎measurement（可选）: 可选参数，用于过滤指定测量（Measurement）的数据。
- ❎organization（可选）: 可选参数，用于指定组织（Organization）的名称。如果 InfluxDB 实例启用了多组织支持，可以使用此参数选择特定组织的数据。

```sql
from(
  bucket: "test_cpu",
  start: -1h,
  stop: now(),
  measurement: "system",
  organization: "my_organization"
)
```

1. **range****()**

- ✅start（必需）: 查询的开始时间。可以是相对时间（例如 -1h 表示过去一小时）或绝对时间（例如 "2023-12-05T12:00:00Z"）。
- ❎stop（可选）: 查询的结束时间。可以是相对时间或绝对时间。如果不指定，表示查询直到当前时间。

```sql
range(start:1h,stop:now())
```

1. **filter****()**

✅**基本过滤条件**

```sql
filter(fn: (r) => r["_measurement"] == "temperature")
```

✅**复合过滤条件**

```sql
filter(fn: (r) => r["_measurement"] == "temperature" and r["_field"] == "value")
```

✅**比较运算符**

```sql
filter(fn: (r) => r["_value"] > 25.0)
```

❎**正则表达式匹配**

```sql
filter(fn: (r) => r["_measurement"] =~ /temperature*/)
```

❎**时间条件**

```sql
filter(fn: (r) => r["_time"] > 2023-12-05T12:00:00Z)
```

1. **group()**

- ✅**columns****（必需）：** 定义用于分组的列。可以是标签名、时间列或字段名。多个列之间使用逗号分隔。
- ❎**mode****（可选）：** 定义分组模式。有两种模式可用：

- **"by"**：按列值进行分组。
- **"except"**：按照除指定列之外的所有其他列进行分组。

- ❎**include****（可选）：** 仅在 **mode: "except"** 时有效，用于指定在 **except** 模式下仍然包括在分组中的列。

```sql
group(columns: ["_tagKey", "_field"], mode: "by")
```

1. **aggregateWindow****()**

- ✅**every****（必需）：** 定义时间窗口的大小，表示在多长时间范围内进行一次聚合。可以使用相对时间（例如 **5m** 表示每 5 分钟聚合一次）或绝对时间。
- ✅**fn****（必需）：** 定义在每个时间窗口内执行的聚合函数。常见的聚合函数包括 **mean**（平均值）、**sum**（总和）、**count**（计数）等。
- ❎**createEmpty****（可选）：** 如果设置为 **true**，则在窗口内没有数据时生成一个空行，而不是忽略该窗口。默认为 **false**。
- ❎**timeSrc****（可选）：** 指定用于时间的源列，默认为 **_time**。

```sql
|> aggregateWindow(every:1h,fn:mean,createEmpty:false,timeSrc:"_time")
```

1. **pivot()**

- rowKey（必需）： 定义表格的行键，即原数据中的列，这些列的值将变成新表格的行。
- colKey（必需）： 定义表格的列键，即原数据中的列，这些列的值将变成新表格的列。
- valueColumn（必需）： 定义新表格中的值来自于原数据中的哪一列。
- groupBy（可选）： 定义表格数据在进行聚合操作之前按照哪些列进行分组。这个参数是一个字符串数组。

- 举个例子

```plain
_time                 | _field     | _value
----------------------|------------|-------
2023-12-05T10:00:00Z | temperature| 25.0
2023-12-05T10:00:00Z | humidity   | 60.0
2023-12-05T11:00:00Z | temperature| 26.0
2023-12-05T11:00:00Z | humidity   | 55.0
```

- 使用函数

```sql
from(bucket: "your-bucket-name")
  |> range(start: -1h)
  |> pivot(rowKey:["_time"], colKey: ["_field"], valueColumn: "_value")
  |> yield(name: "pivoted_data")
```

- 得到新的表格

```sql
_time                 | temperature | humidity
----------------------|-------------|---------
2023-12-05T10:00:00Z | 25.0        | 60.0
2023-12-05T11:00:00Z | 26.0        | 55.0
```

1. **map****()**

- 函数的参数是一个函数，该函数用于对每一行数据进行转换。

```sql
  |> map(fn: (r) => ({
    r with
    newColumn: r._value * 1.8 + 32.0,
    modifiedColumn: r.someColumn * 2  // 修改某一列的值
  }))
```

- 在这个例子中，**map()** 函数接收每一行数据 **r**，然后返回一个新对象，包含了原始数据的所有字段以及新增的 **newColumn** 列和修改过的 **modifiedColumn** 列。你可以根据具体的需求自定义转换逻辑。

1. **sort**

- ✅columns（必需）： 定义一个包含列名的字符串数组，表示按照哪些列进行排序。可以包含多个列名，排序将按照列名数组的顺序进行。(一百是根据时间来排序,desc不填就是时间升序)
- ❎desc（可选）： 定义排序方式，是升序还是降序。默认为 false，表示升序；如果设置为 true，则表示降序。

```sql
|> sort(columns: ["_time"], desc: true)
```

1. **limit**

- ✅n（必需）： 定义返回的行数，即限制查询结果返回的行数。
- ❎offset（可选）： 定义返回结果的起始位置。默认为 0，表示从查询结果的第一行开始。

```sql
|> limit(n: 5, offset: 0)
```

1. **keep**

- ✅columns（必需）： 定义一个包含要保留的列名的字符串数组，表示保留哪些列。
- ❎fn（可选）： 定义一个匿名函数，该函数接受一个列名作为输入，并返回一个新的列名。可以用于对保留的列进行重命名。

```sql
keep(columns: ["column1", "column2"], fn: (column) => "new_name")
```

1. **yield(写不写)**

- name（可选）： 定义返回结果的名称。如果没有提供 name 参数，则使用默认的名称。
- yieldTag（可选）： 将指定的标签添加到返回结果中。通常用于标识特定的查询结果。
- yieldKey（可选）： 将指定的键添加到返回结果中。通常用于标识特定的查询结果。
- yieldValue（可选）： 将指定的值添加到返回结果中。通常用于标识特定的查询结果。

```sql
yield(name: "result_name", yieldTag: "tag_value", yieldKey: "key_value", yieldValue: "value_value")
```

**小demo**

```sql
  from(bucket: "test_cpu") // 从名为 "test_cpu" 的 bucket 中获取数据
    |> range(start: -5h, stop: now()) // 设置查询时间范围为过去 5 小时到当前时间
    |> filter(fn: (r) => r["_measurement"] == "system") // 筛选 _measurement 列等于 "system" 的数据
    |> filter(fn: (r) => r["_value"] > 0) // 筛选 _value 列大于 0 的数据
    |> filter(fn: (r) => r["host"] == "hecs-365639") // 筛选 host 列等于 "hecs-365639" 的数据
    |> filter(fn: (r) => r["_field"] == "load15") // 筛选 _field 列等于 "load15" 的数据
    |> group(columns: ["host"]) // 按照 host 列进行分组
    |> aggregateWindow(every: 1h, fn: mean) // 每小时对数据进行平均值聚合
    |> map(fn: (r) => ({ // 对每一行数据进行映射和转换
        newColumn: r._value * 1.8 + 32.0, // 添加一个新列 newColumn，其值为 _value 列的转换
        modifiedColumn: r._value * 2.0 // 添加一个新列 modifiedColumn，其值为 _value 列的转换
      }))
    |> sort(columns: ["_time"]) // 按照 _time 列进行排序
    |> limit(n: 500, offset: 0) // 限制返回的行数为 500 行，从第一行开始
    |> keep(columns: ["newColumn", "modifiedColumn"]) // 保留 newColumn 和 modifiedColumn 列
    |> yield() // 返回结果
from(bucket:"test_cpu")
|> range(start:-100h, stop: now())
|> filter(fn:(r)=>r["_measurement"]=="system")
|> filter(fn:(r)=>r["_field"]=="load15")
|> filter(fn:(r)=>r["host"]=="hecs-365639")
|> group(columns:["host"])
|> aggregateWindow(every:1h,fn:mean)
|> map(fn:(r)=>({
    tenVal:r._value*10.0,
    hanVal:r._value*100.0
  }))
|> sort(columns:["_time"])
|> limit(n:520)
|> keep(columns:["_value","tenVal","hanVal"])
|> yield()
```

