---
title: go工具小包
tags:
  - project
  - go
  - ledger_util
---

[项目地址](https://github.com/Ledgerbiggg/ledger_util)

### 项目简介

- 这个是用go语言编写的一个工具包合集

### 快速使用

1. 引入

```shell
 go get github.com/ledgerbiggg/ledger_util
```

1. email

- 发送简单邮件

```go
func TestSendUtil_IsCCOrBCCSend(t *testing.T) {
	err := NewSimpleSendUtil("xxx@qq.com",
		"xxx@qq.com",
		"test",
		"test",
		nil,
		&User{
			Identity: "",
			Username: "xxx@qq.com",
			Password: "xxx",
		},
		QQ).IsCCOrBCCSend(true, false)

	if err != nil {
		t.Error(err)
	}
}
```

1. http

- 简单请求

```go
func TestGet(t *testing.T) {
	p := param{
		Name: "",
		Age:  0,
	}
	newUrl, err := MontageURL("https://www.baidu.com", p)
	if err != nil {
		t.Error(err)
	}
	get, err := NewHttpDos(newUrl, nil, nil).Get()
	if err != nil {
		t.Error(err)
	}
	t.Log(string(get))
}
```

1. excel

- 生成excel

```go
func TestExcelHelper_GenerateExcel(t *testing.T) {
	people := []any{
		Person{"Alice", 30, "USA"},
		Person{"Bob", 25, "Canada"},
		Person{"Charlie", 35, "UK"},
	}
    // 文件名,sheet名,表头,数据
	helper := NewExcelHelper("persons1.xlsx", "Sheet1", []string{"Name", "Age", "Country"}, people)
	err := helper.GenerateExcel()
	if err != nil {
		t.Error(err)
	}
}
```

1. vedio断点续传

```go
http.HandleFunc("/api/video", func(w http.ResponseWriter, r *http.Request) {
		// 打开视频文件
		videoFile, err := os.Open("videos/video2.mp4")
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer videoFile.Close()

		// 获取文件信息
		fileInfo, err := videoFile.Stat()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// 设置响应头，指定文件内容类型
		//w.Header().Set("Content-Type", "video/mp4")
		w.Header().Set("Content-Type", "video/mp4")

		// 设置响应头，指定文件总长度
		w.Header().Set("Content-Length", strconv.FormatInt(fileInfo.Size(), 10))

		// 处理 Range 请求头
		rangeHeader := r.Header.Get("Range")
		if rangeHeader != "" {
			// 解析 Range 请求头，获取起始和结束位置
			start, _, err := parseRange(rangeHeader, fileInfo.Size())
			if err != nil {
				http.Error(w, "Invalid range request", http.StatusRequestedRangeNotSatisfiable)
				return
			}
			// 设置响应状态码为 206 Partial Content
			//w.WriteHeader(206)

			// 设置读取文件的起始位置
			videoFile.Seek(start, 0)

			// 发送部分内容给客户端
			http.ServeContent(w, r, "", fileInfo.ModTime(), videoFile)
		} else {
			// 如果没有 Range 请求头，直接发送整个文件内容
			http.ServeContent(w, r, "", fileInfo.ModTime(), videoFile)
		}
	})
	http.ListenAndServe(":9999", nil)
```