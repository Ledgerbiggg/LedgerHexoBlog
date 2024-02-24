---
title: archive/tar文件压缩
tags:
  - go每日一库
  - archive/tar
---


## 简介

- `archive/tar` 是 Go 语言标准库提供的一个包，用于创建、读取和操作 Tar 格式的归档文件。Tar 是一种常见的文件归档格式，通常用于在 Unix 系统中创建备份或将多个文件和目录打包成单个文件。`archive/tar` 包使得在 Go 语言中处理 Tar 归档文件变得非常简单和方便。

## 快速使用

1. 压缩

- gzip.NewWriter(targetFile) 创建 gzip 写入器
- tar.NewWriter(gzipWriter) 创建 tar 写入器
- filepath.Walk(src, func(path string, info os.FileInfo, err error) error {} 遍历源文件夹下的所有文件和子文件夹
- tar.FileInfoHeader(info, "") 创建 tar 记录
- filepath.Rel(src, path) 更新 tar 记录的名称
- tarWriter.WriteHeader(tarHeader) 写入 tar 记录
- io.Copy(tarWriter, file) 如果是文件，则将文件内容写入 tar 文件

```go
func TarGz(dst string, src string) error {
	// 创建目标压缩文件
	if !strings.HasSuffix(dst, ".tar.gz") {
		dst += ".tar.gz"
	}
	targetFile, err := os.Create(dst)
	if err != nil {
		log.Println("err when create file:", err)
		return err
	}
	defer targetFile.Close()

	// 创建 gzip 写入器
	gzipWriter := gzip.NewWriter(targetFile)
	defer gzipWriter.Close()

	// 创建 tar 写入器
	tarWriter := tar.NewWriter(gzipWriter)
	defer tarWriter.Close()

	// 遍历源文件夹下的所有文件和子文件夹
	err = filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			log.Println("err when walk file:", err)
			return err
		}

		// 忽略目录本身
		if path == src {
			return nil
		}

		// 创建 tar 记录
		tarHeader, err := tar.FileInfoHeader(info, "")
		if err != nil {
			log.Println("err when create tar header:", err)
			return err
		}

		// 更新 tar 记录的名称
		relPath, err := filepath.Rel(src, path)
		if err != nil {
			log.Println("err when get relative path:", err)
			return err
		}
		// 设置 tar 记录的名称
		tarHeader.Name = strings.Replace(relPath, "src\\", "", 1)
		tarHeader.Name = strings.Replace(tarHeader.Name, "\\", "/", -1)

		// 写入 tar 记录
		if err := tarWriter.WriteHeader(tarHeader); err != nil {
			log.Println("err when write tar header:", err)
			return err
		}

		// 如果是文件，则将文件内容写入 tar 文件
		if !info.IsDir() {
			file, err := os.Open(path)
			if err != nil {
				log.Println("err when open file:", err)
				return err
			}
			defer file.Close()

			if _, err := io.Copy(tarWriter, file); err != nil {
				log.Println("err when copy file:", err)
				return err
			}
		}

		return nil
	})

	if err != nil {
		log.Println("err when walk file:", err)
		return err
	}
	return err
}
```

1. 解压缩

- gzip.NewReader(file) 创建 gzip 读取器
- tar.NewReader(gzipReader) 创建 tar 读取器
- tarReader.Next() 解压缩文件
- header.Typeflag 根据文件类型执行不同的操作

```go
func UnTarGz(src string, dest string) error {
	// 打开要解压缩的文件
	file, err := os.Open(src)
	if err != nil {
		log.Println("open file error:", err)
		return err
	}
	defer file.Close()

	err = os.Mkdir(dest, os.ModePerm)
	if err != nil {
		//log.Println(dest+"dir is exist", err)
	}

	// 创建 gzip 读取器
	gzipReader, err := gzip.NewReader(file)
	if err != nil {
		log.Println("read gzip error:", err)
		return err
	}
	defer gzipReader.Close()

	// 创建 tar 读取器
	tarReader := tar.NewReader(gzipReader)

	// 解压缩文件
	for {
		header, err := tarReader.Next()

		if err == io.EOF {
			break
		}
		if err != nil {
			log.Println("read tar error:", err)
			return err
		}

		targetPath := filepath.Join("."+"\\"+dest, header.Name)

		// 根据文件类型执行不同的操作
		switch header.Typeflag {
		case tar.TypeDir:
			// 如果是目录，创建目录
			if err := os.MkdirAll(targetPath, os.FileMode(header.Mode)); err != nil {
				log.Println("mkdir error:", err)
				return err
			}
		case tar.TypeReg:
			// 如果是文件，创建文件并写入内容
			fileToWrite, err := os.OpenFile(targetPath, os.O_CREATE|os.O_RDWR, os.FileMode(header.Mode))
			if err != nil {
				log.Println("open file error:", err)
				return err
			}
			defer fileToWrite.Close()

			if _, err := io.Copy(fileToWrite, tarReader); err != nil {
				log.Println("copy error:", err)
				return err
			}
		}
	}
	return nil
}
```


