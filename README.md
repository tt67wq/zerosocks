# Zerosocks

shadowsocks实现中大多以短链主，这样会浪费链接建立的时间。
这个项目中，将client和server之间的通信全放在一个zeromq的通道中，并在本地实现一个client管理，让多个socket通信可以复用一个zeromq连接，节约了频繁建立链接的开销。
而且zeromq自带重连，不用自己再去维护了，十分方便。

