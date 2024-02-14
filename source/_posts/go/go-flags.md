---
title: flag的增强go-flags
tags:
  - go每日一库
  - go-flags
---

## 简介

- 是一个 Go 语言的命令行参数解析库，用于帮助开发者创建命令行工具并解析命令行参数。它提供了一种简单而灵活的方式来定义命令行标志(flag)，支持短选项（如 -v）和长选项（如 --verbose），以及子命令（subcommands）的解析。通过 go-flags，开发者可以轻松地解析命令行参数，并根据参数执行相应的操作，使得命令行工具的开发和使用更加便捷。

## 快速使用

1. 支持子命令
2. 自动生成帮助文档
3. 选项别名
4. 更灵活的选项处理
5. 更多的类型支持

### 1.  支持子命令（Subcommands）： 

- **功能：** `go-flags` 允许您为命令行工具定义多个子命令，这使得您可以将功能按照不同的子命令进行组织，提供更清晰的命令结构。
- **场景：** 例如，您正在开发一个版本控制工具，您可以为该工具定义诸如 `commit`、`push`、`pull` 等子命令，每个子命令执行不同的操作。这样，用户可以根据需要选择相应的子命令，并通过子命令来执行特定的功能。

#### 代码

-  flags.NewParser 创建解析器
- 子命令的结构体实现接口

```go
type Commander interface {
	// Execute will be called for the last active (sub)command. The
	// args argument contains the remaining command line arguments. The
	// error that Execute returns will be eventually passed out of the
	// Parse method of the Parser.
	Execute(args []string) error
}
```

- parser.AddCommand 添加子指令
-  parser.Parse() 解析

```go
func main() {
	SubCommend()
}

func SubCommend() {
	// 创建解析器
	parser := flags.NewParser(&Options{}, flags.Default)

	// 添加子命令
	subCmd1 := &Subcommand1{}
	subCmd2 := &Subcommand2{}

	parser.AddCommand("subcommand1", "子命令1的描述", "子命令1的长描述...", subCmd1)
	parser.AddCommand("subcommand2", "子命令2的描述", "子命令2的长描述...", subCmd2)

	// 解析命令行参数
	_, err := parser.Parse()
	if err != nil {
		os.Exit(1)
	}
}

type Options struct {
	// 主命令的选项
}

type Subcommand1 struct {
	// 子命令1的选项
}

type Subcommand2 struct {
	// 子命令2的选项
}

// Execute 实现子命令的方法
func (opts *Subcommand1) Execute(args []string) error {
	// 子命令1的逻辑
	fmt.Println("执行子命令1")
	fmt.Println("执行子命令1")
	fmt.Println("执行子命令1")
	return nil
}

func (opts *Subcommand2) Execute(args []string) error {
	// 子命令2的逻辑
	fmt.Println("执行子命令2")
	fmt.Println("执行子命令2")
	fmt.Println("执行子命令2")
	return nil
}
```

#### 运行

- 执行指令

```shell
go run .\main.go subcommand1
go run .\main.go subcommand2
```

![img](https://img2.imgtp.com/2024/02/14/pDaZrCOz.png)

- 查看指令

```shell
 .\main.exe -h
```

![img](https://img2.imgtp.com/2024/02/14/vREsZIDQ.png)

### 2.  自动生成帮助文档： 

- **功能：** `go-flags` 可以自动为您的命令行工具生成帮助文档，包括命令、选项、子命令的说明，以及示例用法等信息。
- **场景：** 当您的命令行工具包含许多选项和子命令时，手动编写帮助文档可能会变得繁琐。通过使用 `go-flags`，您可以轻松地生成详细的帮助文档，使得用户可以方便地了解命令行工具的用法和功能。

#### 代码

- Options2 表示命令行的参数的合集组(这里存放了两个命令行参数,Verbose和Threshold)
- parser.Usage 表示使用方法的名称
- opt.Call 指定call的函数,传入的参数作为call函数的参数

```go
func GenerateDoc() {
	var opt Options2 // 创建一个 Options 结构体实例用于存储命令行选项的值

	parser := flags.NewParser(&opt, flags.Default) // 创建一个 go-flags 解析器，并将 Options 结构体的地址传递给它
	parser.Usage = "[MAIN-PARAM]"                  // 设置解析器的用法说明

	opt.Call = func(value string) {
		fmt.Println("in callback: ", value)
	}

	_, err := parser.Parse() // 解析命令行参数，并返回解析结果和可能的错误
	if err != nil {          // 如果解析过程中发生错误
		if flagsErr, ok := err.(*flags.Error); ok && flagsErr.Type == flags.ErrHelp { // 如果是因为用户请求帮助文档
			os.Exit(0) // 立即退出程序，不进行其他处理
		}
		fmt.Println(err) // 打印错误信息
		os.Exit(1)       // 退出程序并返回错误码 1
	}

	// 执行到这里说明命令行参数解析成功，可以执行其他逻辑
	fmt.Printf("int flag: %v\n", opt.IntFlag)
	fmt.Printf("int slice flag: %v\n", opt.IntSlice)
	fmt.Printf("bool flag: %v\n", opt.BoolFlag)
	fmt.Printf("bool slice flag: %v\n", opt.BoolSlice)
	fmt.Printf("float flag: %v\n", opt.FloatFlag)
	fmt.Printf("float slice flag: %v\n", opt.FloatSlice)
	fmt.Printf("string flag: %v\n", opt.StringFlag)
	fmt.Printf("string slice flag: %v\n", opt.StringSlice)
	fmt.Println("slice of pointer of string flag: ")
	for i := 0; i < len(opt.PtrStringSlice); i++ {
		fmt.Printf("\t%d: %v\n", i, *opt.PtrStringSlice[i])
	}
	fmt.Printf("int map: %v\n", opt.IntMap)
}

// Options2 结构体用于定义命令行选项
type Options2 struct {
	IntFlag        int            `short:"i" long:"int" description:"int flag value"`
	IntSlice       []int          `long:"intslice" description:"int slice flag value"`
	BoolFlag       bool           `long:"bool" description:"bool flag value"`
	BoolSlice      []bool         `long:"boolslice" description:"bool slice flag value"`
	FloatFlag      float64        `long:"float" description:"float64 flag value"`
	FloatSlice     []float64      `long:"floatslice" description:"float64 slice flag value"`
	StringFlag     string         `short:"s" long:"string" description:"string flag value"`
	StringSlice    []string       `long:"strslice" description:"string slice flag value"`
	PtrStringSlice []*string      `long:"pstrslice" description:"slice of pointer of string flag value"`
	Call           func(string)   `long:"call" description:"callback"`
	IntMap         map[string]int `long:"intmap" description:"A map from string to int"`
}
```

- 执行指令

```shell
./main.exe -i 10 --intslice 1 2 3 --bool --boolslice true false --float 3.14 --floatslice 1.1 2.2 3.3 -s hello --strslice one two three --pstrslice foo bar baz --call testParam --intmap key1:1 key2:2
IntFlag: 设置为 10
IntSlice: 设置为 [1, 2, 3]
BoolFlag: 设置为 true
BoolSlice: 设置为 [true, false]
FloatFlag: 设置为 3.14
FloatSlice: 设置为 [1.1, 2.2, 3.3]
StringFlag: 设置为 "hello"
StringSlice: 设置为 ["one", "two", "three"]
PtrStringSlice: 设置为 ["foo", "bar", "baz"]
Call: 传入参数 testParam
IntMap: 设置为 map[string]int{"key1": 1, "key2": 2}
```

![img](https://img2.imgtp.com/2024/02/14/eE2yDQUf.png)

- 查看程序的帮助文档

```shell
go run main.go --help
```

![img](https://img2.imgtp.com/2024/02/14/VmWnsltW.png)

### 3. 常用设置

- long: 长指令
- short: 短指令
- description： 用于为选项提供描述文本，描述其作用和用法。
- required： 用于标记选项是否为必需的，如果设置为 true，则用户必须在命令行中提供该选项。
- default： 用于为选项设置默认值，如果用户未在命令行中提供该选项，则使用默认值。
- env： 用于将选项与环境变量绑定，使得用户可以通过设置环境变量来配置选项的值。



tip: 运行程序，不传入default选项，Default字段取默认值，不传入required选项，执行报错

### 4.  分组配置： 

- **功能：** `gof-flags` 支持更多类型的命令行选项，包括复杂的数据结构、嵌套选项等。
- **场景：** 这样可以使代码看起来更清晰自然，特别是在代码量很大的情况下。 这样做还有一个好处

#### 代码

```go
// MySQLConfig 结构体表示 MySQL 的配置
type MySQLConfig struct {
	Host     string `long:"mysql-host" description:"MySQL host"`
	Port     int    `long:"mysql-port" description:"MySQL port"`
	Username string `long:"mysql-username" description:"MySQL username"`
	Password string `long:"mysql-password" description:"MySQL password"`
}

// RedisConfig 结构体表示 Redis 的配置
type RedisConfig struct {
	Host     string `long:"redis-host" description:"Redis host"`
	Port     int    `long:"redis-port" description:"Redis port"`
	Password string `long:"redis-password" description:"Redis password"`
}

// Options4 Options3 结构体表示所有选项
type Options4 struct {
	MySQL MySQLConfig `group:"MySQL Options"`
	Redis RedisConfig `group:"Redis Options"`
}

func UseGroup() {
	var opts Options4

	parser := flags.NewParser(&opts, flags.Default)
	parser.Usage = "[OPTIONS]"

	_, err := parser.Parse()
	if err != nil {
		if flagsErr, ok := err.(*flags.Error); ok && flagsErr.Type == flags.ErrHelp {
			parser.WriteHelp(os.Stdout)
			os.Exit(0)
		}
		fmt.Println(err)
		os.Exit(1)
	}

	// 打印 MySQL 配置信息
	fmt.Println("MySQL Configuration:")
	fmt.Printf("Host: %s\n", opts.MySQL.Host)
	fmt.Printf("Port: %d\n", opts.MySQL.Port)
	fmt.Printf("Username: %s\n", opts.MySQL.Username)
	fmt.Printf("Password: %s\n", opts.MySQL.Password)

	// 打印 Redis 配置信息
	fmt.Println("\nRedis Configuration:")
	fmt.Printf("Host: %s\n", opts.Redis.Host)
	fmt.Printf("Port: %d\n", opts.Redis.Port)
	fmt.Printf("Password: %s\n", opts.Redis.Password)
}
```

- 启动程序

```shell
go run  .\main.go --mysql-host=localhost --mysql-port=3306 --mysql-username=admin --mysql-password=secretpassword --redis-host=localhost --redis-port=6379 --redis-password=myredispassword
```

- 结果

![img](https://img2.imgtp.com/2024/02/14/yTiiWoB9.png)