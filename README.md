# Zerosocks

shadowsocks实现中大多以短链主，这样会浪费链接建立的时间。
这个项目中，将client和server之间的通信全放在一个zeromq的通道中，并在本地实现一个client管理，让多个socket通信可以复用一个zeromq连接，节约了频繁建立链接的开销。
而且zeromq自带重连，不用自己再去维护了，十分方便。

#### 目录结构
```
.
├── apps
│   ├── chumak # zeromq驱动
│   ├── client
	 ├── config
	 │   └── config.exs
	 ├── lib
	 │   ├── client
	 │   │   ├── listener.ex # 本地监听
	 │   │   ├── receiver.ex # 隧道监听
	 │   │   ├── sock_store.ex # 套接字中心
	 │   │   └── tunnel.ex # 隧道
	 │   └── client.ex
	 ├── mix.exs
	 ├── mix.lock
	 ├── README.md
	 └── test
	     ├── client_test.exs
	     └── test_helper.exs

│   ├── common # 加密，压缩等工具
│   └── server
	 ├── config
	 │   └── config.exs
	 ├── lib
	 │   ├── server
	 │   │   ├── listener.ex # 隧道监听
	 │   │   ├── sock_store.ex # 套接字中心
	 │   │   └── tunnel.ex # 隧道
	 │   └── server.ex
	 ├── mix.exs
	 ├── mix.lock
	 ├── README.md
	 └── test
	     ├── server_test.exs
	     └── test_helper.exs

├── config
│   └── config.exs
├── mix.exs
└── README.md

```

详细解释 [自己搓个shadowsocks](https://github.com/tt67wq/blog/issues/44)
