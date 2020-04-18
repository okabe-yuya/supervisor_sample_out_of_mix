## Description
mix project外にてsupervisorを定義して実行するための手順をまとめたファイル
ブログ記事にて詳細を解説。自身のアウトプット&まとめとして機能している。

## about each module
### Child
プロセスにて実行されるタスクを記述したモジュール。supervisorから起動される。

### Parent
supervisorの定義と設定、戦略をまとめたモジュール。公式のsupervisorのモジュールsupervisorの実装に従って実装している。
child_spec/2は使用せずに、起動プロセスの定義を行なっている。

### SupervisorSample
supervisorの起動とメッセージの受信を簡略化したwrapperモジュールであり、`launch`が実行される関数。

## Usage
前提としてErlang&Elixirがinstallされているとする。作者の実行versionは以下の通り。
> Erlang/OTP 22 [erts-10.6.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe] [dtrace]  
> Interactive Elixir (1.9.4) - press Ctrl+C to exit (type h() ENTER for help)  

カレントディレクトリにてiexを起動する
> $ iex

.exファイルをコンパイル
```elixir
iex(1)> c("supervisor_sample.ex")
[Child, Parent, SupervisorSample]
```

wrapperモジュールの`launch`関数を呼び出す
```elixir
iex(2)> SupervisorSample.launch(2)
Start child with pid #PID<0.116.0>
Start child with pid #PID<0.117.0>
Start child with pid #PID<0.118.0>
Start child with pid #PID<0.119.0>
received message!: "hello! from #PID<0.116.0>"
received message!: "hello! from #PID<0.116.0>"
received message!: "hello! from #PID<0.117.0>"
received message!: "hello! from #PID<0.117.0>"
received message!: "hello! from #PID<0.119.0>"
received message!: "hello! from #PID<0.119.0>"
Start child with pid #PID<0.120.0>
Start child with pid #PID<0.121.0>
received message!: "hello! from #PID<0.118.0>"
received message!: "hello! from #PID<0.118.0>"
Start child with pid #PID<0.122.0>
Start child with pid #PID<0.123.0>
received message!: "hello! from #PID<0.120.0>"
received message!: "hello! from #PID<0.120.0>"
received message!: "hello! from #PID<0.121.0>"
received message!: "hello! from #PID<0.121.0>"
received message!: "hello! from #PID<0.122.0>"
Start child with pid #PID<0.124.0>
Start child with pid #PID<0.125.0>
received message!: "hello! from #PID<0.122.0>"
received message!: "hello! from #PID<0.123.0>"
received message!: "hello! from #PID<0.123.0>"
received message!: "hello! from #PID<0.124.0>"
Start child with pid #PID<0.126.0>
Start child with pid #PID<0.127.0>
received message!: "hello! from #PID<0.124.0>"
received message!: "hello! from #PID<0.125.0>"
received message!: "hello! from #PID<0.125.0>"
received message!: "hello! from #PID<0.126.0>"
** (EXIT from #PID<0.104.0>) shell process exited with reason: shutdown
```

## Check the number of restarts
- 起動するプロセス数 -> 2
- 再起動の上限値 -> 10

での実行例

```elixir
log =
"""
Start child with pid #PID<0.116.0>
:
:
received message!: "hello! from #PID<0.126.0>"
"""

log
|> String.split("\n")
|> Enum.filter(fn s -> String.starts_with?(s, "Start child with") end)
|> length()
|> IO.puts() # 12
```