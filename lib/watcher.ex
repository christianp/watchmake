defmodule WatchMake.Watcher do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(maker_pid: maker_pid, settings: %{"root" => root, "path" => dirs, "extensions" => extensions}, name: name) do
    dirs = 
      dirs
      |> Enum.map(&(root <> "/" <> &1))
      Enum.filter(dirs, &File.exists?/1)

    IO.puts "Watching these directories for changes:"
    for d <- dirs do
        IO.puts "  " <> d
    end

    {:ok, watcher_pid} = FileSystem.start_link(dirs: dirs, name: name)
    FileSystem.subscribe(watcher_pid)

    {:ok, %{watcher_pid: watcher_pid, dirs: dirs, extensions: extensions, maker_pid: maker_pid}}
  end

  def should_watch_file(nil, _file) do
    true
  end

  def should_watch_file(:any, _file) do
    true
  end

  def should_watch_file(extensions, file) do
    MapSet.new(extensions)
    |>MapSet.member?(Path.extname(file))
  end

  def handle_info(
    {:file_event, watcher_pid, {path, events}},
    %{watcher_pid: watcher_pid, dirs: dirs, extensions: extensions} = state
  ) do

    root =
      dirs
      |> Enum.find(fn(d) ->
        Path.type(Path.relative_to(path, d)) == :relative
      end
      )

    relpath = Path.relative_to(path, root)

    important_event = not MapSet.disjoint?(MapSet.new(events), MapSet.new([:modified, :created, :deleted]))

    watching = should_watch_file(extensions, path)

    if watching and important_event do
      file_changed(relpath, state)
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    {:noreply, state}
  end

  def file_changed(file, %{maker_pid: maker_pid}) do
    GenServer.cast(maker_pid, :make)
  end
end
