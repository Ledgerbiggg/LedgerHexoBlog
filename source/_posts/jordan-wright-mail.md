---
title: 使用go语言框架jordan-wright/email发送邮件
date: 2023-02-10
tags: go,email
---

## jordan-wright/email

是一个用于构建和发送电子邮件的 Go 语言库。它提供了一种简单而灵活的方式来创建和发送电子邮件，支持常见的邮件功能，例如发送文本邮件、HTML 邮件、附件邮件等

这个库的主要功能包括：

1.  **创建邮件：** 你可以使用 email.NewEmail() 函数创建一个新的邮件对象，并设置邮件的发送者、收件人、主题、正文内容等属性。
2.  **设置附件：** 你可以使用 email.AttachFile() 或 email.AttachReader() 方法添加附件到邮件中。
3.  **发送邮件：** 使用 email.Send() 方法发送邮件，你可以指定 SMTP 服务器的地址和端口，并提供认证信息（如果需要的话）。

## 举例

前戏:获取qq邮箱的smtp授权码

![img](https://img2.imgtp.com/2024/02/10/IhNJMtA8.png)



![img](https://img2.imgtp.com/2024/02/10/IhNJMtA8.png)



1. 导入包



```bash
"github.com/jordan-wright/email"
```



2. 简单使用



```go
package main

import (
    "log"
    "net/smtp"

    "github.com/jordan-wright/email"
)

func main() {
    e := email.NewEmail()
    e.From = "dj <xxx@126.com>"
    e.To = []string{"935653229@qq.com"}
    e.Subject = "Awesome web"
    e.Text = []byte("Text Body is, of course, supported!")
    err := e.Send("smtp.126.com:25", smtp.PlainAuth("", "xxx@126.com", "yyy", "smtp.126.com"))
    if err != nil {
        log.Fatal(err)
    }
}
```



3. 可以使用e.HTML和e.Attch等方法发送网页转义的消息或者附件,还可以使用CC,BBC的模式去发送邮件

- CC（抄送）： 把邮件抄送给其他收件人，被抄送的人能看到其他收件人的邮件地址。
- BCC（密送）： 把邮件密送给其他收件人，被密送的人看不到其他收件人的邮件地址。这样其他收件人就不知道彼此都收到了相同的邮件。

### 简单封装一下就可以使用了(model.go和send_util.go)

- model

```go
package email

import (
	"github.com/jordan-wright/email" // 导入发送邮件所需的库
)

// EType 表示邮件类型
type EType int

// AddrType 表示地址类型
type AddrType int

// QQ 邮件类型常量
const (
	QQ EType = iota // QQ 邮箱类型
)

// SendUtil 封装了发送邮件的相关信息和操作
type SendUtil struct {
	From    string       // 发件人邮箱地址
	To      string       // 收件人邮箱地址
	Subject string       // 邮件主题
	Text    string       // 邮件正文
	Attach  *Attach      // 附件信息
	MyInfo  *User        // 收件人信息
	ToCC    []string     // 抄送收件人信息
	ToBCC   []string     // 密送收件人信息
	addr    string       // SMTP 服务器地址
	host    string       // SMTP 服务器主机名
	se      *email.Email // 发送邮件实例
	cce     *email.Email // 抄送邮件实例
	bcce    *email.Email // 密送邮件实例
}

// Attach 表示邮件附件信息
type Attach struct {
	fileBytes []byte // 附件文件内容
	fileName  string // 附件文件名
	fileType  string // 附件文件类型
}

// NewAttach 创建新的附件信息
func NewAttach(fileBytes []byte, fileName string, fileType string) *Attach {
	return &Attach{fileBytes: fileBytes, fileName: fileName, fileType: fileType}
}

// User 表示收件人信息
type User struct {
	Identity string // 收件人标识
	Username string // 收件人邮箱用户名
	Password string // 收件人邮箱密码
}

// NewUser 创建新的收件人信息
func NewUser(identity string, username string, password string) *User {
	return &User{Identity: identity, Username: username, Password: password}
}

// NewBCCSendUtil 创建新的密送邮件实例
func NewBCCSendUtil(from string, to string, subject string, text string, attach *Attach, myInfo *User, ToBCC []string, t EType) *SendUtil {
	e := &SendUtil{From: from, To: to, Subject: subject, Text: text, Attach: attach, MyInfo: myInfo, ToBCC: ToBCC}
	switchType(t, e)
	return e
}

// NewCCSendUtil 创建新的抄送邮件实例
func NewCCSendUtil(from string, to string, subject string, text string, attach *Attach, myInfo *User, ToCC []string, t EType) *SendUtil {
	e := &SendUtil{From: from, To: to, Subject: subject, Text: text, Attach: attach, MyInfo: myInfo, ToCC: ToCC}
	switchType(t, e)
	return e
}

// NewSimpleSendUtil 创建新的普通邮件实例
func NewSimpleSendUtil(from string, to string, subject string, text string, attach *Attach, myInfo *User, t EType) *SendUtil {
	e := &SendUtil{From: from, To: to, Subject: subject, Text: text, Attach: attach, MyInfo: myInfo}
	switchType(t, e)
	return e
}

// switchType 根据邮件类型切换 SMTP 服务器地址和主机名
func switchType(t EType, e *SendUtil) {
	switch t {
	case QQ:
		e.addr = "smtp.qq.com:25" // Q
		e.host = "smtp.qq.com"
		break
	}
}
```

- send_util

```go
package email

import (
	"bytes"
	"fmt"
	"github.com/jordan-wright/email"
	"net/smtp"
)

// IsCCOrBCCSend 用于发送包含抄送或密送收件人的邮件
func (s *SendUtil) IsCCOrBCCSend(isText bool, isCC bool) error {
	if s.From == "" ||
		s.To == "" ||
		s.Subject == "" ||
		s.Text == "" ||
		s.addr == "" ||
		s.host == "" ||
		s.MyInfo == nil ||
		s.MyInfo.Username == "" ||
		s.MyInfo.Password == "" {
		return fmt.Errorf("发送邮件失败, 信息不全")
	}

	var e *email.Email
	if isCC {
		if s.cce == nil {
			s.cce = email.NewEmail()
		}
		e = s.cce
	} else {
		if s.bcce == nil {
			s.bcce = email.NewEmail()
		}
		e = s.bcce
	}

	// 添加抄送或密送收件人
	e.From = s.From
	e.To = []string{s.To}
	if isCC {
		e.Cc = s.ToCC // 设置抄送收件人
	} else {
		e.Bcc = s.ToBCC // 设置密送收件人
	}
	e.Subject = s.Subject

	// 设置邮件内容（文本或 HTML）
	if isText {
		e.Text = []byte(s.Text)
	} else {
		e.HTML = []byte(s.Text)
	}

	// 添加附件（如果有）
	if s.Attach != nil {
		_, err := e.Attach(bytes.NewReader(s.Attach.fileBytes), s.Attach.fileName, s.Attach.fileType)
		if err != nil {
			return fmt.Errorf("发送邮件失败: %v", err)
		}
	}

	// 发送邮件
	err := e.Send(s.addr, smtp.PlainAuth(s.MyInfo.Identity, s.MyInfo.Username, s.MyInfo.Password, s.host))
	if err != nil {
		return fmt.Errorf("发送邮件失败: %v", err)
	}

	return nil
}

// SimpleSend 用于发送简单的邮件（不含抄送或密送收件人）
func (s *SendUtil) SimpleSend(isText bool) error {

	if s.From == "" ||
		s.To == "" ||
		s.Subject == "" ||
		s.Text == "" ||
		s.addr == "" ||
		s.host == "" ||
		s.MyInfo == nil ||
		s.MyInfo.Username == "" ||
		s.MyInfo.Password == "" {
		return fmt.Errorf("发送邮件失败, 信息不全")
	}

	var e *email.Email
	if s.se == nil {
		s.se = email.NewEmail()
	}

	e = s.se
	// 设置发件人、收件人和主题
	e.From = s.From
	e.To = []string{s.To}
	e.Subject = s.Subject

	// 设置邮件内容（文本或 HTML）
	if isText {
		e.Text = []byte(s.Text)
	} else {
		e.HTML = []byte(s.Text)
	}

	// 添加附件（如果有）
	if s.Attach != nil {
		_, err := e.Attach(bytes.NewReader(s.Attach.fileBytes), s.Attach.fileName, s.Attach.fileType)
		if err != nil {
			return fmt.Errorf("发送邮件失败: %v", err)
		}
	}

	// 发送邮件
	err := e.Send(s.addr, smtp.PlainAuth(s.MyInfo.Identity, s.MyInfo.Username, s.MyInfo.Password, s.host))
	if err != nil {
		return fmt.Errorf("发送邮件失败: %v", err)
	}
	return nil
}
```

