defmodule WatchMake.Maker do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([{:settings, %{"root" => root, "default_make" => default_make}} | _]) do
    {:ok, %{running: false, waiting: false, root: root, default_make: default_make}}
  end

  def run_it(%{root: root, default_make: make_targets}) do
    IO.puts "Making"

    cmd = "direnv exec . make " <> Enum.join(make_targets," ")

    Port.open({:spawn, cmd}, [:binary, :exit_status, :stderr_to_stdout, cd: root])
  end

  def handle_cast(:make, %{running: false} = state) do
    port = run_it(state)

    {:noreply, %{state | running: port, waiting: false}}
  end

  def handle_cast(:make, %{running: _port} = state) do
    if not state.waiting do
      IO.puts "Going to build again"
    end

    {:noreply, %{state | waiting: true}}
  end

  def handle_info({_p, {:data, output}}, state) do
    "\n\e[3m#{output}\e[0m"
    |> WatchMake.Util.indent("    ")
    |> IO.puts

    {:noreply, state}
  end

  def handle_info({_p, {:exit_status, _}}, %{waiting: waiting} = state) do
    IO.puts "Finished making"
    if waiting do
      port = run_it(state)
      {:noreply, %{state | running: port, waiting: false}}
    else
      {:noreply, %{ state | running: false }}
    end
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
