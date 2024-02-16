---
title: go-homedir获取目录
tags:
  - go每日一库
  - go-homedir
---
## 简介

- go-homedir 是一个 Go 语言库，用于获取用户的主目录路径。在跨平台的应用程序中，需要了解用户主目录的位置以便正确地处理文件和配置。但是不同操作系统的用户主目录路径可能不同，例如在 Unix 系统中通常是 /home/user，而在 Windows 系统中通常是 C:\Users\user。go-homedir 库通过提供一个简单的 API，让开发者能够跨平台地获取用户主目录路径，从而简化了应用程序的开发过程。

## 快速使用

- 安装

```shell
go get github.com/mitchellh/go-homedir
```

- go-homedir有两个功能：

- Dir：获取用户主目录；
- Expand：将路径中的第一个~扩展成用户主目录。

#### 代码

```go
func TestGo_homedir(t *testing.T) {
	dir, err := homedir.Dir()
	if err != nil {
		t.Fatal(err)
		os.Exit(1)
	}
	fmt.Println("当前用户的主目录路径:", dir)
	// 将路径中的 `~` 或 `~user` 转换为完整的用户主目录路径
	expandedPath, err := homedir.Expand("~/Documents")
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}
	fmt.Println("完整的用户主目录路径:", expandedPath)
}
```

## 高级用法

### 缓存功能

- go-homedir 提供了缓存功能，以提高性能。默认情况下，go-homedir 会在第一次调用 homedir.Dir() 或 homedir.Expand() 时执行系统调用或外部执行命令来获取用户主目录路径，并将结果缓存起来。后续对这两个函数的调用会直接返回缓存中的结果，而不再执行系统调用或外部命令。

```go
func TestCache(t *testing.T) {
	// 禁用缓存
	homedir.DisableCache = true

	// 第一次调用会执行系统调用或外部命令，并将结果缓存
	homeDir, err := homedir.Dir()
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}
	fmt.Println("当前用户的主目录路径:", homeDir)

	// 第二次调用不会执行系统调用或外部命令，直接返回缓存中的结果
	homeDirCached, err := homedir.Dir()
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}
	fmt.Println("缓存中的主目录路径:", homeDirCached)
}
```






