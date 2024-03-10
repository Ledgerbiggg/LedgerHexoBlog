---
title: excelize操作excel
tags:
  - go每日一库
  - excelize
---

## 简介

- "github.com/360EntSecGroup-Skylar/excelize" 是一个开源的 Go 语言库，用于读写 Microsoft Excel 文件（.xlsx 格式）。它提供了一系列功能强大的 API，可以用来创建、修改和操作 Excel 文件，包括设置单元格值、样式、合并单元格、设置图表等等。这个库的使用方式简单直观，适用于各种需要处理 Excel 文件的场景，比如数据导出、报表生成等。由于其功能完善且性能优异，因此在 Go 社区中得到了广泛的应用和好评。

## 快速使用

- excelize.NewFile() 创建一个excel对象
- file.NewSheet(sheetName) 创建一个sheet
- file.DeleteSheet("Sheet1") 移除一个sheet
- file.SetCellValue(sheetName, string(rune(k))+"1", e.Header[i]) 设置单元
- file.SetColWidth(sheetName, "A", "A", 45) 设置长度
- 之后使用反射遍历结构体的所有字段去写入单元格

```go
type ExcelHelper struct {
	FileName          string           // 文件名称
	Header            []string         // 表头
	SheetNameWithData map[string][]any // sheet名
}

// GenerateExcelWithSheets  生成excel
func (e *ExcelHelper) GenerateExcelWithSheets() error {
	file := excelize.NewFile()
	var ints []int
	for sheetName, data := range e.SheetNameWithData {
		file.NewSheet(sheetName)
		file.DeleteSheet("Sheet1")
		for i := 0; i < len(e.Header); i++ {
			k := 'A' + i
			file.SetCellValue(sheetName, string(rune(k))+"1", e.Header[i])
			file.SetColWidth(sheetName, "A", "A", 45) // width 为你想要设置的列宽度
			file.SetColWidth(sheetName, "B", "B", 70) // width 为你想要设置的列宽度
			file.SetColWidth(sheetName, "C", "C", 45) // width 为你想要设置的列宽度
		}
		for i := 0; i < len(data); i++ {
			row := i + 2 // 行索引从2开始，因为第一行是表头
			a := data[i]
			t := reflect.ValueOf(a)
			if t.Kind() == reflect.Ptr {
				t = t.Elem()
			}
			// 遍历结构体的字段
			for j := 0; j < t.NumField(); j++ {
				field := t.Field(j)
				k := 'A' + j
				file.SetCellValue(sheetName, string(rune(k))+strconv.Itoa(row), field.Interface())
				log.Println("写入sheet: " + sheetName + " 行索引: " + strconv.Itoa(row) + " 列索引: " + string(rune(k)) + " 值: " + field.String())
			}
		}
		log.Println("sheet " + sheetName + " 写入成功")
		ints = append(ints, 1)
	}
	err := file.SaveAs(e.FileName)
	if err != nil {
		fmt.Println("save excel fail " + err.Error())
		return err
	}
	return nil
}

func NewExcelHelper(fileName string, header []string, SheetNameWithData map[string][]any) *ExcelHelper {
	return &ExcelHelper{FileName: fileName, Header: header, SheetNameWithData: SheetNameWithData}
}
```
