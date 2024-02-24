---
title: archive/zip文件压缩
tags:
  - go每日一库
  - archive/zip
---
## 简介

- archive/zip 是一个用于创建和提取 ZIP 归档文件的 Go 语言包。ZIP 文件是一种常见的存档文件格式，它可以包含多个文件和文件夹，并使用压缩算法减小文件大小。archive/zip 包提供了创建、打开、读取和写入 ZIP 文件的功能，使得在 Go 语言中处理 ZIP 文件变得非常简单。

## 快速使用

1. 压缩

- zip.NewWriter(fw) 更具一个文件创建一个zip.Write,用来写入压缩文件
- filepath.Walk(src, func(path string, fi os.FileInfo, errBack error) (err error) 用来递归src路径文件夹中的所有的文件(src可以是文件路径也可以是文件夹路径,文件就执行一次)
- zip.FileInfoHeader(fi) 将文件信息转换为 ZIP 文件头
- 后面的逻辑是我将src这层目录去除掉了
- zw.CreateHeader(fh) 方法创建一个新的文件并得到一个 io.Writer 对象
- io.Copy(w, fr) 拷贝文件将这个文件写入压缩包

```go
func Zip(dst string, src string) (err error) {
	// 创建准备写入的文件
	fw, err := os.Create(dst)
	defer fw.Close()
	if err != nil {
		return err
	}

	// 通过 fw 来创建 zip.Write
	zw := zip.NewWriter(fw)
	defer zw.Close()

	// 去除src目录前缀
	var i = true

	// 下面来将文件写入 zw ，因为有可能会有很多个目录及文件，所以递归处理
	return filepath.Walk(src, func(path string, fi os.FileInfo, errBack error) (err error) {
		// 处理遍历过程中的错误
		if errBack != nil {
			log.Println("filepath.Walk:", errBack)
			return errBack
		}

		// 使用 zip.FileInfoHeader 方法将文件信息转换为 zip 文件头
		fh, err := zip.FileInfoHeader(fi)
		// 将最外层的src去除掉
		fh.Name = strings.Replace(path, "src\\", "", 1)
		// 将\ 替换为 /
		fh.Name = strings.Replace(fh.Name, "\\", "/", -1)

		// 将src目录去除,但是只能去除一次
		if fi.IsDir() && fh.Name == "src" && i {
			i = false
			return nil
		}

		if err != nil {
			log.Println("fh error:", err)
			return
		}

		// 使用 zip.Writer.CreateHeader 方法创建一个新的文件并得到一个 io.Writer 对象
		w, err := zw.CreateHeader(fh)
		if err != nil {
			log.Println("w error:", err)
			return
		}

		// 文件夹不需要拷贝
		if fi.IsDir() {
			return nil
		}

		// 打开文件
		fr, err := os.Open(path)

		defer fr.Close()
		if err != nil {
			log.Println("fr error:", err)
			return
		}

		_, errBack = io.Copy(w, fr)
		log.Println("success zip file:", fh.Name)
		if errBack != nil {
			log.Println("written error:", errBack)
			return
		}
		return nil
	})
}
```

- 将src目录下的所有文件,都压缩成为log.zip

![img](https://img2.imgtp.com/2024/02/19/hA36aNoU.png)

1. 解压缩

- zip.OpenReader(src) 打开一个zip压缩包
- os.Mkdir(dest, os.ModePerm) 创建一个文件夹用于存放压缩包的解压出来的文件
- for _, file := range zipFile.File {}遍历所有的文件
- file.FileInfo().IsDir() 如果遍历到的是文件夹,就要创建一个新的文件夹然后走下一个循环,跳过文件拷贝
- io.Copy(targetFile, fileReader)  拷贝至目标文件

```go
func Unzip(src string, dest string) error {
	// 打开 ZIP 文件
	zipFile, err := zip.OpenReader(src)
	if err != nil {
		log.Println("cant open zip:", err)
		return err
	}
	defer zipFile.Close()

	err = os.Mkdir(dest, os.ModePerm)
	if err != nil {
		//log.Println(dest+"dir is exist", err)
	}

	// 遍历 ZIP 文件中的文件和文件夹
	for _, file := range zipFile.File {
		// 打开 ZIP 文件中的文件
		fileReader, err := file.Open()
		if err != nil {
			log.Println("unzipping error:", err)
			return err
		}
		defer fileReader.Close()

		if file.FileInfo().IsDir() {
			err := os.Mkdir(dest+"\\"+file.Name, os.ModePerm)
			if err != nil {
				//log.Println("cant create dir:", err)
			}
			continue
		}

		// 创建目标文件
		targetFile, err := os.Create(dest + "\\" + file.Name)
		if err != nil {
			log.Println("cant create file:", err)
			return err
		}
		defer targetFile.Close()

		// 将 ZIP 文件中的文件内容复制到目标文件中
		_, err = io.Copy(targetFile, fileReader)
		if err != nil {
			log.Println("cant copy:", err)
			return err
		}

		log.Println("success unzip file:", file.Name)
	}

	log.Println("success unzip file:", src)
	return nil
}
```

- 成功将log.zip解压到dest目录下面

![img](https://img2.imgtp.com/2024/02/19/enw6dLvu.png)



