---
title: testify assert
tags:
  - go每日一库
  - assert  
---

`assert` 包通常是通过 Go 的 **`github.com/stretchr/testify/assert`** 这个库来使用的。这个库提供了多种断言函数，用于简化测试中的条件检查。

### 安装

首先，你需要通过 `go get` 命令安装 `testify` 包：

```bash
go get github.com/stretchr/testify/assert
```

### 常用的 `assert` 函数

以下是 `assert` 包中一些常用的断言方法，帮助你编写更加简洁的测试代码：

1. **`assert.Equal`**：检查两个值是否相等。
```go
   assert.Equal(t, expectedValue, actualValue, "Error message if they are not equal")
```

2. **`assert.NotEqual`**：检查两个值是否不相等。
```go
   assert.NotEqual(t, unexpectedValue, actualValue, "Error message if they are equal")
```

3. **`assert.Nil`**：检查一个值是否为 `nil`。
```go
   assert.Nil(t, err, "Error should be nil")
```

4. **`assert.NotNil`**：检查一个值是否不是 `nil`。
```go
   assert.NotNil(t, obj, "Object should not be nil")
```

5. **`assert.True`**：检查一个布尔值是否为 `true`。
```go
   assert.True(t, condition, "Condition should be true")
```

6. **`assert.False`**：检查一个布尔值是否为 `false`。
```go
   assert.False(t, condition, "Condition should be false")
```

7. **`assert.Contains`**：检查一个字符串或数组是否包含某个值。
```go
   assert.Contains(t, "Hello, World", "World", "String should contain 'World'")
```

8. **`assert.Len`**：检查数组、切片或映射的长度。
```go
   assert.Len(t, mySlice, 5, "Slice should have 5 elements")
```

9. **`assert.Panics`**：检查一个函数是否会产生 `panic`。
```go
   assert.Panics(t, func() { someFunctionThatShouldPanic() }, "Function should panic")
```