---
title: Go 实现 Mock
tags:
  - go每日一库
  - mockery  
---

## 简介

- **mockery** 是一个自动生成 Go 语言 mock 代码的工具，主要用于单元测试。它基于 Go 接口生成对应的mock
  对象，让开发者无需手动编写模拟对象，大幅提高了测试的效率。

#### 主要功能

1. 自动生成 Mock 代码：根据 Go 接口生成相应的 Mock 实现。
2. 支持多种输出格式：Mock 代码可自定义输出路径。
3. 灵活的行为控制：配合 Mock 对象，可以模拟依赖的不同行为和状态。
4. 轻松集成到测试中：适合在 Go 的单元测试中使用。

## 快速使用

#### 安装 mockery

```shell
go install github.com/vektra/mockery/v2@latest
```

- 确保 GOBIN 路径已添加到系统的环境变量中，这样你就可以在命令行中使用 mockery 命令。

#### 基本用法

- 假设你有一个接口 Database，想为它生成一个 Mock 版本：

```go
package example

type Database interface {
	GetUser(id int) (string, error)
}

```

#### 使用 mockery 生成 Mock 代码

```shell
mockery --name=Database --output=mocks --with-expecter
```
* --name=Database：指定要为哪个接口生成 Mock。
* --output=mocks：生成的 Mock 代码存放在 mocks 目录中。
* --with-expecter：生成带有期望行为的辅助方法，方便测试。

#### 生成的 Mock 代码示例

- mockery 会生成类似以下的代码：

```go
package mocks

import (
	"github.com/stretchr/testify/mock"
)

type Database struct {
	mock.Mock
}

func (m *Database) GetUser(id int) (string, error) {
	args := m.Called(id)
	return args.String(0), args.Error(1)
}

```

#### 如何在测试中使用生成的 Mock

```go
package example_test

import (
	"example/mocks"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestGetUserName(t *testing.T) {
	mockDB := new(mocks.Database)
	mockDB.On("GetUser", 1).Return("Alice", nil)

	name, err := mockDB.GetUser(1)
	assert.NoError(t, err)
	assert.Equal(t, "Alice", name)

	mockDB.AssertExpectations(t) // 验证所有的期望行为是否满足
}

```

#### 总结

* mockery 是一个强大的工具，用于为 Go 接口自动生成 Mock 对象，非常适合需要频繁测试的项目。结合 testify
  等测试框架，你可以快速构建可维护、可靠的单元测试。
* 优点：减少手动编写 Mock 代码的时间；测试代码更加简洁。
* 适用场景：项目中存在多个依赖接口时，能显著提高测试效率。
* 这就是 mockery 的核心概念和基本使用！




































































































































