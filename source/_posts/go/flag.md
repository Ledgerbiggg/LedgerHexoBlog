---
title: 使用go语言框架flag使用命令行参数
date: 2023-02-10
tags:
  - go每日一库
  - flag
---
## 简介

- 在Go语言的标准库中，flag 包提供了一种简单的方法来解析命令行参数。以下是一个简单的示例，演示如何使用 flag 包：

## 快速使用

### 基本用法

- 优势

- 使用的方法就是将命令行参数转化为内部的变量去使用

- 场景

- 测试环境的变量控制,比如日志级别控制等等

#### 代码

- 学习一个库的第一步当然是使用它。我们先看看flag库的基本使用

```go
package main

import (
  "fmt"
  "flag"
)

var (
  intflag int
  boolflag bool
  stringflag string
)

func init() {
  flag.IntVar(&intflag, "intflag", 0, "int flag value")
  flag.BoolVar(&boolflag, "boolflag", false, "bool flag value")
  flag.StringVar(&stringflag, "stringflag", "default", "string flag value")
}

func main() {
  flag.Parse()
  fmt.Println("int flag:", intflag)
  fmt.Println("bool flag:", boolflag)
  fmt.Println("string flag:", stringflag)
}
```

1. 普通启动的打印

![img](https://img2.imgtp.com/2024/02/12/243G8J5K.png)

1. 设置命令行参数

![img](https://img2.imgtp.com/2024/02/12/hyVHeWm9.png)

- 启动

![img](https://img2.imgtp.com/2024/02/12/WZE1RZY6.png)

- 使用命令查看可以配置的命令行参数和描述

```shell
.\main.exe -h
```

![img](https://img2.imgtp.com/2024/02/12/SUUl1O3K.png)

## 高级使用方法

### 接口实现的方法控制命令行参数的传递

- 优势:

- 更加灵活,不是给什么参数就赋值什么参数,可以对值进行判断或者修改

- 场景

- 如果传入的是value1,value2,value3这样的可以写成数组传入变量

#### 代码

- 实现Value接口

```go
type Value interface {
	String() string
	Set(string) error
}
```

- 实现(将环境变量的字符串转换为字符串数组给变量赋值)

```go
type stringSlice []string

func (s *stringSlice) String() string {
	return fmt.Sprintf("%v", *s)
}

func (s *stringSlice) Set(value string) error {
	*s = append(*s, strings.Split(value, ",")...)
	return nil
}
```

- 使用

```go
func main() {
	var stringSliceFlag stringSlice
	flag.Var(&stringSliceFlag, "stringSliceFlag", "string slice flag value")
	flag.Parse()
	fmt.Println(stringSliceFlag.String())
	fmt.Println("StringSliceFlag:", stringSliceFlag)
}
```

- 结果

![img](https://img2.imgtp.com/2024/02/12/3b3d7M3L.png)

## FlagSet的使用

- 优势

- 可以对命令行参数的变量进行分组管理,同一个flagset的变量都分到一组去了

- 场景

- 变量的分组控制,比如数据库的地址,端口等等分为一组使用

#### 代码

- 创建一个叫group的FlagSet,将name分配到这个FlagSet中

- flag.NewFlagSet创建于IGfs
- fs.String定义一个fs参数(参数名字,参数默认值.参数描述)
- fs.Parse(os.Args[1:]) 解析所有的参数
- fs.NArg()没有完成解析的参数个数

```go
func main() {

	// 创建一个新的 FlagSet
	fs := flag.NewFlagSet("group", flag.ExitOnError)

	// 定义命令行标志
	name := fs.String("name", "Guest", "Your name")

	// 解析命令行参数
	//其中 os.Args[0] 表示的是程序本身的名称,不用解析
	fs.Parse(os.Args[1:])

	// 如果没有未识别的参数就走这个分支
	if fs.NArg() == 0 {
		fmt.Println("Hello, ", *name)
	}
}
```

- 使用FlagSet的分组使用

- 创建两个fs
- fs.Lookup查看这个参数是不是自己组的,解析非自己组的参数会报错!!!
- fs.Parse(fsArgs)批量解析

```go
func test() {

	// 创建一个新的 FlagSet
	fs := flag.NewFlagSet("group", flag.ExitOnError)
	fs2 := flag.NewFlagSet("group2", flag.ExitOnError)

	// 定义命令行标志
	name := fs.String("name", "Guest", "Your name")
	des := fs.String("des", "des", "description")

	name2 := fs2.String("name2", "Guest2", "Your name")
	des2 := fs2.String("des2", "des2", "description")

	// 解析命令行参数
	//其中 os.Args[0] 表示的是程序本身的名称,不用解析,将后面的所有参数解析
	// 解析命令行参数
	fsArgs := make([]string, 0)
	fs2Args := make([]string, 0)

	for i := 1; i < len(os.Args); i++ {
		// 检查参数是否属于 fs 或 fs2
		if fs.Lookup(os.Args[i]) != nil {
			fsArgs = append(fsArgs, os.Args[i])
		} else if fs2.Lookup(os.Args[i]) != nil {
			fs2Args = append(fs2Args, os.Args[i])
		}
	}
	// 解析命令行参数
	fs.Parse(fsArgs)
	fs2.Parse(fs2Args)

	fmt.Println("Hello, ", *name)
	fmt.Println("Hello, ", *name2)
	fmt.Println("description, ", *des)
	fmt.Println("description, ", *des2)
}
```

- 查看结果

![img](https://img2.imgtp.com/2024/02/12/esOBDmHF.png)

- 查看分组状况

```go
func main() {

    // 创建一个新的 FlagSet
    fs := flag.NewFlagSet("group", flag.ExitOnError)
    fs2 := flag.NewFlagSet("group2", flag.ExitOnError)

    // 定义命令行标志
    name := fs.String("name", "Guest", "Your name")
    des := fs.String("des", "des", "description")

    name2 := fs2.String("name2", "Guest2", "Your name")
    des2 := fs2.String("des2", "des2", "description")

    // 解析命令行参数
    //其中 os.Args[0] 表示的是程序本身的名称,不用解析,将后面的所有参数解析
    // 解析命令行参数
    fsArgs := make([]string, 0)
    fs2Args := make([]string, 0)

    for i := 1; i < len(os.Args); i++ {
        // 检查参数是否属于 fs 或 fs2
        if fs.Lookup(os.Args[i]) != nil {
            fsArgs = append(fsArgs, os.Args[i])
        } else if fs2.Lookup(os.Args[i]) != nil {
            fs2Args = append(fs2Args, os.Args[i])
        }
    }
    // 解析命令行参数
    fs.Parse(fsArgs)
    fs2.Parse(fs2Args)

    fmt.Println("Hello, ", *name)
    fmt.Println("Hello, ", *name2)
    fmt.Println("description, ", *des)
    fmt.Println("description, ", *des2)

    fmt.Println("分组情况")
    fs.PrintDefaults()
    fs2.PrintDefaults()
}
```

- 打印情况

![img](https://img2.imgtp.com/2024/02/12/uQq9etBB.png)