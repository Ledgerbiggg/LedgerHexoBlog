---
title: ClickHouse数据库
tags:
  - ClickHouse
  - 数据库
---
## **ClickHouse 入门**

### 简介

ClickHouse 是俄罗斯的 Yandex 于 2016 年开源的列式存储数据库（DBMS），使用 C++

语言编写，主要用于在线分析处理查询（OLAP），能够使用 SQL 查询实时生成分析数据报

告。


**ClickHouse 的特点**

- 列式存储

![img](https://img2.imgtp.com/2024/03/12/V7yM2bQS.png)

**采用行式存储时，数据在磁盘上的组织结构为：**

![img](https://img2.imgtp.com/2024/03/12/1b63VWUg.png)

好处是想查某个人所有的属性时，可以通过一次磁盘查找加顺序读取就可以。但是当想

查所有人的年龄时，需要不停的查找，或者全表扫描才行，遍历的很多数据都是不需要的。

**采用列式存储时，数据在磁盘上的组织结构为：**

![img](https://img2.imgtp.com/2024/03/12/DSCA57XO.png)

这时想查所有人的年龄只需把年龄那一列拿出来就可以了

- **列式储存的好处：**

1. 对于列的聚合，计数，求和等统计操作原因优于行式存储。
2. 由于某一列的数据类型都是相同的，针对于数据存储更容易进行数据压缩，每一列

选择更优的数据压缩算法，大大提高了数据的压缩比重。

1. 由于数据压缩比更好，一方面节省了磁盘空间，另一方面对于 cache 也有了更大的

发挥空间。

- **列式储存的缺点**

1. 写入性能：列式存储数据库通常在处理大量事务性写操作时表现不如行式数据库。因为每次插入或更新数据，都涉及到多个列的分别写入，这可能比行式存储的单个连续写操作更为复杂和耗时。
2. 行级操作开销：当需要获取整行数据时，例如在进行表的横向查询（需要许多或所有列的数据）时，列式存储可能需要跨越多个列的数据块来重建完整行的数据，这可能导致性能下降。
3. 实时查询处理：列式数据库可能并不总是适合需要快速响应的实时查询处理，尤其是当查询需要涉及到大量数据写入和即时结果返回时。
4. 数据更新代价：列式存储的数据更新代价可能比行式存储高。在一些列式存储系统中，数据更新可能会涉及到重写整个列的数据块，而不是只更改数据的一小部分，这会增加额外的性能负担。
5. 资源使用：尽管列式存储可以提高查询性能，但在某些情况下这可能需要额外的计算资源，如对多列的数据进行解压缩和聚合运算，这可能会在处理能力有限的环境中成为问题。
6. 复杂性：列式存储数据库在设计和执行方面可能比行式数据库更加复杂。开发者可能需要对列式存储有更深入的了解，才能充分利用其性能优势。

### **DBMS 的功能**

- 几乎覆盖了标准 SQL 的大部分语法，包括 DDL 和 DML，以及配套的各种函数，用户管

理及权限管理，数据的备份与恢复

### **多样化引擎**

- ClickHouse 和 MySQL 类似，把表级的存储引擎插件化，根据表的不同需求可以设定不同

的存储引擎。目前包括合并树、日志、接口和其他四大类 20 多种引擎。

**高吞吐写入能力**

- ClickHouse 采用类 LSM Tree的结构，数据写入后定期在后台 Compaction。通过类 LSM tree

的结构，ClickHouse 在数据导入时全部是顺序 append 写，写入后数据段不可更改，在后台

compaction 时也是多个段 merge sort 后顺序写回磁盘。顺序写的特性，充分利用了磁盘的吞

吐能力，即便在 HDD 上也有着优异的写入性能。

- 官方公开 benchmark 测试显示能够达到 50MB-200MB/s 的写入吞吐能力，按照每行

100Byte 估算，大约相当于 50W-200W 条/s 的写入速度。

**数据分区与线程级并行**

- ClickHouse 将数据划分为多个 partition，每个 partition 再进一步划分为多个 index

granularity(索引粒度)，然后通过多个 CPU核心分别处理其中的一部分来实现并行数据处理。

在这种设计下，单条 Query 就能利用整机所有 CPU。极致的并行处理能力，极大的降低了查

询延时。

- 所以，ClickHouse 即使对于大量数据的查询也能够化整为零平行处理。但是有一个弊端

就是对于单条查询使用多 cpu，就不利于同时并发多条查询。所以对于高 qps 的查询业务，

ClickHouse 并不是强项。

### 启动

```shell
sudo docker run --user root -d --rm \
-p 8123:8123 \
-p 9000:9000 \
--name clickhouse \
--ulimit nofile=262144:262144 \
-e CLICKHOUSE_DB=default \
-e CLICKHOUSE_USER=root \
-e CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 \
-e TZ=Asia/Shanghai \
-e CLICKHOUSE_PASSWORD=root \
-v /data/clickhouse/db:/var/lib/clickhouse \
-d clickhouse/clickhouse-server
```

## 数据类型

### **整型**

整型范围（-2n-1~2n-1-1）：

Int8 - [-128 : 127]

Int16 - [-32768 : 32767]

Int32 - [-2147483648 : 2147483647]

Int64 - [-9223372036854775808 : 9223372036854775807]

无符号整型范围（0~2n-1）：

UInt8 - [0 : 255]

UInt16 - [0 : 65535]

UInt32 - [0 : 4294967295]

UInt64 - [0 : 18446744073709551615]

**使用场景： 个数、数量、也可以存储型 id。**

**浮点型**

Float32 - float

Float64 – double

建议尽可能以整数形式存储数据。例如，将固定精度的数字转换为整数值，如时间用毫秒为单位表示，因为浮点型进行计算时可能引起四舍五入的误差。

**布尔型**

没有单独的类型来存储布尔值。可以使用 UInt8 类型，取值限制为 0 或 1

**Decimal 型**

有符号的浮点数，可在加、减和乘法运算过程中保持精度。对于除法，最低有效数字会

被丢弃（不舍入）

有三种声明：

➢ Decimal32(s)，相当于 Decimal(9-s,s)，有效位数为 1~9

➢ Decimal64(s)，相当于 Decimal(18-s,s)，有效位数为 1~18

➢ Decimal128(s)，相当于 Decimal(38-s,s)，有效位数为 1~38

**字符串**

**String**

字符串可以任意长度的。它可以包含任意的字节集，包含空字节。

**FixedString(N)**

固定长度 N 的字符串，N 必须是严格的正自然数。当服务端读取长度小于 N 的字符

串时候，通过在字符串末尾添加空字节来达到 N 字节长度。 当服务端读取长度大于 N 的

字符串时候，将返回错误消息。

与 String 相比，极少会使用 FixedString，因为使用起来不是很方便

**枚举类型**

包括 Enum8 和 Enum16 类型。Enum 保存 'string'= integer 的对应关系。

Enum8 用 'String'= Int8 对描述。

Enum16 用 'String'= Int16 对描述。

**时间类型**

目前 ClickHouse 有三种时间类型

➢ Date 接受**年****-****月****-****日**的字符串比如 ‘2019-12-16’

➢ Datetime 接受**年****-****月****-****日 时****:****分****:****秒**的字符串比如 ‘2019-12-16 20:50:10’

➢ Datetime64 接受**年****-****月****-****日 时****:****分****:****秒****.****亚秒**的字符串比如‘2019-12-16 20:50:10.66’

日期类型，用两个字节存储，表示从 1970-01-01 (无符号) 到当前的日期值。

还有很多数据结构，可以参考官方文档：https://clickhouse.yandex/docs/zh/data_types/

**数组**

**Array(T)****：**由 T 类型元素组成的数组。

T 可以是任意类型，包含数组类型。 但不推荐使用多维数组，ClickHouse 对多维数组

的支持有限。例如，不能在 MergeTree 表中存储多维数组。

## 表引擎

**表引擎的使用**

表引擎是 ClickHouse 的一大特色。可以说， 表引擎决定了如何存储表的数据。包括：

➢ 数据的存储方式和位置，写到哪里以及从哪里读取数据。

➢ 支持哪些查询以及如何支持。

➢ 并发数据访问。

➢ 索引的使用（如果存在）。

➢ 是否可以执行多线程请求。

➢ 数据复制参数。

表引擎的使用方式就是必须显式在创建表时定义该表使用的引擎，以及引擎使用的相关

参数。

**TinyLog**

以列文件的形式保存在磁盘上，不支持索引，没有并发控制。一般保存少量数据的小表，

生产环境上作用有限。可以用于平时练习测试用。

**Memory**

内存引擎，数据以未压缩的原始形式直接保存在内存当中，服务器重启数据就会消失。

读写操作不会相互阻塞，不支持索引。简单查询下有非常非常高的性能表现（超过 10G/s）。

一般用到它的地方不多，除了用来测试，就是在需要非常高的性能，同时数据量又不太

大（上限大概 1 亿行）的场景。

**MergeTree**

ClickHouse 中最强大的表引擎当属 MergeTree（合并树）引擎及该系列（*MergeTree）

中的其他引擎，支持索引和分区，地位可以相当于 innodb 之于 Mysql。

而且基于 MergeTree，

还衍生除了很多小弟，也是非常有特色的引擎。



**partition by 分区**

**作用**

学过 hive 的应该都不陌生，分区的目的主要是降低扫描的范围，优化查询速度

**分区目录**

MergeTree 是以列文件+索引文件+表定义文件组成的，但是如果设定了分区那么这些文

件就会保存到不同的分区目录中。

**并行**

分区后，面对涉及跨分区的查询统计，ClickHouse 会以分区为单位并行处理。

**数据写入与分区合并**

任何一个批次的数据写入都会产生一个临时分区，不会纳入任何一个已有的分区。写入

后的某个时刻（大概 10-15 分钟后），ClickHouse 会自动执行合并操作（等不及也可以手动

通过 optimize 执行），把临时分区的数据，合并到已有分区中。

**primary key 主键**

ClickHouse 中的主键，和其他数据库不太一样，**它只提供了数据的一级索引，但是却不**

**是唯一约束。**这就意味着是可以存在相同 primary key 的数据的。

主键的设定主要依据是查询语句中的 where 条件。

根据条件通过对主键进行某种形式的二分查找，能够定位到对应的 index granularity,避

免了全表扫描。

index granularity： 直接翻译的话就是索引粒度，指在稀疏索引中两个相邻索引对应数

据的间隔。ClickHouse 中的 MergeTree 默认是 8192。官方不建议修改这个值，除非该列存在

大量重复值，比如在一个分区中几万行才有一个不同数据。

**order by**

order by 设定了分区内的数据按照哪些字段顺序进行有序保存。

order by 是 MergeTree 中唯一一个必填项，甚至比 primary key 还重要，因为当用户不

设置主键的情况，很多处理会依照 order by 的字段进行处理（比如后面会讲的去重和汇总）。

要求：主键必须是 order by 字段的前缀字段。

比如 order by 字段是 (id,sku_id) 那么主键必须是 id 或者(id,sku_id)

**二级索引**

目前在 ClickHouse 的官网上二级索引的功能在 v20.1.2.4 之前是被标注为实验性的，在

这个版本之后默认是开启的。

**数据 TTL**

TTL 即 Time To Live，MergeTree 提供了可以管理数据表或者列的生命周期的功能



**列级别的 TTL**

**表级别的 TTL**



**ReplacingMergeTree**

ReplacingMergeTree 是 MergeTree 的一个变种，它存储特性完全继承 MergeTree，只是

多了一个去重的功能。 尽管 MergeTree 可以设置主键，但是 primary key 其实没有唯一约束

的功能。如果你想处理掉重复的数据，可以借助这个 ReplacingMergeTree。

**查询操作**

➢ 支持子查询

➢ 支持 CTE(Common Table Expression 公用表表达式 with 子句)

➢ 支持各种 JOIN，

但是 JOIN 操作无法使用缓存，所以即使是两次相同的 JOIN 语句，

ClickHouse 也会视为两条新 SQL

➢ 窗口函数(官方正在测试中...)

➢ 不支持自定义函数

➢ GROUP BY 操作增加了 with rollup\with cube\with total 用来计算小计和总计。

**alter 操作**

**1****）新增字段**

alter table **tableName** add column **newcolname** String after col1;

**2****）修改字段类型**

alter table tableName modify column newcolname String;

**3****）删除字段**

alter table tableName drop column newcolname;

### 副本

副本的目的主要是保障数据的高可用性，即使一台 ClickHouse 节点宕机，那么也可以从

其他服务器获得相同的数据

**副本写入流程**

![img](https://img2.imgtp.com/2024/03/12/HoF37j9G.png)

**分片集群**

副本虽然能够提高数据的可用性，降低丢失风险，但是每台服务器实际上必须容纳全量

数据，对数据的横向扩容没有解决

ClickHouse 高级

**Explain 查看执行计划**

**Explain+sql**

```sql
SELECT dhcs.host_sequence                             sequence,
       hcs.product_model                              product_model,
       concat(CAST(SUM(hcs.total_value) AS CHAR), '+',
              CAST(SUM(shcs.total_value) AS CHAR), '+',
              CAST(SUM(dhcs.total_value) AS CHAR)) AS _value
FROM (
         SELECT time_hour, host_sequence, product_model, field, total_value
         FROM host_command_summary
         WHERE time_hour BETWEEN 1710172800 AND 1710259199.999
         ) hcs
         RIGHT JOIN (
    SELECT time_hour, host_sequence, product_model, field, total_value
    FROM slave_host_command_summary
    WHERE time_hour BETWEEN 1710172800 AND 1710259199.999
    ) shcs
                    ON hcs.host_sequence = shcs.host_sequence
                        AND hcs.time_hour = shcs.time_hour
         RIGHT JOIN (
    SELECT time_hour, host_sequence, field, total_value
    FROM device_host_command_summary
    WHERE time_hour BETWEEN 1710172800 AND 1710259199.999
    ) dhcs
                    ON hcs.host_sequence = dhcs.host_sequence
                        AND hcs.time_hour = dhcs.time_hour
WHERE TRUE
  AND dhcs.time_hour BETWEEN 1710172800 AND 1710259199.999
GROUP BY dhcs.host_sequence, hcs.product_model
ORDER BY _value
        DESC
LIMIT 0,30;
```

### 建表优化

**数据类型**

**时间字段的类型**

建表时能用数值型或日期时间型表示的字段就不要用字符串，全 String 类型在以 Hive

为中心的数仓建设中常见，但 ClickHouse 环境不应受此影响。

虽然 ClickHouse 底层将 DateTime 存储为时间戳 Long 类型，但不建议存储 Long 类型，

因为 DateTime 不需要经过函数转换处理，执行效率高、可读性好。

**空值存储类型**

官方已经指出 **Nullable** **类型几乎总是会拖累性能**，因为存储 Nullable 列时需要创建一个

额外的文件来存储 NULL 的标记，并且 Nullable 列无法被索引。因此除非极特殊情况，应直

接使用字段默认值表示空，或者自行指定一个在业务中无意义的值（例如用-1 表示没有商品

ID）

**分区和索引**

分区粒度根据业务特点决定，不宜过粗或过细。一般选择**按天分区**，也可以指定为 Tuple()，

以单表一亿数据为例，分区大小控制在 10-30 个为最佳。

必须指定索引列，ClickHouse 中的索引列即排序列，通过 order by 指定，一般在查询条

件中经常被用来充当筛选条件的属性被纳入进来；可以是单一维度，也可以是组合维度的索

引；通常需要满足高级列在前、查询频率大的在前原则；还有基数特别大的不适合做索引列，

如用户表的 userid 字段；通常**筛选后的数据满足在百万以内为最佳**。

**表参数**

Index_granularity 是用来控制索引粒度的，默认是 8192，如非必须不建议调整。

如果表中不是必须保留全量历史数据，建议指定 TTL（生存时间值），可以免去手动过期

历史数据的麻烦，TTL 也可以通过 alter table 语句随时修改。

（参考基础文档 4.4.5 数据 TTL）

**写入和删除优化**

（1）尽量不要执行单条或小批量删除和插入操作，这样会产生小分区文件，给后台

Merge 任务带来巨大压力

（2）不要一次写入太多分区，或数据写入太快，数据写入太快会导致 Merge 速度跟不

上而报错，一般建议每秒钟发起 2-3 次写入操作，每次操作写入 2w~5w 条数据（依服务器

性能而定）

**常见配置**

配置项主要在 config.xml 或 users.xml 中， 基本上都在 users.xml 里

➢ config.xml 的配置项

https://clickhouse.com/docs/zh/operations/server-configuration-parameters/settings

➢ users.xml 的配置项

https://clickhouse.tech/docs/zh/operations/settings/settings/

**CPU 资源**

![img](https://img2.imgtp.com/2024/03/12/e3CDbPqM.png)

**内存资源**

![img](https://img2.imgtp.com/2024/03/12/sbfOkWmg.png)

**存储**

ClickHouse 不支持设置多数据目录，为了提升数据 io 性能，可以挂载虚拟券组，一个券

组绑定多块物理磁盘提升读写性能，多数据查询场景 SSD 会比普通机械硬盘快 2-3 倍。

**ClickHouse 语法优化规则**

**单表查询**

**Prewhere 替代 where**

**数据采样**

通过采样运算可极大提升数据分析的性能

**列裁剪与分区裁剪**

数据量太大时应避免使用 select * 操作，查询的性能会与查询的字段大小和数量成线性

表换，字段越少，消耗的 io 资源越少，性能就会越高

**orderby 结合 where、limit**

千万以上数据集进行 order by 查询时需要搭配 where 条件和 limit 语句一起使用。

**避免构建虚拟列**

如非必须，不要在结果集上构建虚拟列，虚拟列非常消耗资源浪费性能，可以考虑在前

端进行处理，或者在表中构造实际字段进行额外存储。

**其他注意事项**

**查询熔断**

为了避免因个别慢查询引起的服务雪崩的问题，除了可以为单个查询设置超时以外，还

可以配置周期熔断，在一个查询周期内，如果用户频繁进行慢查询操作超出规定阈值后将无

法继续进行查询操作

**关闭虚拟内存**

物理内存和虚拟内存的数据交换，会导致查询变慢，资源允许的情况下关闭虚拟内存。

**配置 join_use_null**

为每一个账户添加 join_use_nulls 配置，左表中的一条记录在右表中不存在，右表的相

应字段会返回该字段相应数据类型的默认值，而不是标准 SQL 中的 Null 值。

**批量写入时先排序**

批量写入数据时，必须控制每个批次的数据中涉及到的分区的数量，在写入之前最好对

需要导入的数据进行排序。无序的数据或者涉及的分区太多，会导致 ClickHouse 无法及时对

新导入的数据进行合并，从而影响查询性能

**关注 CPU**

cpu 一般在 50%左右会出现查询波动，达到 70%会出现大范围的查询超时，cpu 是最关

键的指标，要非常关注。

**物化视图**

**普通视图不保存数据，保存的仅仅是查询语句**，查询的时候还是从原表读取数据，可以

将普通视图理解为是个子查询。**物化视图则是把查询的结果根据相应的引擎存入到了磁盘**

**或内存中**，对数据重新进行了组织，你可以理解物化视图是完全的一张新表。

**优缺点**

优点：查询速度**快**，要是把物化视图这些规则全部写好，它比原数据查询快了很多，总

的行数少了，因为都预计算好了。

缺点：它的本质是一个流式数据的使用场景，是累加式的技术，所以要用历史数据做去

重、去核这样的分析，在物化视图里面是不太好用的。在某些场景的使用也是有限的。而且

如果一张表加了好多物化视图，在写这张表的时候，就会消耗很多机器的资源，比如数据带

宽占满、存储一下子增加了很多。

- 物化视图创建好之后，若源表被写入新数据则物化视图也会同步更新
- 物化视图不支持同步删除，若源表的数据不存在（删除了）则物化视图的数据仍然保留
- 物化视图是一种特殊的数据表，可以用 show tables 查看
- 修改数据有限制

