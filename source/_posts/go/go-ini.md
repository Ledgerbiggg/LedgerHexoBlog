---
title: go-ini读取和操作 INI 格式的配置文件
tags:
  - go每日一库
  - go-ini
---
## 简介

- go-ini 是一个 Go 语言库，用于解析和生成 INI 格式的配置文件。INI（Initial Name-Value Assignment）是一种简单的配置文件格式，通常由一系列的节（section）和键值对（key-value pair）组成，每个键值对表示配置的一个选项和其对应的值。

## 快速使用

- 安装

```shell
go get gopkg.in/ini.v1
```

- Load：从文件中加载 INI 格式的配置数据到内存中的结构体。
- LoadString：从字符串中加载 INI 格式的配置数据到内存中的结构体。
- Get：获取指定节（section）和键（key）对应的值。
- Set：设置指定节和键对应的值。
- Sections：获取配置文件中所有的节。
- Keys：获取指定节中所有的键。
- Write：将内存中的配置数据写入到文件中。

#### 代码

- tip:使用.Int()转换不是int类型的要报错

```go
func TestGo_ini(t *testing.T) {
	cfg, err := ini.Load("my.ini")
	if err != nil {
		log.Fatal("Fail to read file: ", err)
	}

	fmt.Println("App Name:", cfg.Section("").Key("app_name").String())
	fmt.Println("Log Level:", cfg.Section("").Key("log_level").String())

	// 读取 MySQL 配置
	fmt.Println("Section: mysql")
	fmt.Println("MySQL IP:", cfg.Section("mysql").Key("ip").String())
	mysqlPort, err := cfg.Section("mysql").Key("port").Int()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("MySQL Port:", mysqlPort)
	fmt.Println("MySQL User:", cfg.Section("mysql").Key("user").String())
	fmt.Println("MySQL Password:", cfg.Section("mysql").Key("password").String())
	fmt.Println("MySQL Database:", cfg.Section("mysql").Key("database").String())

	// 获取 redis 配置
	fmt.Println("Section: redis")
	fmt.Println("Redis IP:", cfg.Section("redis").Key("ip").String())
	redisPort, err := cfg.Section("redis").Key("port").Int()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Redis Port:", redisPort)

	// 获取所有的配置
	fmt.Println("遍历所有配置")
	for _, section := range cfg.Sections() {
		fmt.Println("节:", section.Name())
		for _, key := range section.Keys() {
			fmt.Printf("%s : %s\n", key.Name(), key.String())
		}
	}

}
```

### Must*便捷方法

- 如果每次取值都需要进行错误判断，那么代码写起来会非常繁琐。为此，go-ini也提供对应的MustType（Type 为Init/Uint/Float64等）方法，这个方法只返回一个值。 同时它接受可变参数，如果类型无法转换，取参数中第一个值返回，并且该参数设置为这个配置的值，下次调用返回这个值：

```go
	redisPort := cfg.Section("redis").Key("port").MustInt(1111)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Redis Port:", redisPort)
```

### 分区操作

#### 获取信息

- 在加载配置之后，可以通过Sections方法获取所有分区，SectionStrings()方法获取所有分区名。

```go
func TestSessions(t *testing.T) {

	cfg, err := ini.Load("my.ini")
	if err != nil {
		log.Fatal("Fail to read file: ", err)
	}
	// 获取所有的节
	sections := cfg.Sections()
	// 获取所有的节名
	names := cfg.SectionStrings()

	fmt.Println("sections: ", sections)
	fmt.Println("names: ", names)
}
```

![img](https://img2.imgtp.com/2024/02/16/ove7qPRs.png)

- 调用Section(name)获取名为name的分区，如果该分区不存在，则自动创建一个分区返回：

```go
	newSection := cfg.Section("new")
	fmt.Println("newSection: ", newSection)
	fmt.Println("cfg.SectionStrings(): ", cfg.SectionStrings())
```

![img](https://img2.imgtp.com/2024/02/16/eJIvDkv8.png)

- 也可以手动创建一个新分区，如果分区已存在，则返回错误：

```go
err := cfg.NewSection("new")
```

### 父子分区

- 配置文件

```properties
[parent]
    key1 = value1

    [parent.child1]
        key2 = value2

    [parent.child2]
        key3 = value3
```

### 保存配置

```go
// 保存
err = cfg.SaveTo("my.ini")
// 保存为缩进
err = cfg.SaveToIndent("my.ini", "\t")

// 输出
cfg.WriteTo(writer)
// 缩进输出
cfg.WriteToIndent(writer, "\t")
func TestSessions(t *testing.T) {

	cfg, err := ini.Load("my.ini")
	if err != nil {
		log.Fatal("Fail to read file: ", err)
	}
	// 获取所有的节
	sections := cfg.Sections()
	// 获取所有的节名
	names := cfg.SectionStrings()

	fmt.Println("sections: ", sections)
	fmt.Println("names: ", names)

	newSection := cfg.Section("new")
	fmt.Println("newSection: ", newSection)
	fmt.Println("cfg.SectionStrings(): ", cfg.SectionStrings())

}

func TestOutput(t *testing.T) {
	cfg := ini.Empty()

	defaultSection := cfg.Section("")
	defaultSection.NewKey("app_name", "awesome web")
	defaultSection.NewKey("log_level", "DEBUG")

	mysqlSection, err := cfg.NewSection("mysql")
	if err != nil {
		fmt.Println("new mysql section failed:", err)
		return
	}
	mysqlSection.NewKey("ip", "127.0.0.1")
	mysqlSection.NewKey("port", "3306")
	mysqlSection.NewKey("user", "root")
	mysqlSection.NewKey("password", "123456")
	mysqlSection.NewKey("database", "awesome")

	redisSection, err := cfg.NewSection("redis")
	if err != nil {
		fmt.Println("new redis section failed:", err)
		return
	}
	redisSection.NewKey("ip", "127.0.0.1")
	redisSection.NewKey("port", "6381")

	err = cfg.SaveTo("my222.ini")
	if err != nil {
		fmt.Println("SaveTo failed: ", err)
	}
	
	err = cfg.SaveToIndent("my-pretty.ini", "\t")
	if err != nil {
		fmt.Println("SaveToIndent failed: ", err)
	}

	cfg.WriteTo(os.Stdout)
	fmt.Println()
	cfg.WriteToIndent(os.Stdout, "\t")
}
```

![img](https://img2.imgtp.com/2024/02/16/ZNUUnyLt.png)

- 不带缩进

![img](https://img2.imgtp.com/2024/02/16/0PyV6Y2I.png)

- 带缩进

![img](https://img2.imgtp.com/2024/02/16/W5LcHFxg.png)

### 分区与结构体字段映射

- 将配置文件直接映射为结构体

```go
type Config struct {
	AppName  string `ini:"app_name"`
	LogLevel string `ini:"log_level"`

	MySQL MySQLConfig `ini:"mysql"`
	Redis RedisConfig `ini:"redis"`
}

type MySQLConfig struct {
	IP       string `ini:"ip"`
	Port     int    `ini:"port"`
	User     string `ini:"user"`
	Password string `ini:"password"`
	Database string `ini:"database"`
}

type RedisConfig struct {
	IP   string `ini:"ip"`
	Port int    `ini:"port"`
}

func TestLoad(t *testing.T) {
	cfg, err := ini.Load("my.ini")
	if err != nil {
		fmt.Println("load my.ini failed: ", err)
	}

	c := Config{}
	cfg.MapTo(&c)

	fmt.Println(c)
}
```

![img](https://img2.imgtp.com/2024/02/16/jECouhwK.png)


































