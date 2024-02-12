---
title: go做后端实现前端视频的断点续传
date: 2024-02-10
tags:
  - go
  - vue
  - video
---

### 前言

- 为什么要用断点续传?

- 断点续传是为了解决上传过程中断掉的问题，能够继续上传。
- 防止用户的流量走的太快 


### 后端go代码

- 测试方法中,我们开启了一个9999的http端口
- 使用parseRange方法去分析请求头中视频的需要的断点位置

```go
func TestVideo(t *testing.T) {
	http.HandleFunc("/api/video", func(w http.ResponseWriter, r *http.Request) {
		// 打开视频文件
		videoFile, err := os.Open("videos/video3.ts")
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
}

// 解析 Range 请求头，返回起始和结束位置
func parseRange(rangeHeader string, fileSize int64) (int64, int64, error) {
	// Range 请求头的格式为 "bytes=start-end"
	rangeParts := strings.SplitN(rangeHeader, "=", 2)
	byteRange := strings.SplitN(rangeParts[1], "-", 2)

	// 解析起始位置
	start, err := strconv.ParseInt(byteRange[0], 10, 64)
	if err != nil {
		return 0, 0, err
	}

	var end int64
	// 如果请求头中有指定结束位置，则解析结束位置
	if byteRange[1] != "" {
		end, err = strconv.ParseInt(byteRange[1], 10, 64)
		if err != nil {
			return 0, 0, err
		}
	} else {
		// 如果请求头中没有指定结束位置，则设置结束位置为文件大小减一
		end = fileSize - 1
	}

	return start, end, nil
}
```

- 这里的目录结构中,我们上传了vedio2给前端![img](https://img2.imgtp.com/2024/02/11/cs5UfnMy.png)

### 前端代码

- 前端使用vedio去请求后端资源

```vue
<template>
  <div>
    <video id="myVideo" controls @timeupdate="handleTimeUpdate" width="500px">
      <!-- 设置视频源 -->
      <source :src="videoSource" type="video/mp4">
    </video>
  </div>
</template>

<script setup>
import { ref } from "vue";

const videoSource = "http://localhost:9999/api/video"; // 视频源的 URL
const currentTime = ref(0);
const handleTimeUpdate = (e) => {
  // 获取当前视频播放的时间
  currentTime.value = e.target.currentTime;
};

</script>


<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
```

- 视频已经开始断点续传过来了

![img](https://img2.imgtp.com/2024/02/11/qYxwrVSE.png)