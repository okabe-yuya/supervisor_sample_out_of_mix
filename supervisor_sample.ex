defmodule Child do
  @moduledoc """
    supervisorから起動されるタスクを実行するプロセス
    上限回数まで親プロセスにメッセージを送信して、上限に達したら終了してkillされる
  """

  @doc """
    supervisorから実行される関数。
    supervisorからlinkされたプロセスの生成を行う
  """
  def start_link(receiver, max_send) do
    # launch process link to supervisor process
    pid = spawn_link(__MODULE__, :init, [receiver, max_send])
    {:ok, pid}
  end

  def init(receiver, max_send) do
    # set seed for each process
    IO.puts("Start child with pid #{inspect(self())}")
    Process.sleep(200)
    sender(receiver, max_send)
  end

  @doc """
    上限回数まで再帰的にメッセージを親プロセスに送信する関数
  """
  def sender(_, 0), do: :ok
  def sender(receiver, max_send) do
    send(receiver, {:MESSAGE, "hello! from #{inspect(self())}"})
    sender(receiver, max_send-1)
  end
end


defmodule Parent do
  @moduledoc """
    supervisorの定義モジュール
  """
  use Supervisor

  @doc """
    supervisorの起動
  """
  def start_link(receiver, total_process) do
    Supervisor.start_link(__MODULE__, {receiver, total_process}, name: __MODULE__)
  end

  @doc """
    supervisorの設定と戦略をまとめた関数
  """
  def init({receiver, total_process}) do
    children = Enum.map(1..total_process, fn n ->
      %{
        id: "#{__MODULE__}_#{n}",
        # Childのstart_link関数に引数を渡して呼び出す。
        start: {Child, :start_link, [receiver, total_process]},
        restart: :permanent
      }
    end)

    # Aプロセスが死んだ時にAプロセスを復活させる -> 上限は10回(全プロセスで合算)
    Supervisor.init(children, strategy: :one_for_one, max_restarts: 10)
  end
end


defmodule SupervisorSample do
  @moduledoc """
    supervisorの呼び出しとメッセージの受信をサボるためのwrapperモジュール
  """

  @doc """
    supervisorの起動と再帰的メッセージ受信ループを実行
  """
  def launch(total_process) do
    # launch supervisor
    Parent.start_link(self(), total_process)
    receiver()
  end

  def receiver() do
    receive do
      {:MESSAGE, content} ->
        IO.puts("received message!: #{inspect(content)}")
        receiver()
    end
  end
end
