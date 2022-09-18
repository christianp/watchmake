defmodule WatchMake do
  use Application

  @default_settings %{ "default_make" => [],
    "extensions" => :any,
    "path" => ["."]
  } 

  @impl true
  def start(_type, _args) do
    WatchMake.go()
  end

  def go do
    root = IO.inspect File.cwd!()

    settings = WatchMake.load_settings(root)

    {:ok, maker_pid} = WatchMake.Maker.start_link(settings: settings, name: :maker)
    {:ok, _} = WatchMake.Watcher.start_link(maker_pid: maker_pid, settings: settings, name: :watch_files)
  end

  def load_settings(root) do
    settings = case YamlElixir.read_from_file(root <> "/.watchmakerc") do
      {:ok, settings} ->
        IO.puts "found settings"

        Map.merge(@default_settings, settings)
      _ ->
        IO.puts "default settings"

        @default_settings
    end

    settings 
    |> Map.put("root", root)
  end
end

WatchMake.go()
